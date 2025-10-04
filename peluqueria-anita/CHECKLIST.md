# ✅ CHECKLIST RÁPIDO - Despliegue en Railway + Vercel

## Antes de empezar:
- [x] Código en GitHub: https://github.com/dgonzalez15/pruebaTEK.git
- [ ] Cuenta en Railway.app
- [ ] Cuenta en Vercel.com

## Railway (Backend + MySQL):
- [ ] Proyecto creado en Railway
- [ ] MySQL provisionado
- [ ] Backend conectado desde GitHub
- [ ] Root Directory: `peluqueria-anita/backend-api`
- [ ] Variables de entorno configuradas:
  - [ ] APP_KEY: `base64:Ld+T3YJJUo1eqo8x4ihiGFH5VCHP3RS50qZKCEeejdY=`
  - [ ] DB_CONNECTION=mysql
  - [ ] DB_HOST=${{MySQL.MYSQLHOST}}
  - [ ] DB_PORT=${{MySQL.MYSQLPORT}}
  - [ ] DB_DATABASE=${{MySQL.MYSQLDATABASE}}
  - [ ] DB_USERNAME=${{MySQL.MYSQLUSER}}
  - [ ] DB_PASSWORD=${{MySQL.MYSQLPASSWORD}}
- [ ] Deploy exitoso
- [ ] Domain generado

## Vercel (Frontend):
- [ ] Proyecto importado desde GitHub
- [ ] Root Directory: `peluqueria-anita/mobile-flutter`
- [ ] Build Command configurado
- [ ] Output Directory: `build/web`
- [ ] Deploy exitoso

## Configuración del Frontend:
- [ ] URL del backend actualizada en `lib/utils/constants.dart`
- [ ] Cambios pusheados a GitHub
- [ ] Vercel redespliegado automáticamente

## Base de Datos:
- [ ] Migraciones ejecutadas (Railway hace esto automáticamente)
- [ ] Usuarios creados con `railway run php artisan tinker`

## Pruebas Finales:
- [ ] Frontend carga correctamente
- [ ] Se puede hacer login
- [ ] Las APIs responden
- [ ] Crear cita funciona
- [ ] Ver citas funciona

## URLs Finales:
- Frontend (Vercel): ___________________________
- Backend (Railway): ___________________________

---

## Comandos rápidos:

### Generar APP_KEY:
```bash
php artisan key:generate --show
```

### Crear usuario en producción:
```php
\App\Models\User::create([
    'name' => 'Admin',
    'email' => 'admin@test.com',
    'password' => bcrypt('password123'),
    'role' => 'admin'
]);
```

### Si algo falla:
1. Revisa los logs en Render
2. Verifica las variables de entorno
3. Ejecuta migraciones manualmente desde Shell

---

¡Buena suerte! 🚀
