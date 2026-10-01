import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // ============================================================
  // CADASTRO
  // ============================================================

  Future<Map<String, dynamic>> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/usuarios'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'password': senha,
        'password_confirmation': senha,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) {
      return data;
    }

    throw Exception(
      data['message'] ?? 'Erro ao realizar cadastro.',
    );
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<Map<String, dynamic>> login({
    required String email,
    required String senha,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': senha,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(
      data['message'] ?? 'Erro ao realizar login.',
    );
  }

  // ============================================================
  // RECEITAS
  // ============================================================

  Future<List<dynamic>> buscarReceitas(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/receitas'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return data['receitas'] as List<dynamic>;
    }

    throw Exception(
      data['message'] ?? 'Erro ao buscar receitas.',
    );
  }

  Future<Map<String, dynamic>> criarReceita({
    required String token,
    required String descricao,
    required int valor,
    required String data,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/receitas'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'descricao': descricao,
        'valor': valor,
        'data': data,
      }),
    );

    final responseData =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseData;
    }

    throw Exception(
      responseData['message'] ?? 'Erro ao criar receita.',
    );
  }

  Future<Map<String, dynamic>> editarReceita({
    required String token,
    required int id,
    required String descricao,
    required int valor,
    required String data,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/receitas/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'descricao': descricao,
        'valor': valor,
        'data': data,
      }),
    );

    final responseData =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return responseData;
    }

    throw Exception(
      responseData['message'] ?? 'Erro ao editar receita.',
    );
  }

  Future<void> excluirReceita({
    required String token,
    required int id,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/receitas/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    throw Exception(
      data['message'] ?? 'Erro ao excluir receita.',
    );
  }

  // ============================================================
  // DESPESAS
  // ============================================================

  Future<List<dynamic>> buscarDespesas(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/despesas'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return data['despesas'] as List<dynamic>;
    }

    throw Exception(
      data['message'] ?? 'Erro ao buscar despesas.',
    );
  }

  Future<Map<String, dynamic>> criarDespesa({
    required String token,
    required String descricao,
    required int valor,
    required String data,
    required int categoriaId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/despesas'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'descricao': descricao,
        'valor': valor,
        'data': data,
        'categoria_id': categoriaId,
      }),
    );

    final responseData =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseData;
    }

    throw Exception(
      responseData['message'] ?? 'Erro ao criar despesa.',
    );
  }

  Future<Map<String, dynamic>> editarDespesa({
    required String token,
    required int id,
    required String descricao,
    required int valor,
    required String data,
    required int categoriaId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/despesas/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'descricao': descricao,
        'valor': valor,
        'data': data,
        'categoria_id': categoriaId,
      }),
    );

    final responseData =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return responseData;
    }

    throw Exception(
      responseData['message'] ?? 'Erro ao editar despesa.',
    );
  }

  Future<void> excluirDespesa({
    required String token,
    required int id,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/despesas/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    throw Exception(
      data['message'] ?? 'Erro ao excluir despesa.',
    );
  }

  // ============================================================
  // CATEGORIAS
  // ============================================================

  Future<List<dynamic>> buscarCategorias(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/categorias'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return data['categorias'] as List<dynamic>;
    }

    throw Exception(
      data['message'] ?? 'Erro ao buscar categorias.',
    );
  }

  Future<Map<String, dynamic>> criarCategoria({
    required String token,
    required String nome,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categorias'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nome': nome,
      }),
    );

    final responseData =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseData;
    }

    throw Exception(
      responseData['message'] ?? 'Erro ao criar categoria.',
    );
  }

  Future<void> excluirCategoria({
    required String token,
    required int id,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/categorias/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    throw Exception(
      data['message'] ?? 'Erro ao excluir categoria.',
    );
  }

  // ============================================================
  // METAS FINANCEIRAS
  // ============================================================

  Future<List<dynamic>> buscarMetas(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/metas-financeiras'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      final metas =
          data['metas_financeiras'] ??
          data['metas'] ??
          data['data'];

      if (metas is List) {
        return metas;
      }

      throw Exception(
        'A API não retornou uma lista de metas.',
      );
    }

    throw Exception(
      data['message'] ?? 'Erro ao buscar metas.',
    );
  }

  Future<Map<String, dynamic>> criarMeta({
    required String token,
    required String nome,
    required int valorDesejado,
    String? prazo,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/metas-financeiras'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nome': nome,
        'valor_desejado': valorDesejado,
        'prazo': prazo,
      }),
    );

    final responseData =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseData;
    }

    throw Exception(
      responseData['message'] ?? 'Erro ao criar meta.',
    );
  }

  Future<Map<String, dynamic>> editarMeta({
    required String token,
    required int id,
    required String nome,
    required int valorDesejado,
    String? prazo,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/metas-financeiras/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nome': nome,
        'valor_desejado': valorDesejado,
        'prazo': prazo,
      }),
    );

    final responseData =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return responseData;
    }

    throw Exception(
      responseData['message'] ?? 'Erro ao editar meta.',
    );
  }

  Future<void> excluirMeta({
    required String token,
    required int id,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/metas-financeiras/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    throw Exception(
      data['message'] ?? 'Erro ao excluir meta.',
    );
  }
}