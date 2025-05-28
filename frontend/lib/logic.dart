import 'package:http/http.dart' as http;
import 'dart:convert';

const baseUrl = "https://proyecto-estructrua-dato-2.onrender.com";

Future<Map<String, dynamic>> obtenerRecomendaciones(String usuario) async {
  final url = Uri.parse('$baseUrl/recomendar?usuario=$usuario');
  final response = await http.get(url);
  return json.decode(response.body);
}

Future<List<String>> obtenerComidasSaludables() async {
  final url = Uri.parse('$baseUrl/saludables');
  final response = await http.get(url);
  final data = json.decode(response.body);
  return List<String>.from(data['comidas_saludables']);
}


Future<List<String>> obtenerGustosDesdeNeo4j(String usuario) async {
  final url = Uri.parse('https://proyecto-estructrua-dato-2.onrender.com/gustos_n4j?usuario=$usuario');
  final response = await http.get(url);
  final data = json.decode(response.body);

  if (response.statusCode == 200 && data.containsKey('gustos')) {
    return List<String>.from(data['gustos']);
  } else {
    throw Exception(data['mensaje'] ?? 'Error al obtener gustos');
  }
}