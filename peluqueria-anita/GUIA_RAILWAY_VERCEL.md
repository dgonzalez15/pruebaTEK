# 🚀 GUÍA COMPLETA: Desplegar en Railway + Vercel (MySQL)

## 📋 Lo que vamos a desplegar:
- ✅ Backend Laravel (PHP) con MySQL → **Railway.app** (GRATIS)
- ✅ Base de datos MySQL → **Railway.app** (GRATIS)
- ✅ Frontend Flutter Web → **Vercel** (GRATIS)

---

## 🎯 PASO 1: Crear cuenta en Railway

1. Ve a [railway.app](https://railway.app)
2. Haz clic en **"Start a New Project"**
3. Inicia sesión con **GitHub** (recomendado)
4. Verifica tu email
5. Te dan **$5 de crédito gratis** mensualmente (500 horas)

---

## 🗄️ PASO 2: Crear Base de Datos MySQL en Railway

1. En Railway Dashboard, haz clic en **"+ New Project"**
2. Selecciona **"Provision MySQL"**
3. Espera a que se cree (toma ~30 segundos)
4. Haz clic en el servicio **MySQL** creado
5. Ve a la pestaña **"Variables"**
6. Copia estas variables (las necesitarás):
   - `MYSQLHOST`
   - `MYSQLPORT`
   - `MYSQLDATABASE`
   - `MYSQLUSER`
   - `MYSQLPASSWORD`

---

## 🖥️ PASO 3: Desplegar Backend Laravel en Railway

### A. Agregar el Backend al mismo proyecto

1. En el mismo proyecto de Railway, haz clic en **"+ New"**
2. Selecciona **"GitHub Repo"**
3. Busca y selecciona tu repositorio: **`pruebaTEK`**
4. Railway detectará automáticamente que es Laravel/PHP

### B. Configurar Root Directory

1. Haz clic en el servicio de tu backend
2. Ve a **"Settings"**
3. En **"Root Directory"**, escribe: `peluqueria-anita/backend-api`
4. Guarda los cambios

### C. Configurar Variables de Entorno

1. Ve a la pestaña **"Variables"**
2. Haz clic en **"+ New Variable"** y agrega cada una:

```env
APP_NAME=Peluquería Anita
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:Ld+T3YJJUo1eqo8x4ihiGFH5VCHP3RS50qZKCEeejdY=

# Base de datos - Copia estos valores del servicio MySQL que creaste
DB_CONNECTION=mysql
DB_HOST=${{MySQL.MYSQLHOST}}
DB_PORT=${{MySQL.MYSQLPORT}}
DB_DATABASE=${{MySQL.MYSQLDATABASE}}
DB_USERNAME=${{MySQL.MYSQLUSER}}
DB_PASSWORD=${{MySQL.MYSQLPASSWORD}}

SESSION_DRIVER=file
QUEUE_CONNECTION=sync
LOG_CHANNEL=stack
LOG_LEVEL=info
```

**IMPORTANTE:** Railway te permite referenciar variables de otros servicios usando `${{NombreServicio.VARIABLE}}`

### D. Configurar el comando de inicio

1. Ve a **"Settings"**
2. Busca **"Custom Start Command"**
3. Déjalo vacío (Railway usará el de `railway.json` automáticamente)

### E. Desplegar

1. Haz clic en **"Deploy"**
2. Espera a que el deploy termine (5-10 minutos la primera vez)
3. Cuando veas **"Success"**, tu backend está listo
4. Ve a **"Settings"** → **"Networking"** → **"Generate Domain"**
5. Copia la URL generada (ejemplo: `https://tu-proyecto.up.railway.app`)

---

## 🎨 PASO 4: Actualizar Frontend con URL del Backend

Antes de desplegar el frontend, actualiza la URL de la API:

```bash
cd /Users/dgonzalez15/Desktop/DG/prueba/peluqueria-anita/mobile-flutter
```

Abre `lib/utils/constants.dart` y actualiza:

```dart
static String get baseUrl {
  if (kIsWeb) {
    final currentUrl = Uri.base.toString();
    if (currentUrl.contains('localhost') || currentUrl.contains('127.0.0.1')) {
      return 'http://localhost:8001/api';
    }
    // ⬇️ CAMBIA ESTA URL POR LA DE TU BACKEND EN RAILWAY
    return 'https://tu-proyecto.up.railway.app/api';
  }
  // ... resto del código
}
```

Guarda y haz commit:

```bash
git add .
git commit -m "Actualizar URL del backend para Railway"
git push
```

---

## 🌐 PASO 5: Desplegar Frontend en Vercel

### A. Crear cuenta en Vercel

1. Ve a [vercel.com](https://vercel.com)
2. Haz clic en **"Sign Up"**
3. Inicia sesión con **GitHub**

### B. Importar proyecto

1. En Vercel Dashboard, haz clic en **"Add New..."** → **"Project"**
2. Busca y selecciona tu repositorio: **`pruebaTEK`**
3. Haz clic en **"Import"**

### C. Configurar el proyecto

**Framework Preset:** Other

**Root Directory:** 
- Haz clic en **"Edit"**
- Selecciona: `peluqueria-anita/mobile-flutter`

**Build Command:**
```bash
if ! command -v flutter &> /dev/null; then git clone https://github.com/flutter/flutter.git -b stable --depth 1 && export PATH="$PATH:`pwd`/flutter/bin"; fi && flutter doctor && flutter pub get && flutter build web --release --web-renderer html
```

**Output Directory:**
```
build/web
```

**Install Command:**
```bash
echo "Flutter will be installed in build command"
```

### D. Desplegar

1. Haz clic en **"Deploy"**
2. Espera 10-15 minutos (la primera vez tarda porque instala Flutter)
3. Cuando termine, tendrás una URL como: `https://prueba-tek.vercel.app`

---

## ✅ PASO 6: Crear Usuarios en la Base de Datos

### Opción 1: Usando Railway CLI (Recomendado)

1. Instala Railway CLI:
   ```bash
   npm install -g @railway/cli
   ```

2. Inicia sesión:
   ```bash
   railway login
   ```

3. Vincula tu proyecto:
   ```bash
   cd /Users/dgonzalez15/Desktop/DG/prueba/peluqueria-anita/backend-api
   railway link
   ```

4. Ejecuta tinker:
   ```bash
   railway run php artisan tinker
   ```

5. Crea usuarios:
   ```php
   \App\Models\User::create([
       'name' => 'Anita',
       'email' => 'anita@peluqueria.com',
       'password' => bcrypt('password123'),
       'role' => 'admin'
   ]);
   
   \App\Models\User::create([
       'name' => 'Cliente Demo',
       'email' => 'cliente@test.com',
       'password' => bcrypt('password123'),
       'role' => 'client'
   ]);
   
   exit
   ```

### Opción 2: Importar tu base de datos local

1. Exporta tu base de datos local:
   ```bash
   mysqldump -u root -p peluqueria_anita > backup.sql
   ```

2. Importa a Railway:
   ```bash
   railway run mysql -h $MYSQLHOST -P $MYSQLPORT -u $MYSQLUSER -p$MYSQLPASSWORD $MYSQLDATABASE < backup.sql
   ```

---

## 🎉 ¡LISTO! Tu aplicación está en producción

### URLs finales:
- **Frontend**: `https://prueba-tek.vercel.app`
- **Backend API**: `https://tu-proyecto.up.railway.app/api`
- **Base de datos**: MySQL en Railway

---

## 💰 Costos (Plan Gratuito)

### Railway:
- ✅ **$5 de crédito gratis mensual** (equivalente a ~500 horas)
- ✅ Backend + MySQL incluidos
- ⚠️ Se "duerme" después de inactividad (tarda ~10 seg en despertar)

### Vercel:
- ✅ **Completamente gratis** para proyectos personales
- ✅ Deploy ilimitado
- ✅ 100 GB de ancho de banda/mes
- ✅ No se duerme

**Total: $0** (mientras no excedas las 500 horas de Railway)

---

## 🔧 Comandos Útiles

### Ver logs del backend (Railway):
```bash
railway logs
```

### Ejecutar comandos en Railway:
```bash
railway run php artisan migrate
railway run php artisan db:seed
railway run php artisan cache:clear
```

### Redesplegar Vercel:
```bash
vercel --prod
```

---

## 🆘 Solución de Problemas

### Backend no se conecta a MySQL
1. Verifica que las variables de entorno estén correctas
2. Asegúrate de usar `${{MySQL.VARIABLE}}` para referenciar el MySQL
3. Revisa los logs: `railway logs`

### Error CORS en producción
Agrega en `backend-api/config/cors.php`:
```php
'allowed_origins' => [
    'https://prueba-tek.vercel.app',
    'https://*.vercel.app', // Para preview deployments
],
```

### Frontend no carga
1. Verifica que la URL del backend en `constants.dart` sea correcta
2. Revisa los logs del build en Vercel
3. Asegúrate que el Root Directory sea correcto

### Railway se queda sin crédito
- Reduce el número de servicios
- Optimiza el uso (Railway cobra por tiempo activo)
- Considera el plan hobby ($5/mes para más horas)

---

## 📱 Apps Móviles (iOS/Android)

Las apps nativas NO se despliegan en la web. Para distribuirlas:

### iOS:
```bash
flutter build ipa --release
```
Sube a **App Store** (requiere cuenta de $99/año)

### Android:
```bash
flutter build apk --release
```
Sube a **Google Play Store** (pago único de $25)

### Alternativa para pruebas:
- **Firebase App Distribution** (GRATIS para testing beta)
- **TestFlight** (GRATIS para iOS beta testing)

---

## 🔄 Actualizar la Aplicación

Cada vez que hagas cambios:

```bash
cd /Users/dgonzalez15/Desktop/DG/prueba

# Hacer cambios en tu código...

# Commit y push
git add .
git commit -m "Descripción de los cambios"
git push

# Railway y Vercel se redesplegarán automáticamente
```

---

## ✅ CHECKLIST FINAL

Backend (Railway):
- [ ] Proyecto creado en Railway
- [ ] MySQL provisionado
- [ ] Backend desplegado desde GitHub
- [ ] Root Directory: `peluqueria-anita/backend-api`
- [ ] Variables de entorno configuradas
- [ ] APP_KEY configurada
- [ ] Variables MySQL referenciadas con `${{MySQL.VARIABLE}}`
- [ ] Deploy exitoso
- [ ] Domain generado

Frontend (Vercel):
- [ ] Proyecto importado en Vercel
- [ ] Root Directory: `peluqueria-anita/mobile-flutter`
- [ ] Build Command configurado
- [ ] Output Directory: `build/web`
- [ ] URL del backend actualizada en código
- [ ] Deploy exitoso

Base de Datos:
- [ ] Migraciones ejecutadas
- [ ] Usuarios creados
- [ ] Datos de prueba (opcional)

Pruebas:
- [ ] Frontend carga correctamente
- [ ] Login funciona
- [ ] APIs responden
- [ ] CORS configurado correctamente

---

Desarrollado por **Diego González (DG)** 🚀
