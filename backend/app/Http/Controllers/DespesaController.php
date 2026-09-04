<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreDespesaRequest;
use App\Models\Categoria;
use App\Models\Despesa;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DespesaController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $despesas = Despesa::where('usuario_id', $request->user()->id)
            ->with('categoria')
            ->orderByDesc('data')
            ->get();

        return response()->json([
            'despesas' => $despesas,
        ], 200);
    }

    public function store(StoreDespesaRequest $request): JsonResponse
    {
        $categoriaValida = Categoria::where('id', $request->categoria_id)
            ->where(function ($query) use ($request) {
                $query->where('usuario_id', $request->user()->id)
                      ->orWhere('is_global', true);
            })
            ->exists();

        if (!$categoriaValida) {
            return response()->json([
                'message' => 'Categoria inválida ou não autorizada.',
            ], 403);
        }

        $despesa = Despesa::create([
            'descricao' => $request->descricao,
            'valor' => $request->valor,
            'data' => $request->data,
            'usuario_id' => $request->user()->id,
            'categoria_id' => $request->categoria_id,
        ]);

        $despesa->load('categoria');

        return response()->json([
            'message' => 'Despesa criada com sucesso.',
            'despesa' => $despesa,
        ], 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $despesa = Despesa::where('id', $id)
            ->where('usuario_id', $request->user()->id)
            ->with('categoria')
            ->first();

        if (!$despesa) {
            return response()->json([
                'message' => 'Despesa não encontrada ou não autorizada.',
            ], 404);
        }

        return response()->json([
            'despesa' => $despesa,
        ], 200);
    }

    public function update(
        StoreDespesaRequest $request,
        int $id
    ): JsonResponse {
        $despesa = Despesa::where('id', $id)
            ->where('usuario_id', $request->user()->id)
            ->first();

        if (!$despesa) {
            return response()->json([
                'message' => 'Despesa não encontrada ou não autorizada.',
            ], 404);
        }

        $categoriaValida = Categoria::where('id', $request->categoria_id)
            ->where(function ($query) use ($request) {
                $query->where('usuario_id', $request->user()->id)
                      ->orWhere('is_global', true);
            })
            ->exists();

        if (!$categoriaValida) {
            return response()->json([
                'message' => 'Categoria inválida ou não autorizada.',
            ], 403);
        }

        $despesa->update([
            'descricao' => $request->descricao,
            'valor' => $request->valor,
            'data' => $request->data,
            'categoria_id' => $request->categoria_id,
        ]);

        $despesa->load('categoria');

        return response()->json([
            'message' => 'Despesa atualizada com sucesso.',
            'despesa' => $despesa,
        ], 200);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $despesa = Despesa::where('id', $id)
            ->where('usuario_id', $request->user()->id)
            ->first();

        if (!$despesa) {
            return response()->json([
                'message' => 'Despesa não encontrada ou não autorizada.',
            ], 404);
        }

        $despesa->delete();

        return response()->json([
            'message' => 'Despesa excluída com sucesso.',
        ], 200);
    }
}
