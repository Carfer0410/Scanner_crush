# Purchase Validation API Contract

Este documento define el endpoint que la app espera para validar compras/restores.

## Endpoint

- Method: `POST`
- Path por defecto: `/api/v1/purchases/validate`
- Base URL: se inyecta con `--dart-define=PURCHASE_VALIDATION_BASE_URL=...`
- Header opcional: `x-api-key` (si se define `PURCHASE_VALIDATION_API_KEY`)

## Request JSON

```json
{
  "platform": "android",
  "productId": "premium_monthly",
  "purchaseId": "GPA.1234-5678-9012-34567",
  "status": "purchased",
  "transactionDate": "1739902486045",
  "expectedTier": "premium",
  "verificationData": {
    "source": "google_play",
    "localVerificationData": "...",
    "serverVerificationData": "..."
  }
}
```

## Response JSON (válida)

```json
{
  "valid": true,
  "message": "Receipt validated",
  "tier": "premium",
  "expiryDateUtc": "2026-03-25T00:00:00Z"
}
```

Campos soportados por la app:
- `valid` (bool) o `isValid` (bool) o `ok` (bool)
- `message` (string)
- `tier` (`free`, `premium`, `premium_plus`, `premiumplus`, `premium-plus`)
- `expiryDateUtc` (ISO-8601) o `expiresAt` (ISO-8601/ms epoch) o `expiryDate` (ISO-8601/ms epoch)

## Response JSON (inválida)

```json
{
  "valid": false,
  "message": "Invalid or expired receipt"
}
```

## Notas de seguridad

- En `release`, por defecto la app exige validación backend (`REQUIRE_SERVER_PURCHASE_VALIDATION=true`).
- Si no configuras backend en `release`, la compra no otorga premium.
- En desarrollo puedes trabajar sin backend y la app hará fallback local.
