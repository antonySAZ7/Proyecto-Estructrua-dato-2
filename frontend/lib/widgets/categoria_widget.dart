import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoriaWidget extends StatefulWidget {
  final TextEditingController tipoController;

  CategoriaWidget({required this.tipoController});

  @override
  _CategoriaWidgetState createState() => _CategoriaWidgetState();
}

class _CategoriaWidgetState extends State<CategoriaWidget> {
  List<String> comidas = [];
  String mensaje = '';

  Future<void> obtenerPorCategoria(String tipo) async {
    final url = Uri.parse('https://proyecto-estructrua-dato-2.onrender.com/categoria/$tipo');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          comidas = List<String>.from(data['comidas']);
          mensaje = '';
        });
      } else {
        setState(() {
          comidas = [];
          mensaje = data['mensaje'] ?? 'Error';
        });
      }
    } catch (e) {
      setState(() {
        comidas = [];
        mensaje = 'Error de conexión';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Buscar por categoría", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.tipoController,
                decoration: InputDecoration(labelText: "Ej: italiana, china"),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => obtenerPorCategoria(widget.tipoController.text),
            ),
          ],
        ),
        if (mensaje.isNotEmpty) Text(mensaje),
        ...comidas.map((c) => ListTile(title: Text(c))).toList(),
      ],
    );
  }
}
