#!/usr/bin/env zsh
set -e

echo "🔧 Setup de Base de Datos - Reportería DFS"
echo "=========================================="
echo ""

# Verificar PostgreSQL
PG_AVAILABLE=false
if command -v psql &> /dev/null; then
    if pg_isready -h 127.0.0.1 -p 5432 &> /dev/null || pg_isready &> /dev/null; then
        PG_AVAILABLE=true
        echo "✅ PostgreSQL detectado y corriendo"
    fi
fi

# Verificar MySQL
MYSQL_AVAILABLE=false
if command -v mysql &> /dev/null; then
    if mysqladmin ping -h 127.0.0.1 --silent 2>/dev/null; then
        MYSQL_AVAILABLE=true
        echo "✅ MySQL detectado y corriendo"
    fi
fi

echo ""

# Decidir qué usar
if [[ "$PG_AVAILABLE" == "true" ]] && [[ "$MYSQL_AVAILABLE" == "true" ]]; then
    echo "Ambas bases de datos disponibles:"
    echo "  1) PostgreSQL (recomendado)"
    echo "  2) MySQL"
    echo ""
    read "opcion?Elige una opción (1 o 2) [1]: "
    opcion=${opcion:-1}
    
    if [[ "$opcion" == "1" ]]; then
        USE_DB="postgresql"
    else
        USE_DB="mysql"
    fi
elif [[ "$PG_AVAILABLE" == "true" ]]; then
    USE_DB="postgresql"
    echo "📊 Usando PostgreSQL"
elif [[ "$MYSQL_AVAILABLE" == "true" ]]; then
    USE_DB="mysql"
    echo "📊 Usando MySQL"
else
    echo "❌ Error: No se detectó PostgreSQL ni MySQL"
    echo ""
    echo "Para instalar PostgreSQL:"
    echo "  macOS: brew install postgresql@14 && brew services start postgresql@14"
    echo "  Linux: sudo apt install postgresql postgresql-contrib"
    echo ""
    echo "Para instalar MySQL:"
    echo "  macOS: brew install mysql && brew services start mysql"
    echo "  Linux: sudo apt install mysql-server"
    exit 1
fi

echo ""

if [[ "$USE_DB" == "postgresql" ]]; then
    echo "📊 Configurando PostgreSQL..."
    
    # Pedir credenciales
    read "db_name?Nombre de la base de datos [reporteria_dfs]: "
    db_name=${db_name:-reporteria_dfs}
    
    read "db_user?Usuario PostgreSQL [postgres]: "
    db_user=${db_user:-postgres}
    
    read -s "db_pass?Password PostgreSQL (vacío si no tiene): "
    echo ""
    
    read "db_host?Host PostgreSQL [127.0.0.1]: "
    db_host=${db_host:-127.0.0.1}
    
    read "db_port?Puerto PostgreSQL [5432]: "
    db_port=${db_port:-5432}
    
    # Crear la base de datos si no existe
    echo "🔨 Creando base de datos '$db_name' si no existe..."
    if [[ -z "$db_pass" ]]; then
        psql -h "$db_host" -p "$db_port" -U "$db_user" -tc "SELECT 1 FROM pg_database WHERE datname = '$db_name'" | grep -q 1 || \
            psql -h "$db_host" -p "$db_port" -U "$db_user" -c "CREATE DATABASE $db_name ENCODING 'UTF8';" 2>/dev/null || {
            echo "⚠️  No se pudo crear la BD automáticamente. Créala manualmente:"
            echo "   psql -U $db_user"
            echo "   CREATE DATABASE $db_name ENCODING 'UTF8';"
        }
    else
        PGPASSWORD="$db_pass" psql -h "$db_host" -p "$db_port" -U "$db_user" -tc "SELECT 1 FROM pg_database WHERE datname = '$db_name'" | grep -q 1 || \
            PGPASSWORD="$db_pass" psql -h "$db_host" -p "$db_port" -U "$db_user" -c "CREATE DATABASE $db_name ENCODING 'UTF8';" 2>/dev/null || {
            echo "⚠️  No se pudo crear la BD automáticamente. Créala manualmente:"
            echo "   psql -U $db_user"
            echo "   CREATE DATABASE $db_name ENCODING 'UTF8';"
        }
    fi
    
    # Actualizar .env
    echo "📝 Actualizando .env para PostgreSQL..."
    sed -i.bak "s|^DB_CONNECTION=.*|DB_CONNECTION=pgsql|" .env
    sed -i.bak "s|^#*DB_HOST=.*|DB_HOST=$db_host|" .env
    sed -i.bak "s|^#*DB_PORT=.*|DB_PORT=$db_port|" .env
    sed -i.bak "s|^#*DB_DATABASE=.*|DB_DATABASE=$db_name|" .env
    sed -i.bak "s|^#*DB_USERNAME=.*|DB_USERNAME=$db_user|" .env
    sed -i.bak "s|^#*DB_PASSWORD=.*|DB_PASSWORD=$db_pass|" .env
    
    echo "✅ Configuración PostgreSQL aplicada"
    
else
    echo "📊 Configurando MySQL..."
    
    # Pedir credenciales
    read "db_name?Nombre de la base de datos [reporteria_dfs]: "
    db_name=${db_name:-reporteria_dfs}
    
    read "db_user?Usuario MySQL [root]: "
    db_user=${db_user:-root}
    
    read -s "db_pass?Password MySQL: "
    echo ""
    
    # Crear la base de datos si no existe
    echo "🔨 Creando base de datos '$db_name' si no existe..."
    mysql -h 127.0.0.1 -u "$db_user" -p"$db_pass" -e "CREATE DATABASE IF NOT EXISTS \`$db_name\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || {
        echo "⚠️  No se pudo crear la BD automáticamente. Créala manualmente:"
        echo "   mysql -u root -p"
        echo "   CREATE DATABASE $db_name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    }
    
    # Actualizar .env
    echo "📝 Actualizando .env para MySQL..."
    sed -i.bak 's|^DB_CONNECTION=.*|DB_CONNECTION=mysql|' .env
    sed -i.bak 's|^#*DB_HOST=.*|DB_HOST=127.0.0.1|' .env
    sed -i.bak 's|^#*DB_PORT=.*|DB_PORT=3306|' .env
    sed -i.bak "s|^#*DB_DATABASE=.*|DB_DATABASE=$db_name|" .env
    sed -i.bak "s|^#*DB_USERNAME=.*|DB_USERNAME=$db_user|" .env
    sed -i.bak "s|^#*DB_PASSWORD=.*|DB_PASSWORD=$db_pass|" .env
    
    echo "✅ Configuración MySQL aplicada"
fi

echo ""
echo "🔄 Ejecutando migraciones y seeders..."
php artisan migrate:fresh --seed

echo ""
echo "✅ ¡Base de datos configurada exitosamente!"
echo ""
echo "📋 Credenciales de prueba:"
echo "   Email: admin@dfs.com"
echo "   Password: password123"
echo ""
echo "🚀 Ahora ejecuta: cd ../.. && ./start-all.sh"
