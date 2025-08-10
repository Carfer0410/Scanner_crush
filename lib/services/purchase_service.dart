import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'monetization_service.dart';

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
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  List<String> _notFoundIds = <String>[];
  bool _isInitialized = false;

  // Getters públicos
  bool get isAvailable => _isAvailable;
  bool get purchasePending => _purchasePending;
  List<ProductDetails> get products => _products;
  List<PurchaseDetails> get purchases => _purchases;
  String? get queryProductError => _queryProductError;

  /// Inicializar el servicio de compras
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Verificar disponibilidad de la tienda
    _isAvailable = await _inAppPurchase.isAvailable();
    
    if (!_isAvailable) {
      debugPrint('🛒 PurchaseService: Tienda no disponible');
      return;
    }

    debugPrint('🛒 PurchaseService: Inicializando...');

    // Configurar plataforma específica si es Android
    if (Platform.isAndroid) {
      // Habilitar compras pendientes en Android (método deprecado, ya habilitado por defecto)
      debugPrint('🛒 Plataforma Android detectada');
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
    debugPrint('🛒 PurchaseService: Inicializado correctamente');
  }

  /// Cargar productos desde las tiendas
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse productDetailResponse =
          await _inAppPurchase.queryProductDetails(_kIds);
      
      if (productDetailResponse.error != null) {
        _queryProductError = productDetailResponse.error!.message;
        debugPrint('🛒 Error cargando productos: $_queryProductError');
        return;
      }

      if (productDetailResponse.productDetails.isEmpty) {
        _queryProductError = 'No se encontraron productos configurados';
        debugPrint('🛒 Error: No se encontraron productos');
        return;
      }

      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      
      debugPrint('🛒 Productos cargados: ${_products.length}');
      for (final product in _products) {
        debugPrint('  - ${product.id}: ${product.title} (${product.price})');
      }
      
      if (_notFoundIds.isNotEmpty) {
        debugPrint('🛒 Productos no encontrados: $_notFoundIds');
      }
    } catch (e) {
      _queryProductError = 'Error al cargar productos: $e';
      debugPrint('🛒 Excepción cargando productos: $e');
    }
  }

  /// Comprar suscripción
  Future<bool> buySubscription(String productId) async {
    if (!_isAvailable) {
      debugPrint('🛒 Error: Tienda no disponible');
      return false;
    }

    final ProductDetails? productDetails = _products
        .cast<ProductDetails?>()
        .firstWhere((product) => product?.id == productId, orElse: () => null);

    if (productDetails == null) {
      debugPrint('🛒 Error: Producto $productId no encontrado');
      return false;
    }

    if (_purchasePending) {
      debugPrint('🛒 Error: Ya hay una compra en proceso');
      return false;
    }

    try {
      _purchasePending = true;
      
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      debugPrint('🛒 Iniciando compra de: ${productDetails.title}');
      
      bool purchaseResult;
      if (productDetails.id.contains('monthly') || productDetails.id.contains('yearly')) {
        // Es una suscripción
        purchaseResult = await _inAppPurchase.buyNonConsumable(
          purchaseParam: purchaseParam,
        );
      } else {
        // Es un producto consumible (por si acaso)
        purchaseResult = await _inAppPurchase.buyConsumable(
          purchaseParam: purchaseParam,
        );
      }

      if (!purchaseResult) {
        _purchasePending = false;
        debugPrint('🛒 Error iniciando compra');
        return false;
      }

      debugPrint('🛒 Compra iniciada correctamente');
      return true;
      
    } catch (e) {
      _purchasePending = false;
      debugPrint('🛒 Excepción en compra: $e');
      return false;
    }
  }

  /// Restaurar compras previas
  Future<void> _restorePurchases() async {
    try {
      debugPrint('🛒 Restaurando compras...');
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('🛒 Error restaurando compras: $e');
    }
  }

  /// Restaurar compras (método público)
  Future<bool> restorePurchases() async {
    try {
      await _restorePurchases();
      return true;
    } catch (e) {
      debugPrint('🛒 Error en restorePurchases: $e');
      return false;
    }
  }

  /// Procesar actualizaciones de compras
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    debugPrint('🛒 Actualizaciones de compra recibidas: ${purchaseDetailsList.length}');
    
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint('🛒 Procesando compra: ${purchaseDetails.productID} - Estado: ${purchaseDetails.status}');
      
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
    debugPrint('🛒 Compra pendiente...');
    _purchasePending = true;
  }

  /// Manejar errores de compra
  void _handleError(IAPError error) {
    debugPrint('🛒 Error de compra: ${error.message}');
    _purchasePending = false;
  }

  /// Manejar compra exitosa
  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    debugPrint('🛒 Compra exitosa: ${purchaseDetails.productID}');
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
      // Actualizar tier en MonetizationService
      if (newTier == SubscriptionTier.premium) {
        await MonetizationService.instance.upgradeToPremium();
      } else if (newTier == SubscriptionTier.premiumPlus) {
        await MonetizationService.instance.upgradeToPremiumPlus();
      }
      debugPrint('🛒 Suscripción actualizada a: $newTier');
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
    debugPrint('🛒 Stream de compras terminado');
    _subscription.cancel();
  }

  /// Manejar errores del stream
  void _updateStreamOnError(dynamic error) {
    debugPrint('🛒 Error en stream de compras: $error');
  }

  /// Liberar recursos
  Future<void> dispose() async {
    if (_isInitialized) {
      await _subscription.cancel();
      _isInitialized = false;
      debugPrint('🛒 PurchaseService: Recursos liberados');
    }
  }
}
