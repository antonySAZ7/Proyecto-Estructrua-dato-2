import 'dart:convert';
import 'package:http/http.dart' as http;

class RecomendadorService {
  Future<Map<String, dynamic>> obtenerRecomendaciones(String usuario) async {
    final url = Uri.parse(
      'https://proyecto-estructrua-dato-2.onrender.com/recomendar?usuario=$usuario',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "error": "Error del servidor: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "error": "Error de conexión: $e",
      };
    }
  }
}
