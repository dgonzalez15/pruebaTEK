<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Client extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'address',
        'birth_date',
        'gender',
        'preferences',
        'notes',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'birth_date' => 'date',
            'is_active' => 'boolean',
        ];
    }

    /**
     * Relación: Un cliente puede tener múltiples citas
     */
    public function appointments()
    {
        return $this->hasMany(Appointment::class);
    }

    /**
     * Relación: Un cliente puede tener múltiples atenciones
     */
    public function attentions()
    {
        return $this->hasMany(Attention::class);
    }

    /**
     * Relación: Un cliente puede tener pagos a través de citas
     */
    public function payments()
    {
        return $this->hasManyThrough(Payment::class, Appointment::class);
    }

    /**
     * Obtener citas completadas del cliente
     */
    public function completedAppointments()
    {
        return $this->appointments()->where('status', 'completed');
    }

    /**
     * Obtener el total gastado por el cliente
     */
    public function getTotalSpentAttribute()
    {
        return $this->completedAppointments()->sum('total_amount');
    }

    /**
     * Obtener la edad del cliente
     */
    public function getAgeAttribute()
    {
        return $this->birth_date ? $this->birth_date->age : null;
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeInactive($query)
    {
        return $query->where('is_active', false);
    }

    public function scopeByGender($query, $gender)
    {
        return $query->where('gender', $gender);
    }
}
