<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreCategoriaRequest;
use App\Models\Categoria;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CategoriaController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $categorias = Categoria::where(function ($query) use ($request) {
            $query->where('is_global', true)
                  ->orWhere('usuario_id', $request->user()->id);
        })
        ->orderBy('nome')
        ->get();

        return response()->json([
            'categorias' => $categorias,
        ], 200);
    }

    public function store(StoreCategoriaRequest $request): JsonResponse
    {
        $categoria = Categoria::create([
            'nome' => $request->nome,
            'usuario_id' => $request->user()->id,
            'is_global' => false,
        ]);

        return response()->json([
            'message' => 'Categoria criada com sucesso.',
            'categoria' => $categoria,
        ], 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $categoria = Categoria::where('id', $id)
            ->where(function ($query) use ($request) {
                $query->where('is_global', true)
                      ->orWhere('usuario_id', $request->user()->id);
            })
            ->first();

        if (!$categoria) {
            return response()->json([
                'message' => 'Categoria não encontrada ou não autorizada.',
            ], 404);
        }

        return response()->json([
            'categoria' => $categoria,
        ], 200);
    }

    public function update(
        StoreCategoriaRequest $request,
        int $id
    ): JsonResponse {
        $categoria = Categoria::where('id', $id)
            ->where('usuario_id', $request->user()->id)
            ->where('is_global', false)
            ->first();

        if (!$categoria) {
            return response()->json([
                'message' => 'Categoria não encontrada ou não pode ser alterada.',
            ], 404);
        }

        $categoria->update([
            'nome' => $request->nome,
        ]);

        return response()->json([
            'message' => 'Categoria atualizada com sucesso.',
            'categoria' => $categoria,
        ], 200);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $categoria = Categoria::where('id', $id)
            ->where('usuario_id', $request->user()->id)
            ->where('is_global', false)
            ->first();

        if (!$categoria) {
            return response()->json([
                'message' => 'Categoria não encontrada ou não pode ser excluída.',
            ], 404);
        }

        $categoria->delete();

        return response()->json([
            'message' => 'Categoria excluída com sucesso.',
        ], 200);
    }
}
