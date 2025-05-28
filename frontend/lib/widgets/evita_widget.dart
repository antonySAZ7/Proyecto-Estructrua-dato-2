import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EvitaWidget extends StatefulWidget {
  final TextEditingController usuarioController;

  const EvitaWidget({super.key, required this.usuarioController});

  @override
  State<EvitaWidget> createState() => _EvitaWidgetState();
}

class _EvitaWidgetState extends State<EvitaWidget> {
  List<String> evitados = [];
  String mensaje = "";

  Future<void> buscarEvita() async {
    final usuario = widget.usuarioController.text;
    final url = Uri.parse('https://proyecto-estructrua-dato-2.onrender.com/evita?usuario=$usuario');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          mensaje = "";
          evitados = List<String>.from(data['ingredientes_evita']); // ✅ CORREGIDO
        });
      } else {
        setState(() {
          mensaje = jsonDecode(response.body)['mensaje'] ?? 'Error';
          evitados = [];
        });
      }
    } catch (e) {
      setState(() {
        mensaje = "Error de conexión";
        evitados = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Ingredientes que evita el usuario", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextField(
            controller: widget.usuarioController,
            decoration: const InputDecoration(labelText: 'Nombre del usuario'),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: buscarEvita,
              icon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 8),
          if (mensaje.isNotEmpty)
            Text(mensaje, style: const TextStyle(color: Colors.red)),
          ...evitados.map((i) => Text('- $i')),
        ],
      ),
    );
  }
}
