import 'package:flutter/material.dart';
import 'logic.dart'; // Importa tu archivo

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _controladorUsuario = TextEditingController();
  final _servicio = RecomendadorService();

  String _nota = '';
  String _usuario = '';
  List<dynamic> _recomendaciones = [];
  String _error = '';

  void _consultar() async {
    final nombre = _controladorUsuario.text.trim();
    if (nombre.isEmpty) return;

    final resultado = await _servicio.obtenerRecomendaciones(nombre);

    setState(() {
      _usuario = nombre;
      _error = resultado["error"] ?? '';
      _nota = resultado["nota"] ?? '';
      _recomendaciones = resultado["recomendaciones"] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Recomendaciones',
      home: Scaffold(
        appBar: AppBar(title: const Text('Recomendador de comida')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _controladorUsuario,
                decoration: const InputDecoration(labelText: 'Nombre de usuario'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _consultar,
                child: const Text('Obtener recomendaciones'),
              ),
              const SizedBox(height: 20),
              if (_error.isNotEmpty)
                Text(_error, style: const TextStyle(color: Colors.red)),
              if (_usuario.isNotEmpty && _error.isEmpty) ...[
                Text('Hola $_usuario'),
                if (_nota.isNotEmpty) Text(_nota),
                const SizedBox(height: 10),
                ..._recomendaciones.map((r) => Text('- $r')).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
