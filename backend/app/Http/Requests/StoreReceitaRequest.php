<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreReceitaRequest extends FormRequest
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
        ];
    }

    public function messages(): array
    {
        return [
            'descricao.required' => 'A descrição da receita é obrigatória.',
            'descricao.string' => 'A descrição da receita deve ser um texto.',
            'descricao.max' => 'A descrição da receita pode ter no máximo 255 caracteres.',

            'valor.required' => 'O valor da receita é obrigatório.',
            'valor.integer' => 'O valor da receita deve ser informado em centavos.',
            'valor.min' => 'O valor da receita deve ser maior que zero.',

            'data.required' => 'A data da receita é obrigatória.',
            'data.date' => 'Informe uma data válida.',
        ];
    }
}