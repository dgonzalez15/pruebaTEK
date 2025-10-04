# 📊 Modelo de Base de Datos - Peluquería Anita

## Diagrama Entidad-Relación

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│      USERS      │     │     CLIENTS     │     │    SERVICES     │
├─────────────────┤     ├─────────────────┤     ├─────────────────┤
│ id (PK)         │     │ id (PK)         │     │ id (PK)         │
│ name            │     │ name            │     │ name            │
│ email           │     │ email           │     │ description     │
│ password        │     │ phone           │     │ duration        │
│ role            │     │ address         │     │ price           │
│ created_at      │     │ birth_date      │     │ active          │
│ updated_at      │     │ created_at      │     │ created_at      │
└─────────────────┘     │ updated_at      │     │ updated_at      │
                        └─────────────────┘     └─────────────────┘
                                 │                        │
                                 │                        │
                        ┌─────────────────┐               │
                        │  APPOINTMENTS   │               │
                        │   (CABECERA)    │               │
                        ├─────────────────┤               │
                        │ id (PK)         │               │
                        │ client_id (FK)  │───────────────┘
                        │ user_id (FK)    │────────┐
                        │ appointment_date│        │
                        │ start_time      │        │
                        │ end_time        │        │
                        │ status          │        │
                        │ total_amount    │        │
                        │ notes           │        │
                        │ created_at      │        │
                        │ updated_at      │        │
                        └─────────────────┘        │
                                 │                 │
                                 │                 │
                        ┌─────────────────┐        │
                        │APPOINTMENT_DTLS │        │
                        │   (DETALLE)     │        │
                        ├─────────────────┤        │
                        │ id (PK)         │        │
                        │ appointment_id  │────────┘
                        │ service_id (FK) │────────────────┐
                        │ quantity        │                │
                        │ unit_price      │                │
                        │ subtotal        │                │
                        │ created_at      │                │
                        │ updated_at      │                │
                        └─────────────────┘                │
                                                          │
                        ┌─────────────────┐                │
                        │    PAYMENTS     │                │
                        ├─────────────────┤                │
                        │ id (PK)         │                │
                        │ appointment_id  │────────────────┘
                        │ amount          │
                        │ payment_method  │
                        │ payment_date    │
                        │ status          │
                        │ created_at      │
                        │ updated_at      │
                        └─────────────────┘
```

## Relaciones

### 1:N (Uno a Muchos)
- **CLIENTS → APPOINTMENTS**: Un cliente puede tener múltiples citas
- **USERS → APPOINTMENTS**: Un usuario (estilista) puede atender múltiples citas
- **APPOINTMENTS → APPOINTMENT_DETAILS**: Una cita puede tener múltiples servicios
- **SERVICES → APPOINTMENT_DETAILS**: Un servicio puede estar en múltiples detalles
- **APPOINTMENTS → PAYMENTS**: Una cita puede tener múltiples pagos (abonos)

### Restricciones de Integridad
- Todas las claves foráneas deben referenciar registros existentes
- Las fechas de citas no pueden ser en el pasado (excepto para registros históricos)
- El total de la cita debe coincidir con la suma de los subtotales de los detalles
- Los horarios de citas no pueden solaparse para el mismo estilista

## Estados del Sistema

### Estados de Citas (appointments.status)
- `pending`: Pendiente de confirmación
- `confirmed`: Confirmada
- `in_progress`: En progreso
- `completed`: Completada
- `cancelled`: Cancelada
- `no_show`: Cliente no se presentó

### Roles de Usuario (users.role)
- `admin`: Administrador del sistema
- `stylist`: Estilista/Peluquero
- `client`: Cliente (solo para app móvil)

### Métodos de Pago (payments.payment_method)
- `cash`: Efectivo
- `card`: Tarjeta
- `transfer`: Transferencia
- `digital`: Pago digital (PayPal, etc.)

## Índices Recomendados

```sql
-- Optimización de consultas frecuentes
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_client ON appointments(client_id);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_clients_email ON clients(email);
CREATE INDEX idx_users_email ON users(email);
```

## Triggers y Procedimientos

### Trigger: Actualizar total de cita
```sql
DELIMITER //
CREATE TRIGGER update_appointment_total 
    AFTER INSERT ON appointment_details
    FOR EACH ROW
BEGIN
    UPDATE appointments 
    SET total_amount = (
        SELECT SUM(subtotal) 
        FROM appointment_details 
        WHERE appointment_id = NEW.appointment_id
    )
    WHERE id = NEW.appointment_id;
END//
DELIMITER ;
```