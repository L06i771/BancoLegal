<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreMetaFinanceiraRequest;
use App\Models\MetaFinanceira;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MetaFinanceiraController extends Controller
{
    public function index(): JsonResponse
    {
        $metas = MetaFinanceira::where('usuario_id', request()->user()->id)
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'metas' => $metas,
        ], 200);
    }

    public function store(StoreMetaFinanceiraRequest $request): JsonResponse
    {
        $meta = MetaFinanceira::create([
            'nome' => $request->nome,
            'valor_desejado' => $request->valor_desejado,
            'prazo' => $request->prazo,
            'usuario_id' => $request->user()->id,
        ]);

        return response()->json([
            'message' => 'Meta financeira criada com sucesso.',
            'meta' => $meta->fresh(),
        ], 201);
    }

    public function show(
        Request $request,
        MetaFinanceira $metas_financeira
    ): JsonResponse {
        if ($metas_financeira->usuario_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Você não tem autorização para acessar esta meta.',
            ], 403);
        }

        return response()->json([
            'meta' => $metas_financeira->fresh(),
        ], 200);
    }

    public function update(
        StoreMetaFinanceiraRequest $request,
        MetaFinanceira $metas_financeira
    ): JsonResponse {
        if ($metas_financeira->usuario_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Você não tem autorização para alterar esta meta.',
            ], 403);
        }

        $metas_financeira->update([
            'nome' => $request->nome,
            'valor_desejado' => $request->valor_desejado,
            'prazo' => $request->prazo,
        ]);

        return response()->json([
            'message' => 'Meta financeira atualizada com sucesso.',
            'meta' => $metas_financeira->fresh(),
        ], 200);
    }

    public function destroy(
        Request $request,
        MetaFinanceira $metas_financeira
    ): JsonResponse {
        if ($metas_financeira->usuario_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Você não tem autorização para excluir esta meta.',
            ], 403);
        }

        $metas_financeira->delete();

        return response()->json([
            'message' => 'Meta financeira excluída com sucesso.',
        ], 200);
    }
}