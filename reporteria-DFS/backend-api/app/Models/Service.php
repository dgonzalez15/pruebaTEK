<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Service extends Model
{
    protected $table = 'service';

    protected $fillable = [
        'name',
        'slug'
    ];

    // Relaciones
    public function priceServices()
    {
        return $this->hasMany(PriceService::class, 'service_id');
    }

    public function attentions()
    {
        return $this->hasMany(Attention::class, 'service_id');
    }

    public function currentPrice()
    {
        return $this->hasOne(PriceService::class, 'service_id')
            ->where('status', true)
            ->latest();
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->whereHas('priceServices', function($q) {
            $q->where('status', true);
        });
    }
}
