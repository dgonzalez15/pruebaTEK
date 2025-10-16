<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Person extends Model
{
    protected $table = 'person';

    protected $fillable = [
        'document',
        'first_name',
        'last_name',
        'address',
        'phone',
        'email'
    ];

    // Relaciones
    public function cites()
    {
        return $this->hasMany(Cite::class, 'cliente_id');
    }

    public function attentions()
    {
        return $this->hasManyThrough(Attention::class, Cite::class, 'cliente_id', 'cite_id');
    }

    // Accessor para nombre completo
    public function getFullNameAttribute()
    {
        return "{$this->first_name} {$this->last_name}";
    }
}
