<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreReceitaRequest;
use App\Models\Receita;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReceitaController extends Controller
{
    public function index(): JsonResponse
    {
        $receitas = Receita::where('usuario_id', request()->user()->id)
            ->orderByDesc('data')
            ->get();

        return response()->json([
            'receitas' => $receitas,
        ], 200);
    }

    public function store(StoreReceitaRequest $request): JsonResponse
    {
        $receita = Receita::create([
            'descricao' => $request->descricao,
            'valor' => $request->valor,
            'data' => $request->data,
            'usuario_id' => $request->user()->id,
        ]);

        return response()->json([
            'message' => 'Receita criada com sucesso.',
            'receita' => $receita,
        ], 201);
    }

    public function show(Request $request, Receita $receita): JsonResponse
    {
        if ($receita->usuario_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Você não tem autorização para acessar esta receita.',
            ], 403);
        }

        return response()->json([
            'receita' => $receita,
        ], 200);
    }

    public function update(StoreReceitaRequest $request, Receita $receita): JsonResponse
    {
        if ($receita->usuario_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Você não tem autorização para alterar esta receita.',
            ], 403);
        }

        $receita->update([
            'descricao' => $request->descricao,
            'valor' => $request->valor,
            'data' => $request->data,
        ]);

        return response()->json([
            'message' => 'Receita atualizada com sucesso.',
            'receita' => $receita->fresh(),
        ], 200);
    }

    public function destroy(Request $request, Receita $receita): JsonResponse
    {
        if ($receita->usuario_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Você não tem autorização para excluir esta receita.',
            ], 403);
        }

        $receita->delete();

        return response()->json([
            'message' => 'Receita excluída com sucesso.',
        ], 200);
    }
}