<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Appointment extends Model
{
    use HasFactory;

    protected $fillable = [
        'client_id',
        'user_id',
        'appointment_date',
        'start_time',
        'end_time',
        'status',
        'total_amount',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'appointment_date' => 'date',
            'start_time' => 'datetime:H:i:s',
            'end_time' => 'datetime:H:i:s',
            'total_amount' => 'decimal:2',
        ];
    }

    /**
     * Relación: Una cita pertenece a un cliente
     */
    public function client()
    {
        return $this->belongsTo(Client::class);
    }

    /**
     * Relación: Una cita pertenece a un usuario (estilista)
     */
    public function stylist()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Relación: Una cita pertenece a un usuario (estilista) - alias
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Relación: Una cita puede tener múltiples detalles
     */
    public function appointmentDetails()
    {
        return $this->hasMany(AppointmentDetail::class);
    }

    /**
     * Relación: Una cita puede tener múltiples servicios a través de detalles
     */
    public function services()
    {
        return $this->belongsToMany(Service::class, 'appointment_details')
                    ->withPivot('quantity', 'unit_price', 'subtotal')
                    ->withTimestamps();
    }

    /**
     * Relación: Una cita puede tener múltiples pagos
     */
    public function payments()
    {
        return $this->hasMany(Payment::class);
    }

    /**
     * Relación: Una cita puede tener múltiples atenciones
     */
    public function attentions()
    {
        return $this->hasMany(Attention::class);
    }

    /**
     * Scope para citas del día actual
     */
    public function scopeToday($query)
    {
        return $query->whereDate('appointment_date', today());
    }

    /**
     * Scope para citas de un estilista específico
     */
    public function scopeByStylist($query, $stylistId)
    {
        return $query->where('stylist_id', $stylistId);
    }

    /**
     * Scope para citas por estado
     */
    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    /**
     * Obtener el total pagado de la cita
     */
    public function getTotalPaidAttribute()
    {
        return $this->payments()->where('status', 'completed')->sum('amount');
    }

    /**
     * Obtener el saldo pendiente de la cita
     */
    public function getPendingBalanceAttribute()
    {
        return $this->total_amount - $this->total_paid;
    }

    /**
     * Verificar si la cita está completamente pagada
     */
    public function isPaid()
    {
        return $this->pending_balance <= 0;
    }
}
