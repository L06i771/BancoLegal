<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreDespesaRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'descricao' => [
                'required',
                'string',
                'max:255',
            ],

            'valor' => [
                'required',
                'integer',
                'min:1',
            ],

            'data' => [
                'required',
                'date',
            ],

            'categoria_id' => [
                'required',
                'integer',
                'exists:categorias,id',
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'descricao.required' => 'A descrição da despesa é obrigatória.',
            'descricao.string' => 'A descrição da despesa deve ser um texto.',
            'descricao.max' => 'A descrição da despesa pode ter no máximo 255 caracteres.',

            'valor.required' => 'O valor da despesa é obrigatório.',
            'valor.integer' => 'O valor da despesa deve ser informado em centavos.',
            'valor.min' => 'O valor da despesa deve ser maior que zero.',

            'data.required' => 'A data da despesa é obrigatória.',
            'data.date' => 'Informe uma data válida.',

            'categoria_id.required' => 'A categoria da despesa é obrigatória.',
            'categoria_id.integer' => 'O ID da categoria deve ser um número inteiro.',
            'categoria_id.exists' => 'A categoria informada não existe.',
        ];
    }
}