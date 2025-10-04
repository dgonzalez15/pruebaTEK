# ✅ CHECKLIST RÁPIDO - Despliegue en Render

## Antes de empezar:
- [ ] Tienes cuenta en GitHub
- [ ] Tienes cuenta en Render.com

## Backend:
- [ ] Código subido a GitHub
- [ ] Base de datos MySQL creada en Render
- [ ] Backend desplegado en Render
- [ ] Variables de entorno configuradas
- [ ] APP_KEY generada
- [ ] Credenciales de BD configuradas
- [ ] Servicio en estado "Live" (verde)

## Frontend:
- [ ] URL del backend actualizada en `constants.dart`
- [ ] Código subido a GitHub con los cambios
- [ ] Frontend desplegado como Static Site
- [ ] Build completado exitosamente

## Pruebas:
- [ ] Frontend carga correctamente
- [ ] Se puede hacer login
- [ ] Las APIs responden

## URLs:
- Frontend: ___________________________
- Backend: ____________________________

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
