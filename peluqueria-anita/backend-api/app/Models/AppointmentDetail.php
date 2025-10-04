<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AppointmentDetail extends Model
{
    use HasFactory;

    protected $fillable = [
        'appointment_id',
        'service_id',
        'quantity',
        'unit_price',
        'subtotal',
    ];

    protected function casts(): array
    {
        return [
            'unit_price' => 'decimal:2',
            'subtotal' => 'decimal:2',
        ];
    }

    /**
     * Relación: Un detalle pertenece a una cita
     */
    public function appointment()
    {
        return $this->belongsTo(Appointment::class);
    }

    /**
     * Relación: Un detalle pertenece a un servicio
     */
    public function service()
    {
        return $this->belongsTo(Service::class);
    }

    /**
     * Event para calcular automáticamente el subtotal
     */
    protected static function boot()
    {
        parent::boot();

        static::saving(function ($appointmentDetail) {
            // Calcular el subtotal automáticamente
            $appointmentDetail->subtotal = $appointmentDetail->quantity * $appointmentDetail->unit_price;
        });
    }
}
