<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Attention extends Model
{
    protected $table = 'attention';

    protected $fillable = [
        'date',
        'cite_id',
        'service_id',
        'price_service'
    ];

    protected $casts = [
        'date' => 'date',
        'price_service' => 'decimal:2'
    ];

    // Relaciones
    public function cite()
    {
        return $this->belongsTo(Cite::class, 'cite_id');
    }

    public function service()
    {
        return $this->belongsTo(Service::class, 'service_id');
    }

    public function person()
    {
        return $this->hasOneThrough(Person::class, Cite::class, 'id', 'id', 'cite_id', 'cliente_id');
    }
}
