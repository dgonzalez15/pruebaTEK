<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Attention;
use App\Models\Appointment;
use App\Models\Client;
use App\Models\User;
use App\Models\Service;
use Carbon\Carbon;

class AttentionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Obtener datos necesarios
        $appointments = Appointment::all();
        $clients = Client::all();
        $stylists = User::where('role', 'stylist')->get();
        $services = Service::all();

        if ($appointments->isEmpty() || $clients->isEmpty() || $stylists->isEmpty() || $services->isEmpty()) {
            $this->command->warn('No hay datos suficientes para crear atenciones. Asegúrate de que existan citas, clientes, estilistas y servicios.');
            return;
        }

        $attentions = [
            [
                'appointment_id' => $appointments->first()->id,
                'client_id' => $clients->first()->id,
                'user_id' => $stylists->first()->id,
                'service_id' => $services->where('name', 'Corte de cabello')->first()?->id ?? $services->first()->id,
                'attention_date' => Carbon::today()->subDays(2),
                'start_time' => '09:00:00',
                'end_time' => '09:30:00',
                'status' => 'completed',
                'service_price' => 25.00,
                'observations' => 'Cliente muy satisfecho con el corte. Cabello graso, recomendado shampoo especial.',
                'products_used' => 'Shampoo clarificante, acondicionador hidratante, gel de peinado',
                'tip_amount' => 5.00,
                'client_satisfaction' => 'very_satisfied',
                'notes' => 'Cliente frecuente, próxima cita en 4 semanas'
            ],
            [
                'appointment_id' => $appointments->count() > 1 ? $appointments->skip(1)->first()->id : $appointments->first()->id,
                'client_id' => $clients->count() > 1 ? $clients->skip(1)->first()->id : $clients->first()->id,
                'user_id' => $stylists->count() > 1 ? $stylists->skip(1)->first()->id : $stylists->first()->id,
                'service_id' => $services->where('name', 'Coloración')->first()?->id ?? $services->skip(1)->first()->id,
                'attention_date' => Carbon::today()->subDays(1),
                'start_time' => '14:00:00',
                'end_time' => '16:00:00',
                'status' => 'completed',
                'service_price' => 45.00,
                'observations' => 'Cambio de color dramático, de castaño a rubio. Proceso de decoloración realizado.',
                'products_used' => 'Decolorante profesional, tinte rubio ceniza, mascarilla reparadora, protector térmico',
                'tip_amount' => 8.00,
                'client_satisfaction' => 'satisfied',
                'notes' => 'Recomendado tratamiento de hidratación semanal'
            ],
            [
                'appointment_id' => $appointments->first()->id,
                'client_id' => $clients->count() > 2 ? $clients->skip(2)->first()->id : $clients->first()->id,
                'user_id' => $stylists->first()->id,
                'service_id' => $services->where('name', 'Peinado')->first()?->id ?? $services->skip(2)->first()->id,
                'attention_date' => Carbon::today(),
                'start_time' => '11:00:00',
                'end_time' => '12:00:00',
                'status' => 'in_progress',
                'service_price' => 30.00,
                'observations' => 'Peinado para evento especial. Estilo elegante con ondas suaves.',
                'products_used' => 'Mousse voluminizadora, spray fijador, aceite de brillo',
                'tip_amount' => 0.00,
                'client_satisfaction' => null,
                'notes' => 'Evento a las 18:00, cliente muy nerviosa'
            ],
            [
                'appointment_id' => $appointments->first()->id,
                'client_id' => $clients->first()->id,
                'user_id' => $stylists->count() > 1 ? $stylists->skip(1)->first()->id : $stylists->first()->id,
                'service_id' => $services->where('name', 'Tratamiento capilar')->first()?->id ?? $services->skip(3)->first()->id,
                'attention_date' => Carbon::today()->subDays(3),
                'start_time' => '16:30:00',
                'end_time' => '17:30:00',
                'status' => 'completed',
                'service_price' => 35.00,
                'observations' => 'Cabello muy dañado por químicos anteriores. Aplicado tratamiento intensivo.',
                'products_used' => 'Mascarilla proteínas, ampolla de keratina, aceite de argán',
                'tip_amount' => 7.00,
                'client_satisfaction' => 'very_satisfied',
                'notes' => 'Programar seguimiento en 2 semanas'
            ],
            [
                'appointment_id' => $appointments->count() > 1 ? $appointments->skip(1)->first()->id : $appointments->first()->id,
                'client_id' => $clients->count() > 1 ? $clients->skip(1)->first()->id : $clients->first()->id,
                'user_id' => $stylists->first()->id,
                'service_id' => $services->where('name', 'Corte de cabello')->first()?->id ?? $services->first()->id,
                'attention_date' => Carbon::today()->subWeek(),
                'start_time' => '10:15:00',
                'end_time' => '10:45:00',
                'status' => 'completed',
                'service_price' => 25.00,
                'observations' => 'Corte bob clásico. Cliente quería cambio de look radical.',
                'products_used' => 'Shampoo texturizante, crema de peinado, spray de volumen',
                'tip_amount' => 3.00,
                'client_satisfaction' => 'satisfied',
                'notes' => 'Cliente se adapta bien al nuevo corte'
            ]
        ];

        foreach ($attentions as $attentionData) {
            Attention::create($attentionData);
        }

        $this->command->info('Se han creado ' . count($attentions) . ' atenciones de prueba.');
    }
}