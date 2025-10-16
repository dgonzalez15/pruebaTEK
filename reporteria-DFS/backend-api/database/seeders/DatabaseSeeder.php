<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use App\Models\Person;
use App\Models\Service;
use App\Models\PriceService;
use App\Models\Cite;
use App\Models\Attention;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Crear usuario administrador
        $admin = User::create([
            'name' => 'Admin DFS',
            'email' => 'admin@dfs.com',
            'password' => Hash::make('password123'),
            'role' => 'admin',
        ]);

        // Crear algunos estilistas (usuarios)
        $stylist1 = User::create([
            'name' => 'María González',
            'email' => 'maria@dfs.com',
            'password' => Hash::make('password123'),
            'role' => 'stylist',
        ]);

        $stylist2 = User::create([
            'name' => 'Carlos Ruiz',
            'email' => 'carlos@dfs.com',
            'password' => Hash::make('password123'),
            'role' => 'stylist',
        ]);

        // Crear servicios
        $corte = Service::create([
            'name' => 'Corte de Cabello',
            'slug' => 'corte-cabello',
        ]);

        $tintura = Service::create([
            'name' => 'Tintura',
            'slug' => 'tintura',
        ]);

        $peinado = Service::create([
            'name' => 'Peinado',
            'slug' => 'peinado',
        ]);

        // Precios para servicios
        PriceService::create(['service_id' => $corte->id, 'value' => 25000]);
        PriceService::create(['service_id' => $tintura->id, 'value' => 50000]);
        PriceService::create(['service_id' => $peinado->id, 'value' => 30000]);

        // Crear personas (clientes)
        $persona1 = Person::create([
            'document' => '1234567890',
            'first_name' => 'María',
            'last_name' => 'González',
            'email' => 'maria@example.com',
            'phone' => '3001234567',
            'address' => 'Calle 123 #45-67',
        ]);

        $persona2 = Person::create([
            'document' => '9876543210',
            'first_name' => 'Juan',
            'last_name' => 'Pérez',
            'email' => 'juan@example.com',
            'phone' => '3009876543',
            'address' => 'Carrera 45 #12-34',
        ]);

        // Crear citas
        $cita1 = Cite::create([
            'date' => now()->subDays(5),
            'time_arrival' => now()->subDays(5)->setTime(10, 0),
            'cliente_id' => $persona1->id,
            'amount_attention' => 25000,
            'total_service' => 25000,
            'status' => 'completed',
        ]);

        $cita2 = Cite::create([
            'date' => now()->subDays(3),
            'time_arrival' => now()->subDays(3)->setTime(14, 30),
            'cliente_id' => $persona2->id,
            'amount_attention' => 80000,
            'total_service' => 80000,
            'status' => 'completed',
        ]);

        $cita3 = Cite::create([
            'date' => now()->addDays(2),
            'time_arrival' => null,
            'cliente_id' => $persona1->id,
            'amount_attention' => 0,
            'total_service' => 0,
            'status' => 'scheduled',
        ]);

        // Crear atenciones
        Attention::create([
            'date' => now()->subDays(5),
            'cite_id' => $cita1->id,
            'service_id' => $corte->id,
            'price_service' => 25000,
        ]);

        Attention::create([
            'date' => now()->subDays(3),
            'cite_id' => $cita2->id,
            'service_id' => $tintura->id,
            'price_service' => 50000,
        ]);

        Attention::create([
            'date' => now()->subDays(3),
            'cite_id' => $cita2->id,
            'service_id' => $peinado->id,
            'price_service' => 30000,
        ]);

        $this->command->info("✅ Base de datos sembrada exitosamente!");
        $this->command->info("👤 Usuario Admin: admin@dfs.com (password: password123)");
        $this->command->info("💇‍♀️ Estilista 1: maria@dfs.com (password: password123)");
        $this->command->info("💇‍♂️ Estilista 2: carlos@dfs.com (password: password123)");
    }
}
