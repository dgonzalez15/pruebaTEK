<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('attentions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('appointment_id')->constrained('appointments')->onDelete('cascade');
            $table->foreignId('client_id')->constrained('clients')->onDelete('cascade');
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade'); // stylist
            $table->foreignId('service_id')->constrained('services')->onDelete('cascade');
            $table->date('attention_date');
            $table->time('start_time');
            $table->time('end_time');
            $table->enum('status', ['started', 'in_progress', 'completed', 'cancelled'])->default('started');
            $table->decimal('service_price', 10, 2);
            $table->text('observations')->nullable();
            $table->text('products_used')->nullable(); // productos utilizados
            $table->decimal('tip_amount', 8, 2)->default(0.00); // propina
            $table->enum('client_satisfaction', ['very_unsatisfied', 'unsatisfied', 'neutral', 'satisfied', 'very_satisfied'])->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
            
            // Índices para optimizar consultas
            $table->index(['attention_date', 'status']);
            $table->index(['client_id', 'attention_date']);
            $table->index(['user_id', 'attention_date']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('attentions');
    }
};
