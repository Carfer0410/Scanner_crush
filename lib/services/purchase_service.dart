import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'logger_service.dart';
import 'monetization_service.dart';

/// Resultado de una operación de compra
enum PurchaseResult {
  /// Compra iniciada correctamente (flujo de pago abierto)
  success,
  /// La tienda (Google Play / App Store) no está disponible
  storeNotAvailable,
  /// No se encontraron productos configurados (IDs no coinciden con la consola)
  productNotFound,
  /// Ya hay una compra en proceso
  purchaseAlreadyPending,
  /// Error al iniciar la compra en la tienda
  purchaseInitFailed,
  /// Excepción inesperada
  error,
}

/// Servicio de compras dentro de la app para Scanner Crush
/// Maneja suscripciones Premium y Premium Plus
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  static PurchaseService get instance => _instance;
  PurchaseService._internal();

  // Store para compras
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  // Estado del servicio
  bool _isAvailable = false;
  bool _purchasePending = false;
  String? _queryProductError;

  // Último resultado de compra para feedback al usuario
  PurchaseResult _lastPurchaseResult = PurchaseResult.success;
  String? _lastErrorMessage;

  /// Notificador para que la UI reaccione a compras exitosas
  final ValueNotifier<bool> purchaseSuccessNotifier = ValueNotifier(false);
  
  // IDs de productos para las suscripciones
  static const String premiumMonthlyId = 'premium_monthly';
  static const String premiumYearlyId = 'premium_yearly';
  static const String premiumPlusMonthlyId = 'premium_plus_monthly';
  static const String premiumPlusYearlyId = 'premium_plus_yearly';
  
  static const Set<String> _kIds = <String>{
    premiumMonthlyId,
    premiumYearlyId,
    premiumPlusMonthlyId,
    premiumPlusYearlyId,
  };

  List<ProductDetails> _products = <ProductDetails>[];
  final List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  List<String> _notFoundIds = <String>[];
  bool _isInitialized = false;

  // Getters públicos
  bool get isAvailable => _isAvailable;
  bool get isInitialized => _isInitialized;
  bool get purchasePending => _purchasePending;
  bool get hasProducts => _products.isNotEmpty;
  List<ProductDetails> get products => _products;
  List<PurchaseDetails> get purchases => _purchases;
  String? get queryProductError => _queryProductError;
  PurchaseResult get lastPurchaseResult => _lastPurchaseResult;
  String? get lastErrorMessage => _lastErrorMessage;

  /// Inicializar el servicio de compras
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Verificar disponibilidad de la tienda
    _isAvailable = await _inAppPurchase.isAvailable();
    
    if (!_isAvailable) {
      LoggerService.warning('Tienda no disponible', origin: 'PurchaseService');
      return;
    }

    LoggerService.debug('Inicializando...', origin: 'PurchaseService');

    // Configurar plataforma específica si es Android
    if (Platform.isAndroid) {
      // Habilitar compras pendientes en Android (método deprecado, ya habilitado por defecto)
      LoggerService.debug('Plataforma Android detectada', origin: 'PurchaseService');
    }

    // Escuchar cambios en las compras
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );

    // Cargar productos disponibles
    await _loadProducts();

    // Restaurar compras pendientes
    await _restorePurchases();

    _isInitialized = true;
    LoggerService.info('Inicializado correctamente', origin: 'PurchaseService');
  }

  /// Cargar productos desde las tiendas
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse productDetailResponse =
          await _inAppPurchase.queryProductDetails(_kIds);
      
      if (productDetailResponse.error != null) {
        _queryProductError = productDetailResponse.error!.message;
        LoggerService.error('Error cargando productos: $_queryProductError', origin: 'PurchaseService');
        return;
      }

      if (productDetailResponse.productDetails.isEmpty) {
        _queryProductError = 'No se encontraron productos configurados';
        LoggerService.warning('No se encontraron productos', origin: 'PurchaseService');
        return;
      }

      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      
      LoggerService.debug('Productos cargados: ${_products.length}', origin: 'PurchaseService');
      for (final product in _products) {
      LoggerService.debug('  - ${product.id}: ${product.title} (${product.price})', origin: 'PurchaseService');
      }
      
      if (_notFoundIds.isNotEmpty) {
        LoggerService.warning('Productos no encontrados: $_notFoundIds', origin: 'PurchaseService');
      }
    } catch (e) {
      _queryProductError = 'Error al cargar productos: $e';
      LoggerService.error('Excepción cargando productos: $e', origin: 'PurchaseService');
    }
  }

  /// Comprar suscripción — retorna PurchaseResult con información del resultado
  Future<PurchaseResult> buySubscription(String productId) async {
    _lastErrorMessage = null;

    if (!_isAvailable) {
      _lastPurchaseResult = PurchaseResult.storeNotAvailable;
      _lastErrorMessage = _queryProductError ?? 'Tienda no disponible';
      LoggerService.warning('Tienda no disponible para compra', origin: 'PurchaseService');
      return _lastPurchaseResult;
    }

    final ProductDetails? productDetails = _products
        .cast<ProductDetails?>()
        .firstWhere((product) => product?.id == productId, orElse: () => null);

    if (productDetails == null) {
      _lastPurchaseResult = PurchaseResult.productNotFound;
      _lastErrorMessage = 'Producto $productId no encontrado en la tienda';
      LoggerService.warning('Producto $productId no encontrado', origin: 'PurchaseService');
      return _lastPurchaseResult;
    }

    if (_purchasePending) {
      _lastPurchaseResult = PurchaseResult.purchaseAlreadyPending;
      _lastErrorMessage = 'Ya hay una compra en proceso';
      LoggerService.warning('Ya hay una compra en proceso', origin: 'PurchaseService');
      return _lastPurchaseResult;
    }

    try {
      _purchasePending = true;
      
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      LoggerService.debug('Iniciando compra de: ${productDetails.title}', origin: 'PurchaseService');
      
      bool purchaseStarted;
      if (productDetails.id.contains('monthly') || productDetails.id.contains('yearly')) {
        purchaseStarted = await _inAppPurchase.buyNonConsumable(
          purchaseParam: purchaseParam,
        );
      } else {
        purchaseStarted = await _inAppPurchase.buyConsumable(
          purchaseParam: purchaseParam,
        );
      }

      if (!purchaseStarted) {
        _purchasePending = false;
        _lastPurchaseResult = PurchaseResult.purchaseInitFailed;
        _lastErrorMessage = 'No se pudo iniciar el flujo de compra';
        LoggerService.warning('Error iniciando compra', origin: 'PurchaseService');
        return _lastPurchaseResult;
      }

      _lastPurchaseResult = PurchaseResult.success;
      LoggerService.info('Compra iniciada correctamente', origin: 'PurchaseService');
      return PurchaseResult.success;
      
    } catch (e) {
      _purchasePending = false;
      _lastPurchaseResult = PurchaseResult.error;
      _lastErrorMessage = e.toString();
      LoggerService.error('Excepción en compra: $e', origin: 'PurchaseService');
      return PurchaseResult.error;
    }
  }

  /// Restaurar compras previas
  Future<void> _restorePurchases() async {
    try {
      LoggerService.debug('Restaurando compras...', origin: 'PurchaseService');
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      LoggerService.error('Error restaurando compras: $e', origin: 'PurchaseService');
    }
  }

  /// Restaurar compras (método público)
  Future<bool> restorePurchases() async {
    try {
      await _restorePurchases();
      return true;
    } catch (e) {
      LoggerService.error('Error en restorePurchases: $e', origin: 'PurchaseService');
      return false;
    }
  }

  /// Procesar actualizaciones de compras
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    LoggerService.debug('Actualizaciones de compra recibidas: ${purchaseDetailsList.length}', origin: 'PurchaseService');
    
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      LoggerService.debug('Procesando compra: ${purchaseDetails.productID} - Estado: ${purchaseDetails.status}', origin: 'PurchaseService');
      
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          _handleSuccessfulPurchase(purchaseDetails);
        }
        
        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  /// Mostrar UI de compra pendiente
  void _showPendingUI() {
    LoggerService.debug('Compra pendiente...', origin: 'PurchaseService');
    _purchasePending = true;
  }

  /// Manejar errores de compra
  void _handleError(IAPError error) {
    LoggerService.error('Error de compra: ${error.message}', origin: 'PurchaseService');
    _purchasePending = false;
    _lastPurchaseResult = PurchaseResult.error;
    _lastErrorMessage = error.message;
  }

  /// Manejar compra exitosa
  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    LoggerService.info('Compra exitosa: ${purchaseDetails.productID}', origin: 'PurchaseService');
    _purchasePending = false;
    
    // Actualizar estado en MonetizationService
    SubscriptionTier newTier = SubscriptionTier.free;
    
    switch (purchaseDetails.productID) {
      case premiumMonthlyId:
      case premiumYearlyId:
        newTier = SubscriptionTier.premium;
        break;
      case premiumPlusMonthlyId:
      case premiumPlusYearlyId:
        newTier = SubscriptionTier.premiumPlus;
        break;
    }
    
    if (newTier != SubscriptionTier.free) {
      if (newTier == SubscriptionTier.premium) {
        await MonetizationService.instance.upgradeToPremium();
      } else if (newTier == SubscriptionTier.premiumPlus) {
        await MonetizationService.instance.upgradeToPremiumPlus();
      }
      LoggerService.info('Suscripción actualizada a: $newTier', origin: 'PurchaseService');
      
      // Notificar a la UI que la compra fue exitosa
      purchaseSuccessNotifier.value = !purchaseSuccessNotifier.value;
    }
  }

  /// Verificar si un producto está disponible
  bool isProductAvailable(String productId) {
    return _products.any((product) => product.id == productId);
  }

  /// Obtener detalles de un producto
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Obtener precio formateado de un producto
  String getFormattedPrice(String productId) {
    final product = getProduct(productId);
    return product?.price ?? 'N/A';
  }

  /// Verificar si hay suscripciones activas
  bool hasActiveSubscription() {
    return _purchases.any((purchase) => 
      purchase.status == PurchaseStatus.purchased &&
      _kIds.contains(purchase.productID)
    );
  }

  /// Manejar fin del stream
  void _updateStreamOnDone() {
    LoggerService.debug('Stream de compras terminado', origin: 'PurchaseService');
    _subscription.cancel();
  }

  /// Manejar errores del stream
  void _updateStreamOnError(dynamic error) {
    LoggerService.error('Error en stream de compras: $error', origin: 'PurchaseService');
  }

  /// Liberar recursos
  Future<void> dispose() async {
    if (_isInitialized) {
      await _subscription.cancel();
      _isInitialized = false;
      LoggerService.debug('Recursos liberados', origin: 'PurchaseService');
    }
  }
}
