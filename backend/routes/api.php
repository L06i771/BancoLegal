<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\CategoriaController;
use App\Http\Controllers\DespesaController;
use App\Http\Controllers\MetaFinanceiraController;
use App\Http\Controllers\ReceitaController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {

    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    Route::apiResource('categorias', CategoriaController::class);

    Route::apiResource('despesas', DespesaController::class);

    Route::apiResource('receitas', ReceitaController::class);

    Route::apiResource('metas-financeiras', MetaFinanceiraController::class);
});