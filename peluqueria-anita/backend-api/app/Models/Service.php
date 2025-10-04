<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Service extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'duration',
        'price',
        'category',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'price' => 'decimal:2',
            'is_active' => 'boolean',
        ];
    }

    /**
     * Relación: Un servicio puede estar en múltiples detalles de citas
     */
    public function appointmentDetails()
    {
        return $this->hasMany(AppointmentDetail::class);
    }

    /**
     * Relación: Un servicio puede estar en múltiples citas a través de detalles
     */
    public function appointments()
    {
        return $this->belongsToMany(Appointment::class, 'appointment_details')
                    ->withPivot('quantity', 'unit_price', 'subtotal')
                    ->withTimestamps();
    }

    /**
     * Scope para servicios activos
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope para filtrar por categoría
     */
    public function scopeByCategory($query, $category)
    {
        return $query->where('category', $category);
    }

    /**
     * Obtener la duración formateada
     */
    public function getFormattedDurationAttribute()
    {
        $hours = intval($this->duration / 60);
        $minutes = $this->duration % 60;
        
        if ($hours > 0) {
            return $hours . 'h ' . $minutes . 'min';
        }
        
        return $minutes . 'min';
    }
}
