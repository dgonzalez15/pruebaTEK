-- ====================================================
-- SCRIPT DE CREACIÓN DE BASE DE DATOS
-- Peluquería Anita - Sistema de Gestión de Citas
-- ====================================================

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS peluqueria_anita 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE peluqueria_anita;

-- ====================================================
-- TABLA: users (Usuarios del sistema)
-- ====================================================
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'stylist', 'client') DEFAULT 'client',
    phone VARCHAR(20),
    avatar VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    remember_token VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ====================================================
-- TABLA: clients (Clientes de la peluquería)
-- ====================================================
CREATE TABLE clients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    birth_date DATE,
    gender ENUM('male', 'female', 'other'),
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ====================================================
-- TABLA: services (Servicios ofrecidos)
-- ====================================================
CREATE TABLE services (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    duration INT NOT NULL COMMENT 'Duración en minutos',
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ====================================================
-- TABLA: appointments (Citas - Cabecera)
-- ====================================================
CREATE TABLE appointments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    user_id INT NOT NULL COMMENT 'Estilista asignado',
    appointment_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status ENUM('pending', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show') DEFAULT 'pending',
    total_amount DECIMAL(10,2) DEFAULT 0.00,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Claves foráneas
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Restricciones
    CONSTRAINT chk_appointment_time CHECK (start_time < end_time),
    CONSTRAINT chk_appointment_date CHECK (appointment_date >= CURDATE())
);

-- ====================================================
-- TABLA: appointment_details (Detalles de citas)
-- ====================================================
CREATE TABLE appointment_details (
    id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT NOT NULL,
    service_id INT NOT NULL,
    quantity INT DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) AS (quantity * unit_price) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Claves foráneas
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
);

-- ====================================================
-- TABLA: payments (Pagos)
-- ====================================================
CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('cash', 'card', 'transfer', 'digital') NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'completed',
    transaction_id VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Clave foránea
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE
);

-- ====================================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- ====================================================

-- Índices para búsquedas frecuentes
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_client ON appointments(client_id);
CREATE INDEX idx_appointments_stylist ON appointments(user_id);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_clients_phone ON clients(phone);
CREATE INDEX idx_clients_email ON clients(email);
CREATE INDEX idx_services_category ON services(category);
CREATE INDEX idx_services_active ON services(is_active);

-- Índice compuesto para evitar solapamientos de citas
CREATE UNIQUE INDEX idx_no_overlap ON appointments(user_id, appointment_date, start_time, end_time);

-- ====================================================
-- TRIGGERS
-- ====================================================

-- Trigger para actualizar el total de la cita cuando se agregan/modifican detalles
DELIMITER //
CREATE TRIGGER trg_update_appointment_total_insert
    AFTER INSERT ON appointment_details
    FOR EACH ROW
BEGIN
    UPDATE appointments 
    SET total_amount = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM appointment_details 
        WHERE appointment_id = NEW.appointment_id
    )
    WHERE id = NEW.appointment_id;
END//

CREATE TRIGGER trg_update_appointment_total_update
    AFTER UPDATE ON appointment_details
    FOR EACH ROW
BEGIN
    UPDATE appointments 
    SET total_amount = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM appointment_details 
        WHERE appointment_id = NEW.appointment_id
    )
    WHERE id = NEW.appointment_id;
END//

CREATE TRIGGER trg_update_appointment_total_delete
    AFTER DELETE ON appointment_details
    FOR EACH ROW
BEGIN
    UPDATE appointments 
    SET total_amount = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM appointment_details 
        WHERE appointment_id = OLD.appointment_id
    )
    WHERE id = OLD.appointment_id;
END//
DELIMITER ;

-- ====================================================
-- VISTAS ÚTILES
-- ====================================================

-- Vista para citas con información completa
CREATE VIEW v_appointments_complete AS
SELECT 
    a.id,
    a.appointment_date,
    a.start_time,
    a.end_time,
    a.status,
    a.total_amount,
    c.name as client_name,
    c.phone as client_phone,
    u.name as stylist_name,
    GROUP_CONCAT(s.name SEPARATOR ', ') as services
FROM appointments a
INNER JOIN clients c ON a.client_id = c.id
INNER JOIN users u ON a.user_id = u.id
LEFT JOIN appointment_details ad ON a.id = ad.appointment_id
LEFT JOIN services s ON ad.service_id = s.id
GROUP BY a.id, a.appointment_date, a.start_time, a.end_time, a.status, a.total_amount, c.name, c.phone, u.name;

-- Vista para estadísticas diarias
CREATE VIEW v_daily_stats AS
SELECT 
    appointment_date,
    COUNT(*) as total_appointments,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_appointments,
    SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled_appointments,
    SUM(CASE WHEN status = 'completed' THEN total_amount ELSE 0 END) as daily_revenue
FROM appointments
GROUP BY appointment_date
ORDER BY appointment_date DESC;

-- ====================================================
-- DATOS DE PRUEBA
-- ====================================================

-- Insertar usuarios iniciales
INSERT INTO users (name, email, password, role, phone) VALUES
('Anita Pérez', 'anita@peluqueria.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', '555-0001'),
('María González', 'maria@peluqueria.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'stylist', '555-0002'),
('Carlos Ruiz', 'carlos@peluqueria.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'stylist', '555-0003');

-- Insertar clientes de prueba
INSERT INTO clients (name, email, phone, address, birth_date, gender) VALUES
('Laura Martín', 'laura@email.com', '555-1001', 'Calle Principal 123', '1990-05-15', 'female'),
('Pedro Sánchez', 'pedro@email.com', '555-1002', 'Avenida Central 456', '1985-08-22', 'male'),
('Ana Torres', 'ana@email.com', '555-1003', 'Plaza Mayor 789', '1992-12-10', 'female');

-- Insertar servicios
INSERT INTO services (name, description, duration, price, category) VALUES
('Corte de Cabello Mujer', 'Corte y peinado para dama', 45, 25.00, 'Cortes'),
('Corte de Cabello Hombre', 'Corte masculino', 30, 15.00, 'Cortes'),
('Tinte Completo', 'Coloración completa del cabello', 120, 60.00, 'Coloración'),
('Mechas', 'Mechas de colores', 90, 45.00, 'Coloración'),
('Peinado de Fiesta', 'Peinado para eventos especiales', 60, 35.00, 'Peinados'),
('Tratamiento Capilar', 'Hidratación profunda', 45, 30.00, 'Tratamientos'),
('Manicure', 'Cuidado de uñas', 30, 20.00, 'Estética'),
('Pedicure', 'Cuidado de pies', 45, 25.00, 'Estética');

-- La base de datos está lista para usar
SELECT 'Base de datos creada exitosamente!' as Status;