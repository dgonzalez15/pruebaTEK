# 🚀 Guía de Despliegue - Peluquería Anita

Esta guía te llevará paso a paso para desplegar tu aplicación completa (Frontend Flutter Web + Backend Laravel) en servicios gratuitos.

---

## 📋 Tabla de Contenidos

1. [Desplegar Backend Laravel en Railway](#1-desplegar-backend-laravel-en-railway)
2. [Desplegar Frontend Flutter Web en Vercel](#2-desplegar-frontend-flutter-web-en-vercel)
3. [Configurar Base de Datos](#3-configurar-base-de-datos)
4. [Apps Móviles](#4-apps-móviles)

---

## 1. Desplegar Backend Laravel en Railway

### ¿Por qué Railway?
- ✅ Gratis (500 horas/mes)
- ✅ Soporta PHP/Laravel
- ✅ Base de datos MySQL incluida
- ✅ Fácil de usar

### Pasos:

#### A. Crear cuenta en Railway
1. Ve a [railway.app](https://railway.app)
2. Haz clic en "Start a New Project"
3. Inicia sesión con GitHub

#### B. Preparar tu repositorio
1. Sube tu proyecto a GitHub (si no lo has hecho):
   ```bash
   cd /Users/dgonzalez15/Desktop/DG/prueba/peluqueria-anita/backend-api
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/TU_USUARIO/peluqueria-backend.git
   git push -u origin main
   ```

#### C. Desplegar en Railway
1. En Railway, haz clic en "Deploy from GitHub repo"
2. Selecciona tu repositorio `peluqueria-backend`
3. Railway detectará automáticamente que es Laravel
4. Agrega las variables de entorno:
   - `APP_KEY`: (genera con `php artisan key:generate --show`)
   - `APP_ENV`: `production`
   - `APP_DEBUG`: `false`
   - `DB_CONNECTION`: `mysql`
   - `DB_HOST`: (Railway te dará esto)
   - `DB_PORT`: `3306`
   - `DB_DATABASE`: (Railway te dará esto)
   - `DB_USERNAME`: (Railway te dará esto)
   - `DB_PASSWORD`: (Railway te dará esto)

5. Agrega MySQL:
   - En Railway, haz clic en "+ New"
   - Selecciona "Database" → "MySQL"
   - Conecta la base de datos con tu servicio Laravel

6. Ejecuta migraciones:
   - En Railway → Settings → Deploy → Custom Start Command:
     ```bash
     php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=$PORT
     ```

7. Copia la URL de tu API (ejemplo: `https://tu-proyecto.railway.app`)

---

## 2. Desplegar Frontend Flutter Web en Vercel

### A. Actualizar la URL del backend

1. Abre `lib/utils/constants.dart`
2. Cambia la URL de producción por la de Railway:
   ```dart
   const String productionUrl = String.fromEnvironment(
     'API_URL',
     defaultValue: 'https://tu-proyecto.railway.app/api', // ⬅️ Cambia esto
   );
   ```

### B. Construir Flutter Web

```bash
cd /Users/dgonzalez15/Desktop/DG/prueba/peluqueria-anita/mobile-flutter
flutter build web --release --web-renderer html
```

### C. Desplegar en Vercel

#### Opción 1: Desde la terminal (Recomendado)

1. Instala Vercel CLI:
   ```bash
   npm install -g vercel
   ```

2. Inicia sesión:
   ```bash
   vercel login
   ```

3. Despliega:
   ```bash
   cd /Users/dgonzalez15/Desktop/DG/prueba/peluqueria-anita/mobile-flutter
   vercel
   ```
   
4. Sigue las instrucciones:
   - Set up and deploy? **Y**
   - Which scope? Selecciona tu cuenta
   - Link to existing project? **N**
   - Project name? `peluqueria-anita-web`
   - In which directory is your code located? `./`
   - Want to override settings? **N**

5. Una vez desplegado, Vercel te dará una URL (ejemplo: `peluqueria-anita-web.vercel.app`)

#### Opción 2: Desde el Dashboard de Vercel

1. Ve a [vercel.com](https://vercel.com)
2. Haz clic en "Add New" → "Project"
3. Importa tu repositorio de GitHub
4. Configura:
   - **Framework Preset**: Other
   - **Build Command**: `flutter build web --release`
   - **Output Directory**: `build/web`
5. Haz clic en "Deploy"

---

## 3. Configurar Base de Datos

### A. Migrar la base de datos

Ya tienes los datos en local. Para llevarlos a Railway:

1. Exporta tu base de datos local:
   ```bash
   cd /Users/dgonzalez15/Desktop/DG/prueba/peluqueria-anita/backend-api
   php artisan db:seed --class=DatabaseSeeder
   ```
   O exporta manualmente:
   ```bash
   mysqldump -u root peluqueria_anita > backup.sql
   ```

2. Importa a Railway:
   - Descarga Railway CLI: `npm install -g railway`
   - Ejecuta: `railway login`
   - Vincula el proyecto: `railway link`
   - Importa: `railway run mysql < backup.sql`

### B. Crear usuarios de prueba

Si no tienes seeders, crea usuarios manualmente en Railway:
```bash
railway run php artisan tinker
```
```php
User::create([
    'name' => 'Anita',
    'email' => 'anita@peluqueria.com',
    'password' => bcrypt('password123'),
    'role' => 'admin'
]);
```

---

## 4. Apps Móviles

Las apps móviles NO se despliegan en la web. Debes:

### iOS (iPhone/iPad)
1. Genera el archivo IPA:
   ```bash
   flutter build ipa
   ```
2. Súbelo a App Store Connect (requiere cuenta de desarrollador Apple de $99/año)

### Android
1. Genera el APK:
   ```bash
   flutter build apk --release
   ```
2. Súbelo a Google Play Console (pago único de $25)

### O usa TestFlight / Firebase App Distribution para pruebas

---

## 📝 Checklist Final

- [ ] Backend Laravel desplegado en Railway
- [ ] Base de datos MySQL configurada
- [ ] Migraciones ejecutadas
- [ ] URL del backend copiada
- [ ] `constants.dart` actualizado con URL de producción
- [ ] Flutter Web construido (`flutter build web`)
- [ ] Frontend desplegado en Vercel
- [ ] Probado login desde Vercel
- [ ] Apps móviles generadas (opcional)

---

## 🆘 Troubleshooting

### Error CORS en producción
Agrega en `backend-api/config/cors.php`:
```php
'allowed_origins' => ['https://tu-app.vercel.app'],
```

### Error 500 en Railway
Revisa los logs en Railway Dashboard → Deployments → Logs

### App no conecta al backend
Verifica que la URL en `constants.dart` sea correcta y termine en `/api`

---

## 🎉 ¡Listo!

Tu aplicación ya está en producción:
- **Frontend**: `https://tu-app.vercel.app`
- **Backend**: `https://tu-proyecto.railway.app`

---

Desarrollado por **Diego González (DG)** 🚀
