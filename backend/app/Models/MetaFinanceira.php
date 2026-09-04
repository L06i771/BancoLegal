<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class MetaFinanceira extends Model
{
    use HasFactory;

    protected $table = 'metas_financeiras';

    protected $fillable = [
        'nome',
        'valor_desejado',
        'prazo',
        'usuario_id',
    ];

    protected $appends = [
        'progresso',
    ];

    protected function casts(): array
    {
        return [
            'valor_desejado' => 'integer',
            'prazo' => 'date',
        ];
    }

    public function usuario()
    {
        return $this->belongsTo(Usuario::class);
    }

    protected function progresso(): Attribute
    {
        return Attribute::make(
            get: function () {
                $receitas = DB::table('receitas')
                    ->where('usuario_id', $this->usuario_id)
                    ->where('data', '>=', $this->created_at->toDateString())
                    ->sum('valor');

                $despesas = DB::table('despesas')
                    ->where('usuario_id', $this->usuario_id)
                    ->where('data', '>=', $this->created_at->toDateString())
                    ->sum('valor');

                return max(0, $receitas - $despesas);
            }
        );
    }
}