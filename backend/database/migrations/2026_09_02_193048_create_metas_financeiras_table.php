<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('metas_financeiras', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->bigInteger('valor_desejado');
            $table->date('prazo')->nullable();

            $table->foreignId('usuario_id')
                ->constrained('usuarios')
                ->onDelete('cascade');

            $table->index(['usuario_id', 'prazo']);

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('metas_financeiras');
    }
};