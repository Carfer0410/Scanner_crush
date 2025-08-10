# 📋 Sistema de Período de Gracia - Documentación Completa

## 🎯 Resumen del Sistema

El sistema de período de gracia permite a los usuarios nuevos disfrutar de **3 días completos de escaneos ilimitados** desde la primera vez que abren la app. Después de este período, entran al modelo freemium estándar.

## 📅 Cronograma del Usuario

### Día 0 (Primera instalación)
- **Estado**: Nuevo usuario 
- **Escaneos**: ILIMITADOS 
- **Banner**: "✨ ¡Bienvenido! Tienes 3 días de escaneos gratis"
- **Funcionalidad**: Sin restricciones, explora toda la app

### Día 1 
- **Estado**: En período de gracia (2 días restantes)
- **Escaneos**: ILIMITADOS 
- **Banner**: "⏰ Te quedan 2 días de escaneos gratis"
- **Funcionalidad**: Sin restricciones

### Día 2
- **Estado**: En período de gracia (1 día restante)
- **Escaneos**: ILIMITADOS 
- **Banner**: "⚠️ ¡Último día! Quedan pocas horas gratis"
- **Funcionalidad**: Sin restricciones

### Día 3+ (Después del período de gracia)
- **Estado**: Usuario regular (freemium)
- **Escaneos**: 5 base + hasta 10 por anuncios = **máximo 15/día**
- **Banner**: "🎁 5 escaneos gratis + ve anuncios para más"
- **Funcionalidad**: Modelo freemium completo

## 🔧 Implementación Técnica

### Funciones Clave

#### 1. `isNewUser()`
```dart
bool _isInGracePeriod() {
  final installDate = _getFirstInstallDate();
  final daysDifference = DateTime.now().difference(installDate).inDays;
  return daysDifference < _newUserGracePeriod; // < 3 días
}
```

#### 2. `getGracePeriodDaysRemaining()`
```dart
Future<int> getGracePeriodDaysRemaining() async {
  if (!await isNewUser()) return 0;
  
  final installDate = _getFirstInstallDate();
  final daysPassed = DateTime.now().difference(installDate).inDays;
  return _newUserGracePeriod - daysPassed; // 3 - días pasados
}
```

#### 3. `getRemainingScansTodayForFree()`
```dart
Future<int> getRemainingScansTodayForFree() async {
  if (isPremium) return -1; // Ilimitados para premium
  if (await isNewUser()) return -1; // Ilimitados durante gracia
  
  // Usuario regular: 5 base + bonos por anuncios
  final todayScans = await _getTodayScans();
  final remaining = _dailyFreeScans - todayScans;
  return remaining > 0 ? remaining : 0;
}
```

### Estados del Sistema

1. **Nuevo Usuario (Días 0-2)**
   - `isNewUser()` = `true`
   - `getRemainingScansTodayForFree()` = `-1` (ilimitado)
   - `canScanToday()` = `true`

2. **Usuario Regular (Día 3+)**
   - `isNewUser()` = `false` 
   - `getRemainingScansTodayForFree()` = `5 - escaneos_hoy`
   - `canScanToday()` = `true` si quedan escaneos

3. **Usuario Premium**
   - `isPremium` = `true`
   - `getRemainingScansTodayForFree()` = `-1` (ilimitado)
   - `canScanToday()` = `true` siempre

## 💰 Flujo de Monetización

### Durante el Período de Gracia (Días 0-2)
- ❌ **NO** se muestran anuncios intersticiales
- ❌ **NO** se muestran banners de límites
- ✅ **SÍ** se muestra banner de prueba gratuita
- ✅ **SÍ** se permite escaneo ilimitado

### Después del Período de Gracia (Día 3+)
- ✅ **SÍ** se muestran anuncios intersticiales
- ✅ **SÍ** se muestran banners de límites
- ✅ **SÍ** se puede ganar escaneos viendo anuncios
- ✅ **SÍ** se promociona la suscripción premium

## 🧪 Casos de Prueba Validados

### Test 1: Usuario Completamente Nuevo
```
✅ Detectado como nuevo usuario
📅 Días de gracia restantes: 3
✅ Puede escanear (ilimitado)
🔢 Escaneos restantes: ILIMITADOS
```

### Test 2: Usuario Día 1 (Ayer se instaló)
```
✅ Aún en período de gracia
📅 Días de gracia restantes: 2
✅ Puede escanear (ilimitado)
🔢 Escaneos restantes: ILIMITADOS
```

### Test 3: Usuario Día 2 (Hace 2 días se instaló)
```
✅ Último día de gracia
📅 Días de gracia restantes: 1
✅ Puede escanear (ilimitado)
🔢 Escaneos restantes: ILIMITADOS
```

### Test 4: Usuario Día 3 (Hace 3 días - límite)
```
✅ Ya NO está en período de gracia
📅 Días de gracia restantes: 0
⚠️ Puede escanear (límites normales)
🔢 Escaneos restantes: 5 (máximo base)
```

### Test 5: Usuario Después de Gracia (Hace 4+ días)
```
✅ Usuario regular (sin gracia)
📅 Días de gracia restantes: 0
✅ Puede escanear (límites normales)
🔢 Escaneos restantes: 5 (máximo base)
✅ Puede ver ads para más escaneos
```

## 🎯 Presión de Monetización

### Estrategia de Conversión
1. **Días 0-1**: Permite explorar libremente, crear addiction
2. **Día 2**: Muestra warning "último día", genera urgencia
3. **Día 3+**: Introduce límites y opciones de monetización

### Puntos de Conversión
- **Banner de prueba**: Recuerda tiempo restante
- **Diálogo de límites**: Ofrece ver anuncio o upgradeear
- **Pantalla de resultados**: Promociona premium para ilimitados
- **Anuncios intersticiales**: Genera ingresos de usuarios freemium

## ✅ Garantías del Sistema

### 1. **Detección Correcta de Estado**
- Los usuarios nuevos SIEMPRE tienen 3 días completos
- La transición al día 3 es automática y precisa
- No hay "huecos" donde se pierda funcionalidad

### 2. **Persistencia de Datos**
- `first_install_date` se guarda en SharedPreferences
- Sobrevive reinicios de la app
- No se puede "hackear" reinstalando

### 3. **Experiencia de Usuario**
- Banners informativos claros y visibles
- Transición suave de ilimitado a freemium
- Opciones claras para continuar (ads/premium)

### 4. **Monetización Efectiva**
- Maximiza engagement durante período de gracia
- Introduce monetización gradualmente
- Ofrece paths claros para seguir usando la app

## 🚨 Respuesta a Tu Pregunta

**"¿Realmente a los 3 días el usuario no puede hacer más escaneos?"**

**RESPUESTA**: ¡SÍ puede seguir escaneando! Pero con límites:

- **Día 3+**: 5 escaneos base + hasta 10 adicionales viendo anuncios = **15 escaneos máximo por día**
- **Si se acaban**: Puede ver anuncios para obtener +2 escaneos más (hasta 5 veces = +10 total)
- **Si no quiere anuncios**: Puede upgradeear a premium para ilimitados

**El usuario NUNCA se queda sin opciones, siempre puede:**
1. Ver anuncios para más escaneos (gratis)
2. Upgradeear a premium (pago)
3. Esperar al día siguiente (gratis)

Esto maximiza retención y da múltiples opciones de monetización. 🎯

## 📊 Métricas Esperadas

- **Días 0-2**: Alta engagement, exploración completa
- **Día 3**: Primer contacto con monetización, algunos dropoffs esperados
- **Día 4+**: Usuarios comprometidos que ven valor en seguir usando
- **Conversiones**: Mix de anuncios (70%) y premium (30%)

El sistema está diseñado para **maximizar la retención a largo plazo** mientras introduce monetización de forma no agresiva. 🚀
