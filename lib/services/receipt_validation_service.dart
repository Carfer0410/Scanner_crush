import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';

import 'logger_service.dart';
import 'monetization_service.dart';

enum ReceiptValidationStatus {
  valid,
  invalid,
  skipped,
  error,
}

class ReceiptValidationResult {
  final ReceiptValidationStatus status;
  final String message;
  final SubscriptionTier? tier;
  final DateTime? expiryDateUtc;

  const ReceiptValidationResult({
    required this.status,
    required this.message,
    this.tier,
    this.expiryDateUtc,
  });

  bool get isValid => status == ReceiptValidationStatus.valid;

  bool shouldGrantEntitlement({
    required bool isReleaseMode,
    required bool requireServerValidationInRelease,
  }) {
    if (isValid) return true;

    if (status == ReceiptValidationStatus.skipped) {
      return !isReleaseMode || !requireServerValidationInRelease;
    }

    return false;
  }
}

class ReceiptValidationService {
  static final ReceiptValidationService _instance = ReceiptValidationService._internal();
  static ReceiptValidationService get instance => _instance;
  ReceiptValidationService._internal();

  static const bool requireServerValidationInRelease = bool.fromEnvironment(
    'REQUIRE_SERVER_PURCHASE_VALIDATION',
    defaultValue: true,
  );

  static const String _baseUrl = String.fromEnvironment(
    'PURCHASE_VALIDATION_BASE_URL',
    defaultValue: '',
  );

  static const String _apiKey = String.fromEnvironment(
    'PURCHASE_VALIDATION_API_KEY',
    defaultValue: '',
  );

  static const String _validatePath = String.fromEnvironment(
    'PURCHASE_VALIDATION_PATH',
    defaultValue: '/api/v1/purchases/validate',
  );

  static const int _timeoutSeconds = int.fromEnvironment(
    'PURCHASE_VALIDATION_TIMEOUT_SECONDS',
    defaultValue: 12,
  );

  bool get isConfigured => _baseUrl.trim().isNotEmpty;

  Future<void> initialize() async {
    if (!isConfigured) {
      LoggerService.warning(
        'ReceiptValidationService sin endpoint configurado (PURCHASE_VALIDATION_BASE_URL).',
        origin: 'ReceiptValidationService',
      );
      return;
    }

    LoggerService.info(
      'ReceiptValidationService configurado: $_baseUrl',
      origin: 'ReceiptValidationService',
    );
  }

  Future<ReceiptValidationResult> validatePurchase(
    PurchaseDetails purchaseDetails, {
    SubscriptionTier? expectedTier,
  }) async {
    if (!isConfigured) {
      return const ReceiptValidationResult(
        status: ReceiptValidationStatus.skipped,
        message: 'Validation skipped: backend URL not configured',
      );
    }

    final uri = _buildUri();
    if (uri == null) {
      return const ReceiptValidationResult(
        status: ReceiptValidationStatus.error,
        message: 'Validation failed: invalid backend URL',
      );
    }

    final payload = _buildPayload(
      purchaseDetails: purchaseDetails,
      expectedTier: expectedTier,
    );

    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
    };
    if (_apiKey.isNotEmpty) {
      headers['x-api-key'] = _apiKey;
    }

    try {
      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode(payload),
          )
          .timeout(Duration(seconds: _timeoutSeconds));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return ReceiptValidationResult(
          status: ReceiptValidationStatus.error,
          message: 'Validation HTTP ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const ReceiptValidationResult(
          status: ReceiptValidationStatus.error,
          message: 'Validation response is not a JSON object',
        );
      }

      return _parseValidationResponse(decoded);
    } catch (e, st) {
      LoggerService.error(
        'Error validando compra: $e',
        origin: 'ReceiptValidationService',
        error: e,
        stackTrace: st,
      );
      return ReceiptValidationResult(
        status: ReceiptValidationStatus.error,
        message: 'Validation exception: $e',
      );
    }
  }

  Uri? _buildUri() {
    try {
      final normalizedBase =
          _baseUrl.endsWith('/') ? _baseUrl.substring(0, _baseUrl.length - 1) : _baseUrl;
      final normalizedPath = _validatePath.startsWith('/') ? _validatePath : '/$_validatePath';
      return Uri.parse('$normalizedBase$normalizedPath');
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _buildPayload({
    required PurchaseDetails purchaseDetails,
    SubscriptionTier? expectedTier,
  }) {
    final verification = purchaseDetails.verificationData;

    return <String, dynamic>{
      'platform': Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'unknown',
      'productId': purchaseDetails.productID,
      'purchaseId': purchaseDetails.purchaseID,
      'status': purchaseDetails.status.name,
      'transactionDate': purchaseDetails.transactionDate,
      'expectedTier': expectedTier?.name,
      'verificationData': <String, dynamic>{
        'source': verification.source,
        'localVerificationData': verification.localVerificationData,
        'serverVerificationData': verification.serverVerificationData,
      },
    };
  }

  ReceiptValidationResult _parseValidationResponse(Map<String, dynamic> body) {
    final bool isValid =
        body['valid'] == true || body['isValid'] == true || body['ok'] == true;
    final String message = (body['message'] ?? 'No message').toString();

    if (!isValid) {
      return ReceiptValidationResult(
        status: ReceiptValidationStatus.invalid,
        message: message,
      );
    }

    final SubscriptionTier? tier = _parseTier(body['tier']?.toString());
    final DateTime? expiryDateUtc =
        _parseExpiryDate(body['expiryDateUtc'] ?? body['expiresAt'] ?? body['expiryDate']);

    return ReceiptValidationResult(
      status: ReceiptValidationStatus.valid,
      message: message,
      tier: tier,
      expiryDateUtc: expiryDateUtc,
    );
  }

  SubscriptionTier? _parseTier(String? value) {
    if (value == null || value.isEmpty) return null;
    switch (value.trim().toLowerCase()) {
      case 'premium':
        return SubscriptionTier.premium;
      case 'premium_plus':
      case 'premiumplus':
      case 'premium-plus':
        return SubscriptionTier.premiumPlus;
      case 'free':
        return SubscriptionTier.free;
      default:
        return null;
    }
  }

  DateTime? _parseExpiryDate(dynamic raw) {
    if (raw == null) return null;
    try {
      if (raw is int) {
        return DateTime.fromMillisecondsSinceEpoch(raw, isUtc: true);
      }
      if (raw is String && raw.trim().isNotEmpty) {
        return DateTime.parse(raw).toUtc();
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
