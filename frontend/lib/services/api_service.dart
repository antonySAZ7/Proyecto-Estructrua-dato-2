import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Para debugPrint

class ApiService {
  static const String baseUrl = "https://proyecto-estructrua-dato-2.onrender.com";
  static const int timeoutSeconds = 10; // Tiempo de espera para solicitudes

  // Método auxiliar para manejar solicitudes HTTP
  static Future<Map<String, dynamic>> _makeGetRequest(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(url).timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(errorData['mensaje'] ?? 'Error ${response.statusCode}: No se pudo procesar la solicitud');
      }
    } catch (e) {
      debugPrint('Error en _makeGetRequest ($endpoint): $e');
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }

  static Future<Map<String, dynamic>> obtenerRecomendaciones(String usuario) async {
    if (usuario.trim().isEmpty) {
      throw Exception('El nombre de usuario no puede estar vacío');
    }
    final data = await _makeGetRequest('/recomendar?usuario=${Uri.encodeQueryComponent(usuario)}');
    return {
      'recomendaciones': List<String>.from(data['recomendaciones'] ?? []),
      'nota': data['nota'] ?? 'No hay nota disponible',
      'gustos': List<String>.from(data['gustos'] ?? []),
    };
  }

  static Future<List<String>> obtenerComidasSaludables() async {
    final data = await _makeGetRequest('/saludables');
    return List<String>.from(data['comidas_saludables'] ?? []);
  }

  static Future<List<String>> obtenerGustosDesdeNeo4j(String usuario) async {
    if (usuario.trim().isEmpty) {
      throw Exception('El nombre de usuario no puede estar vacío');
    }
    final data = await _makeGetRequest('/gustos_n4j?usuario=${Uri.encodeQueryComponent(usuario)}');
    if (data.containsKey('gustos')) {
      return List<String>.from(data['gustos']);
    }
    throw Exception(data['mensaje'] ?? 'No se encontraron gustos');
  }

  static Future<List<String>> obtenerIngredientesEvitados(String usuario) async {
    if (usuario.trim().isEmpty) {
      throw Exception('El nombre de usuario no puede estar vacío');
    }
    final data = await _makeGetRequest('/evita?usuario=${Uri.encodeQueryComponent(usuario)}');
    if (data.containsKey('ingredientes_evita')) {
      return List<String>.from(data['ingredientes_evita']);
    }
    throw Exception(data['mensaje'] ?? 'No se encontraron ingredientes evitados');
  }

  static Future<Map<String, dynamic>> obtenerPorCategoria(String tipo) async {
    if (tipo.trim().isEmpty) {
      throw Exception('La categoría no puede estar vacía');
    }
    final data = await _makeGetRequest('/categoria/${Uri.encodeQueryComponent(tipo)}');
    return {
      'categoria': data['categoria'] ?? tipo,
      'comidas': List<String>.from(data['comidas'] ?? []),
    };
  }

  static Future<Map<String, dynamic>> obtenerIngredientes(String plato) async {
    if (plato.trim().isEmpty) {
      throw Exception('El nombre del plato no puede estar vacío');
    }
    final data = await _makeGetRequest('/ingredientes/${Uri.encodeQueryComponent(plato)}');
    return {
      'plato': data['plato'] ?? plato,
      'ingredientes': List<String>.from(data['ingredientes'] ?? []),
    };
  }

  // Nuevo método para login
  static Future<Map<String, dynamic>> login(String usuario, String password) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'usuario': usuario, 'password': password}),
      ).timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(errorData['error'] ?? 'Error ${response.statusCode}: No se pudo iniciar sesión');
      }
    } catch (e) {
      debugPrint('Error en login: $e');
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }

  // Nuevo método para registrar usuarios
  static Future<Map<String, dynamic>> registrarUsuario(String usuario, String password) async {
    try {
      final url = Uri.parse('$baseUrl/registro');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'usuario': usuario, 'password': password}),
      ).timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(errorData['error'] ?? 'Error ${response.statusCode}: No se pudo registrar el usuario');
      }
    } catch (e) {
      debugPrint('Error en registrarUsuario: $e');
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }

  static Future<void> register(
    String usuario,
    String password,
    String rol,
    List<String> gustos,
    List<String> evita,
  ) async {
    if (usuario.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Usuario y contraseña son requeridos');
    }

    // 1. Registrar usuario
    try {
      final url = Uri.parse('$baseUrl/registro');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'usuario': usuario,
          'password': password,
          'rol': rol,
        }),
      ).timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(errorData['error'] ?? 'Error al registrar usuario');
      }
    } catch (e) {
      debugPrint('Error al registrar usuario: $e');
      throw Exception('No se pudo registrar: $e');
    }

    // 2. Actualizar preferencias en Neo4j
    try {
      final url = Uri.parse('$baseUrl/update_preferences');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'usuario': usuario,
          'gustos': gustos,
          'evita': evita,
        }),
      ).timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(errorData['error'] ?? 'Error al guardar preferencias');
      }
    } catch (e) {
      debugPrint('Error al guardar preferencias: $e');
      throw Exception('No se pudieron guardar las preferencias: $e');
    }
  }

  
}