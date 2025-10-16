<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('Cite', function (Blueprint $table) {
            $table->id();
            $table->date('date');
            $table->foreignId('cliente_id')->constrained('person')->onDelete('cascade');
            $table->decimal('amount_attention', 10, 2)->default(0);
            $table->time('time_arrival')->nullable();
            $table->decimal('total_service', 10, 2)->default(0);
            $table->enum('status', ['scheduled', 'confirmed', 'completed', 'cancelled'])->default('scheduled');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('Cite');
    }
};
