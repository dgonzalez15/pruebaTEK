<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;

class CreateTestUser extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'create:test-user';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Create a test user for the application';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        // Verificar si el usuario ya existe
        $existingUser = User::where('email', 'test@test.com')->first();
        
        if ($existingUser) {
            $this->info('El usuario test@test.com ya existe.');
            return;
        }

        // Crear el usuario
        $user = User::create([
            'name' => 'Usuario Test',
            'email' => 'test@test.com',
            'password' => Hash::make('123456'),
            'phone' => '555-1234',
            'address' => 'Dirección Test',
            'birth_date' => '1990-01-01',
            'gender' => 'masculino',
            'role' => 'client',
        ]);

        $this->info('Usuario creado exitosamente:');
        $this->info('Email: ' . $user->email);
        $this->info('Password: 123456');
        $this->info('Nombre: ' . $user->name);
    }
}
