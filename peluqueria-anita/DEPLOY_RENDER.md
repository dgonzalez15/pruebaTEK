# 🚀 GUÍA COMPLETA: Desplegar en Render.com con MySQL

## 📋 Lo que vamos a desplegar:
- ✅ Backend Laravel (PHP) con Docker
- ✅ Base de datos MySQL
- ✅ Frontend Flutter Web (sitio estático)

---

## 🎯 PASO 1: Crear cuenta en Render.com

1. Ve a [render.com](https://render.com)
2. Haz clic en **"Get Started"**
3. Registrate con **GitHub** (recomendado) o email
4. Verifica tu email si es necesario

---

## 🗂️ PASO 2: Subir tu código a GitHub

### A. Crear repositorio para el Backend

```bash
cd /Users/dgonzalez15/Desktop/DG/prueba/peluqueria-anita/backend-api

# Inicializar git (si no lo has hecho)
git init

# Agregar todos los archivos
git add .

# Hacer commit
git commit -m "Backend Laravel listo para deploy en Render"

# Crear repositorio en GitHub:
# 1. Ve a github.com
# 2. Click en "+" → "New repository"
# 3. Nombre: "peluqueria-anita-backend"
# 4. Público o Privado (como prefieras)
# 5. NO inicialices con README
# 6. Copia la URL que te da

# Conectar con GitHub (reemplaza con tu URL)
git remote add origin https://github.com/TU_USUARIO/peluqueria-anita-backend.git
git branch -M main
git push -u origin main
```

### B. Crear repositorio para el Frontend

```bash
cd /Users/dgonzalez15/Desktop/DG/prueba/peluqueria-anita/mobile-flutter

# Inicializar git
git init
git add .
git commit -m "Frontend Flutter Web listo para deploy"

# Crear otro repositorio en GitHub:
# Nombre: "peluqueria-anita-frontend"

# Conectar (reemplaza con tu URL)
git remote add origin https://github.com/TU_USUARIO/peluqueria-anita-frontend.git
git branch -M main
git push -u origin main
```

---

## 🗄️ PASO 3: Crear Base de Datos MySQL en Render

1. En Render Dashboard, haz clic en **"New +"**
2. Selecciona **"MySQL"**
3. Configuración:
   - **Name**: `peluqueria-db`
   - **Database**: `peluqueria_anita`
   - **User**: `peluqueria_user`
   - **Region**: Elige la más cercana a ti (Oregon US West)
   - **Plan**: **Free** (512 MB storage, suficiente para empezar)
4. Haz clic en **"Create Database"**
5. **IMPORTANTE**: Guarda estas credenciales (las necesitarás):
   - Internal Database URL
   - External Database URL
   - Hostname
   - Port
   - Database
   - Username
   - Password

---

## 🖥️ PASO 4: Desplegar Backend Laravel

1. En Render Dashboard, haz clic en **"New +"**
2. Selecciona **"Web Service"**
3. Haz clic en **"Build and deploy from a Git repository"**
4. Conecta tu cuenta de GitHub si aún no lo has hecho
5. Busca y selecciona el repo: **"peluqueria-anita-backend"**
6. Configuración:

   **Basic Settings:**
   - **Name**: `peluqueria-backend`
   - **Region**: Misma que la base de datos
   - **Branch**: `main`
   - **Root Directory**: dejar vacío
   - **Runtime**: **Docker**
   - **Plan**: **Free**

   **Advanced Settings (expandir):**
   
   Agrega estas **Environment Variables** (variables de entorno):

   ```
   APP_NAME=Peluquería Anita
   APP_ENV=production
   APP_DEBUG=false
   APP_URL=https://peluqueria-backend.onrender.com (lo verás después del deploy)
   
   # Genera esto ejecutando en local: php artisan key:generate --show
   APP_KEY=base64:TU_KEY_AQUI
   
   DB_CONNECTION=mysql
   DB_HOST=[copia de Render MySQL - Internal Hostname]
   DB_PORT=3306
   DB_DATABASE=peluqueria_anita
   DB_USERNAME=peluqueria_user
   DB_PASSWORD=[copia de Render MySQL - Password]
   
   SESSION_DRIVER=file
   QUEUE_CONNECTION=sync
   LOG_CHANNEL=stack
   LOG_LEVEL=info
   ```

7. Haz clic en **"Create Web Service"**
8. Render empezará a construir tu aplicación (toma 5-10 minutos la primera vez)
9. Espera a que el estado sea **"Live"** (círculo verde)
10. Copia la URL de tu backend (ejemplo: `https://peluqueria-backend.onrender.com`)

---

## 🎨 PASO 5: Actualizar Frontend con URL del Backend

Antes de desplegar el frontend, necesitas actualizar la URL de la API:

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
    // ⬇️ CAMBIA ESTA URL POR LA DE TU BACKEND EN RENDER
    return 'https://peluqueria-backend.onrender.com/api';
  }
  // ... resto del código
}
```

Guarda y haz commit:

```bash
git add .
git commit -m "Actualizar URL del backend para producción"
git push
```

---

## 🌐 PASO 6: Desplegar Frontend Flutter Web

1. En Render Dashboard, haz clic en **"New +"**
2. Selecciona **"Static Site"**
3. Conecta el repo: **"peluqueria-anita-frontend"**
4. Configuración:

   **Basic Settings:**
   - **Name**: `peluqueria-frontend`
   - **Branch**: `main`
   - **Build Command**: 
     ```bash
     chmod +x build_render.sh && ./build_render.sh
     ```
   - **Publish Directory**: `build/web`

5. Haz clic en **"Create Static Site"**
6. Espera a que se complete el build (5-10 minutos)
7. ¡Tu app estará lista! URL ejemplo: `https://peluqueria-frontend.onrender.com`

---

## ✅ PASO 7: Verificar que todo funciona

1. Abre tu frontend: `https://peluqueria-frontend.onrender.com`
2. Intenta hacer login con:
   - Email: `anita@peluqueria.com`
   - Password: `password123`
3. Si no existe el usuario, ve al Paso 8

---

## 👤 PASO 8: Crear usuarios en la base de datos

Render te permite ejecutar comandos en tu backend:

1. Ve a tu servicio **"peluqueria-backend"** en Render
2. Haz clic en **"Shell"** (en el menú izquierdo)
3. Ejecuta:

```bash
php artisan tinker
```

```php
// Crear usuario administrador
\App\Models\User::create([
    'name' => 'Anita',
    'email' => 'anita@peluqueria.com',
    'password' => bcrypt('password123'),
    'role' => 'admin'
]);

// Crear usuario cliente de prueba
\App\Models\User::create([
    'name' => 'Cliente Demo',
    'email' => 'cliente@test.com',
    'password' => bcrypt('password123'),
    'role' => 'client'
]);

exit
```

---

## 🎉 ¡LISTO! Tu aplicación está en producción

### URLs finales:
- **Frontend**: `https://peluqueria-frontend.onrender.com`
- **Backend API**: `https://peluqueria-backend.onrender.com/api`
- **Base de datos**: MySQL en Render (conectada automáticamente)

---

## ⚠️ IMPORTANTE: Limitaciones del plan gratuito

- ⏱️ Los servicios gratuitos se "duermen" después de **15 minutos de inactividad**
- 🕐 Tardan **~30 segundos en despertar** la primera vez que alguien accede
- 💾 Base de datos MySQL gratis: **512 MB** (suficiente para miles de registros)
- 🔄 Los servicios se reinician después de **15 días de inactividad**

---

## 🔧 Comandos útiles

### Ver logs del backend:
1. Ve a tu servicio en Render Dashboard
2. Click en **"Logs"**

### Ejecutar migraciones manualmente:
1. Ve a **"Shell"** en tu servicio backend
2. Ejecuta: `php artisan migrate --force`

### Limpiar cache:
```bash
php artisan config:clear
php artisan cache:clear
php artisan route:clear
```

---

## 🆘 Solución de problemas

### Error: "Connection refused" o "CORS"
- Verifica que la URL del backend en `constants.dart` sea correcta
- Asegúrate que termine en `/api`
- Revisa que `config/cors.php` tenga `'allowed_origins' => ['*']`

### Error 500 en el backend
- Revisa los logs en Render Dashboard
- Verifica que todas las variables de entorno estén configuradas
- Ejecuta migraciones: `php artisan migrate --force`

### Frontend no carga
- Verifica que el build se completó correctamente
- Revisa los logs del build
- Asegúrate que `Publish Directory` sea `build/web`

---

## 📱 Apps Móviles

Las apps nativas (iOS/Android) **NO se despliegan en Render**. Para distribuirlas:

- **iOS**: App Store (requiere cuenta de $99/año)
- **Android**: Google Play Store (pago único de $25)
- **Alternativa**: Firebase App Distribution (pruebas beta gratis)

---

Desarrollado por **Diego González (DG)** 🚀
