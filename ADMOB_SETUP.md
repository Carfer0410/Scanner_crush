# 🎯 CONFIGURACIÓN DE ADMOB - SCANNER CRUSH

## 📱 **PASO 1: Crear cuenta en AdMob**

1. **Ir a**: https://admob.google.com/
2. **Crear cuenta** con tu Google Account
3. **Verificar** tu información fiscal y de pagos

## 🏗️ **PASO 2: Crear tu App en AdMob**

1. **Agregar App** → "Agregar una aplicación"
2. **IMPORTANTE: Seleccionar "No, la aplicación no está publicada en una tienda de aplicaciones"**
3. **Seleccionar plataforma**: Android (y iOS si planeas)
4. **Nombre de app**: "Scanner Crush"
5. **Categoría**: Lifestyle o Entertainment
6. **Configurar** la app en AdMob Console

## 🆔 **PASO 3: Obtener Application ID** ✅ COMPLETADO

### Android:
- En AdMob Console → Tu App → Configuración
- **Application ID**: `ca-app-pub-6436417991123423~5033668315` ✅

### iOS (si implementas):
- En AdMob Console → Tu App → Configuración  
- **Application ID**: `ca-app-pub-6436417991123423~5033668315` ✅

## 📺 **PASO 4: Crear Unidades de Anuncios** ✅ COMPLETADO

### 1. Banner Ads: ✅
- **Crear nueva unidad** → Banner
- **Nombre**: "Scanner Crush Banner"
- **ID**: `ca-app-pub-6436417991123423/1992572008` ✅

### 2. Interstitial Ads: ✅
- **Crear nueva unidad** → Intersticial
- **Nombre**: "Scanner Crush Interstitial"  
- **ID**: `ca-app-pub-6436417991123423/1801000311` ✅

### 3. Rewarded Ads: ✅
- **Crear nueva unidad** → Con recompensa
- **Nombre**: "Scanner Crush Rewarded"
- **ID**: `ca-app-pub-6436417991123423/1900222602` ✅

## ⚙️ **PASO 5: Actualizar código con IDs reales** ✅ COMPLETADO

### Archivo: `android/app/src/main/AndroidManifest.xml` ✅
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-6436417991123423~5033668315"/>
```

### Archivo: `ios/Runner/Info.plist` (para iOS)
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-6436417991123423~5033668315</string>
```

### Archivo: `lib/services/admob_service.dart` ✅
```dart
// IDs REALES implementados:
static const String _androidBannerAdUnitId = 'ca-app-pub-6436417991123423/1992572008';
static const String _androidInterstitialAdUnitId = 'ca-app-pub-6436417991123423/1801000311';
static const String _androidRewardedAdUnitId = 'ca-app-pub-6436417991123423/1900222602';
```

## 🧪 **PASO 6: Testing**

### Para testing (mantener Test IDs):
- Los Test IDs actuales funcionan para pruebas
- **NO** generan ingresos reales
- Útiles para desarrollo

### Para producción (usar IDs reales):
- **REEMPLAZAR** todos los Test IDs antes de publicar
- **VERIFICAR** que los anuncios cargan correctamente
- **PROBAR** en dispositivos reales

## 📊 **PASO 7: Analíticas y Optimización**

1. **Monitorear** rendimiento en AdMob Console
2. **Optimizar** ubicación de anuncios según datos
3. **A/B testing** de frecuencia de anuncios
4. **Ajustar** configuraciones según métricas

## ⚠️ **IMPORTANTE:**

- **NO necesitas publicar la app primero** - AdMob funciona antes de publicar
- **Selecciona "App no publicada"** cuando configures en AdMob Console
- **NUNCA** hacer clic en tus propios anuncios
- **USAR** Test IDs durante desarrollo
- **CAMBIAR** a IDs reales solo para producción
- **CUMPLIR** políticas de AdMob y Google Play

## 🚀 **Estado Actual:**

✅ AdMob SDK integrado
✅ IDs reales configurados 
✅ Anuncios conectados en la app
✅ **AndroidManifest.xml actualizado**
✅ **AdMobService actualizado con IDs reales**
🎯 **LISTO PARA GENERAR INGRESOS**

## 📞 **Soporte:**

- **AdMob Help**: https://support.google.com/admob/
- **Flutter Ads**: https://developers.google.com/admob/flutter/
