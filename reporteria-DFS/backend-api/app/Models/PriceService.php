<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PriceService extends Model
{
    protected $table = 'price_service';

    protected $fillable = [
        'value',
        'status',
        'service_id'
    ];

    protected $casts = [
        'value' => 'decimal:2',
        'status' => 'boolean'
    ];

    // Relaciones
    public function service()
    {
        return $this->belongsTo(Service::class, 'service_id');
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('status', true);
    }
}
