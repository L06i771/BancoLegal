<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreMetaFinanceiraRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'nome' => [
                'required',
                'string',
                'max:255',
            ],

            'valor_desejado' => [
                'required',
                'integer',
                'min:1',
            ],

            'prazo' => [
                'nullable',
                'date',
                'after_or_equal:today',
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'nome.required' => 'O nome da meta é obrigatório.',
            'nome.string' => 'O nome da meta deve ser um texto.',
            'nome.max' => 'O nome da meta pode ter no máximo 255 caracteres.',

            'valor_desejado.required' => 'O valor desejado é obrigatório.',
            'valor_desejado.integer' => 'O valor desejado deve ser informado em centavos.',
            'valor_desejado.min' => 'O valor desejado deve ser maior que zero.',

            'prazo.date' => 'Informe uma data válida.',
            'prazo.after_or_equal' => 'O prazo não pode ser uma data passada.',
        ];
    }
}