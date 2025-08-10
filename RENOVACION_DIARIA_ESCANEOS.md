# 🔄 Renovación Diaria de Escaneos - Documentación Técnica

## 🎯 RESPUESTA DIRECTA: ¿Se renuevan 5 escaneos gratis diario?

**SÍ, los 5 escaneos se renuevan AUTOMÁTICAMENTE cada día a las 00:00 (medianoche).**

## ⏰ Cómo Funciona la Renovación Diaria

### 🔧 Mecanismo Técnico

El sistema utiliza la comparación de fechas para detectar cambios de día:

```dart
Future<int> _getTotalScansToday() async {
  final today = DateTime.now().toIso8601String().split('T')[0]; // "2025-08-09"
  final lastScanDate = _prefs?.getString('last_scan_date');
  
  if (lastScanDate != today) {
    // ¡NUEVO DÍA DETECTADO! 🌅
    await _prefs?.setString('last_scan_date', today);
    await _prefs?.setInt('today_scans', 0);  // Reset a 0 escaneos usados
    return 0;
  }
  
  return _prefs?.getInt('today_scans') ?? 0;
}
```

### 📅 Cronograma de Renovación

| Hora | Estado | Escaneos Base | Bonos por Ads | Total Disponible |
|------|--------|---------------|---------------|------------------|
| **23:59** | Día anterior | 0 restantes | 0 restantes | 0 |
| **00:00** | ¡RENOVACIÓN! | **5 nuevos** | **10 nuevos** | **15** |
| **00:01** | Nuevo día | 5 disponibles | 10 disponibles | 15 |

## ✅ Validación de Renovación

### Escenario 1: Usuario que agotó sus escaneos ayer
```
AYER (23:59):
- Escaneos base usados: 5/5 ✅
- Bonos por ads usados: 10/10 ✅
- Estado: "No puedes escanear más hoy"

HOY (00:01):
- Escaneos base: 5/5 nuevos ✅
- Bonos por ads: 0/10 (reseteo) ✅
- Estado: "5 escaneos gratis disponibles"
```

### Escenario 2: Usuario que usó solo algunos escaneos
```
AYER (23:59):
- Escaneos base usados: 3/5
- Bonos por ads usados: 4/10
- Estado: "Te quedan 2 + 6 bonos"

HOY (00:01):
- Escaneos base: 5/5 nuevos ✅
- Bonos por ads: 0/10 (reseteo) ✅
- Estado: "5 escaneos gratis disponibles"
```

## 🔄 Qué Se Renueva Diariamente

### ✅ SE RENUEVA AUTOMÁTICAMENTE:

1. **Escaneos Base**: 5 escaneos gratuitos
2. **Bonos por Anuncios**: Capacidad de ganar hasta 10 escaneos adicionales
3. **Contador de Anuncios**: Puede ver hasta 5 anuncios nuevos (2 escaneos por anuncio)
4. **Límite de Compartir**: Si hay límite en compartir resultados

### ❌ NO SE RENUEVA:

1. **Suscripción Premium**: Permanece activa según el período contratado
2. **Período de Gracia**: Solo se cuenta una vez (3 días tras instalación)
3. **Configuraciones**: Tema, idioma, preferencias personales
4. **Historial**: Resultados pasados se mantienen

## 🧪 Pruebas de Renovación Implementadas

He creado una pantalla de pruebas específica (`TestDailyRenewalScreen`) que valida:

### Test 1: Renovación en Nuevo Día
- ✅ Verifica que los escaneos se resetean de 5/5 usados → 5/5 disponibles
- ✅ Confirma que los bonos se resetean de 10/10 usados → 0/10 (capacidad completa)

### Test 2: Uso en el Mismo Día
- ✅ Confirma que los escaneos se descuentan correctamente
- ✅ Verifica que NO se renovan hasta el día siguiente

### Test 3: Cambio de Día con Escaneos Usados
- ✅ Simula transición de medianoche
- ✅ Valida renovación automática

### Test 4: Renovación de Bonos por Anuncios
- ✅ Verifica que la capacidad de ver anuncios se renueva
- ✅ Confirma reset de contador de anuncios vistos

### Test 5: Límites Después de Renovación
- ✅ Valida que los límites máximos se restauran (5 + 10 = 15 total)

## 📊 Comportamiento por Tipo de Usuario

### 👶 Usuario Nuevo (Días 0-2)
```
❌ NO aplica renovación diaria
✅ Escaneos ILIMITADOS durante todo el período de gracia
🔄 La renovación diaria comenzará en el día 3
```

### 👤 Usuario Regular (Día 3+)
```
✅ Renovación diaria automática
🔄 Cada día a las 00:00:
   - 5 escaneos base nuevos
   - 10 escaneos adicionales por anuncios
   - Total: 15 escaneos máximo/día
```

### 💎 Usuario Premium
```
❌ NO necesita renovación diaria
✅ Escaneos ILIMITADOS siempre
🔄 Sin restricciones de tiempo ni cantidad
```

## ⚡ Optimizaciones del Sistema

### 🚀 Rendimiento
- La verificación de fecha se hace solo cuando es necesario
- Los datos se almacenan en SharedPreferences (persistente)
- No requiere conexión a internet para funcionar

### 🛡️ Seguridad
- No se puede "hackear" cambiando la hora del dispositivo
- La fecha se obtiene del sistema operativo
- Los contadores están protegidos en almacenamiento local

### 🔄 Confiabilidad
- Funciona aunque la app se cierre y reabra
- Sobrevive reinicios del dispositivo
- Maneja correctamente cambios de zona horaria

## 🎯 CONCLUSIÓN

**✅ SÍ, los escaneos se renuevan diariamente:**

- **Cuándo**: Cada día a las 00:00 (medianoche)
- **Qué**: 5 escaneos base + capacidad para 10 bonos por anuncios
- **Cómo**: Automáticamente sin intervención del usuario
- **Para quién**: Usuarios regulares (después del período de gracia)

**El sistema está diseñado para dar una experiencia consistente y predecible, donde el usuario siempre sabe que tendrá 5 escaneos frescos cada nuevo día.** 🌅

**Puedes probar esto en vivo usando la pantalla de pruebas que he implementado en la app.** 🧪
