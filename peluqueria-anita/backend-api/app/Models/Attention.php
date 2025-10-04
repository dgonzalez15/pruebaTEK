<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Attention extends Model
{
    use HasFactory;

    protected $fillable = [
        'appointment_id',
        'client_id',
        'user_id',
        'service_id',
        'attention_date',
        'start_time',
        'end_time',
        'status',
        'service_price',
        'observations',
        'products_used',
        'tip_amount',
        'client_satisfaction',
        'notes'
    ];

    protected $casts = [
        'attention_date' => 'date',
        'start_time' => 'datetime:H:i',
        'end_time' => 'datetime:H:i',
        'service_price' => 'decimal:2',
        'tip_amount' => 'decimal:2',
    ];

    // Relaciones
    public function appointment(): BelongsTo
    {
        return $this->belongsTo(Appointment::class);
    }

    public function client(): BelongsTo
    {
        return $this->belongsTo(Client::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function stylist(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function service(): BelongsTo
    {
        return $this->belongsTo(Service::class);
    }

    // Scopes
    public function scopeByDate($query, $date)
    {
        return $query->where('attention_date', $date);
    }

    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    public function scopeByStylist($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    public function scopeByClient($query, $clientId)
    {
        return $query->where('client_id', $clientId);
    }

    // Mutators
    public function setStartTimeAttribute($value)
    {
        $this->attributes['start_time'] = date('H:i:s', strtotime($value));
    }

    public function setEndTimeAttribute($value)
    {
        $this->attributes['end_time'] = date('H:i:s', strtotime($value));
    }

    // Accessors
    public function getFormattedDateAttribute()
    {
        return $this->attention_date->format('d/m/Y');
    }

    public function getFormattedStartTimeAttribute()
    {
        return date('H:i', strtotime($this->start_time));
    }

    public function getFormattedEndTimeAttribute()
    {
        return date('H:i', strtotime($this->end_time));
    }

    public function getDurationInMinutesAttribute()
    {
        $start = strtotime($this->start_time);
        $end = strtotime($this->end_time);
        return ($end - $start) / 60;
    }

    public function getTotalAmountAttribute()
    {
        return $this->service_price + $this->tip_amount;
    }
}
