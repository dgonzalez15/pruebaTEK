<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

/**
 * User Model
 * 
 * Modelo para gestionar usuarios del sistema (incluye estilistas)
 * Sistema de Reportería DFS
 * 
 * @author Diego González
 * @version 1.0.0
 */
class User extends Authenticatable
{
    use HasFactory, Notifiable, HasApiTokens;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'status',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    /**
     * Get all appointments assigned to this stylist.
     */
    public function appointments()
    {
        return $this->hasMany(Appointment::class, 'stylist_id');
    }

    /**
     * Scope to filter only stylists.
     */
    public function scopeStylists($query)
    {
        return $query->where('role', 'stylist');
    }

    /**
     * Scope to filter only active users.
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    /**
     * Check if user is admin.
     */
    public function isAdmin()
    {
        return $this->role === 'admin';
    }

    /**
     * Check if user is stylist.
     */
    public function isStylist()
    {
        return $this->role === 'stylist';
    }
}
