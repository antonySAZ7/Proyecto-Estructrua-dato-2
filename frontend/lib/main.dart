import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> recomendarUsuario() async {
    final usuario = 'juan';
    final url = Uri.parse('https://proyecto-estructrua-dato-2.onrender.com/recomendar?usuario=$usuario');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('✅ Sugerencias: ${response.body}');
      } else {
        print('❌ Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Recomendador de comida')),
        body: Center(
          child: ElevatedButton(
            onPressed: recomendarUsuario,
            child: Text('Obtener recomendaciones'),
          ),
        ),
      ),
    );
  }
}
