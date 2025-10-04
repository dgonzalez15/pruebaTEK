<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Client;
use App\Models\Service;
use App\Models\Appointment;
use App\Models\AppointmentDetail;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Crear usuarios del sistema
        $admin = User::create([
            'name' => 'Anita Pérez',
            'email' => 'anita@peluqueria.com',
            'password' => Hash::make('password123'),
            'role' => 'admin',
            'phone' => '555-0001',
        ]);

        $stylist1 = User::create([
            'name' => 'María González',
            'email' => 'maria@peluqueria.com',
            'password' => Hash::make('password123'),
            'role' => 'stylist',
            'phone' => '555-0002',
        ]);

        $stylist2 = User::create([
            'name' => 'Carlos Ruiz',
            'email' => 'carlos@peluqueria.com',
            'password' => Hash::make('password123'),
            'role' => 'stylist',
            'phone' => '555-0003',
        ]);

        // Crear clientes
        $client1 = Client::create([
            'name' => 'Laura Martín',
            'email' => 'laura@email.com',
            'phone' => '555-1001',
            'address' => 'Calle Principal 123',
            'birth_date' => '1990-05-15',
            'gender' => 'female',
        ]);

        $client2 = Client::create([
            'name' => 'Pedro Sánchez',
            'email' => 'pedro@email.com',
            'phone' => '555-1002',
            'address' => 'Avenida Central 456',
            'birth_date' => '1985-08-22',
            'gender' => 'male',
        ]);

        $client3 = Client::create([
            'name' => 'Ana Torres',
            'email' => 'ana@email.com',
            'phone' => '555-1003',
            'address' => 'Plaza Mayor 789',
            'birth_date' => '1992-12-10',
            'gender' => 'female',
        ]);

        // Crear servicios
        $services = [
            [
                'name' => 'Corte de Cabello Mujer',
                'description' => 'Corte y peinado para dama',
                'duration' => 45,
                'price' => 25.00,
                'category' => 'Cortes',
            ],
            [
                'name' => 'Corte de Cabello Hombre',
                'description' => 'Corte masculino',
                'duration' => 30,
                'price' => 15.00,
                'category' => 'Cortes',
            ],
            [
                'name' => 'Tinte Completo',
                'description' => 'Coloración completa del cabello',
                'duration' => 120,
                'price' => 60.00,
                'category' => 'Coloración',
            ],
            [
                'name' => 'Mechas',
                'description' => 'Mechas de colores',
                'duration' => 90,
                'price' => 45.00,
                'category' => 'Coloración',
            ],
            [
                'name' => 'Peinado de Fiesta',
                'description' => 'Peinado para eventos especiales',
                'duration' => 60,
                'price' => 35.00,
                'category' => 'Peinados',
            ],
            [
                'name' => 'Tratamiento Capilar',
                'description' => 'Hidratación profunda',
                'duration' => 45,
                'price' => 30.00,
                'category' => 'Tratamientos',
            ],
            [
                'name' => 'Manicure',
                'description' => 'Cuidado de uñas',
                'duration' => 30,
                'price' => 20.00,
                'category' => 'Estética',
            ],
            [
                'name' => 'Pedicure',
                'description' => 'Cuidado de pies',
                'duration' => 45,
                'price' => 25.00,
                'category' => 'Estética',
            ],
        ];

        foreach ($services as $serviceData) {
            Service::create($serviceData);
        }

        // Crear algunas citas de ejemplo
        $appointment1 = Appointment::create([
            'client_id' => $client1->id,
            'user_id' => $stylist1->id,
            'appointment_date' => now()->addDays(1),
            'start_time' => '10:00:00',
            'end_time' => '11:00:00',
            'status' => 'confirmed',
            'notes' => 'Cliente prefiere corte bob',
        ]);

        // Agregar detalles a la cita
        AppointmentDetail::create([
            'appointment_id' => $appointment1->id,
            'service_id' => 1, // Corte de Cabello Mujer
            'quantity' => 1,
            'unit_price' => 25.00,
        ]);

        $appointment2 = Appointment::create([
            'client_id' => $client2->id,
            'user_id' => $stylist2->id,
            'appointment_date' => now()->addDays(2),
            'start_time' => '14:00:00',
            'end_time' => '14:30:00',
            'status' => 'pending',
        ]);

        AppointmentDetail::create([
            'appointment_id' => $appointment2->id,
            'service_id' => 2, // Corte de Cabello Hombre
            'quantity' => 1,
            'unit_price' => 15.00,
        ]);

        echo "✅ Base de datos sembrada exitosamente!\n";
        echo "👤 Usuario Admin: anita@peluqueria.com (password: password123)\n";
        echo "💇‍♀️ Estilista 1: maria@peluqueria.com (password: password123)\n";
        echo "💇‍♂️ Estilista 2: carlos@peluqueria.com (password: password123)\n";
    }
}
