<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Cite extends Model
{
    protected $table = 'Cite';

    protected $fillable = [
        'date',
        'cliente_id',
        'amount_attention',
        'time_arrival',
        'total_service',
        'status'
    ];

    protected $casts = [
        'date' => 'date',
        'time_arrival' => 'datetime',
        'amount_attention' => 'decimal:2',
        'total_service' => 'decimal:2'
    ];

    // Relaciones
    public function person()
    {
        return $this->belongsTo(Person::class, 'cliente_id');
    }

    public function attentions()
    {
        return $this->hasMany(Attention::class, 'cite_id');
    }

    // Scopes
    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    public function scopeDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('date', [$startDate, $endDate]);
    }

    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    public function scopeScheduled($query)
    {
        return $query->where('status', 'scheduled');
    }
}
