import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IngredientesWidget extends StatefulWidget {
  final TextEditingController platoController;

  IngredientesWidget({required this.platoController});

  @override
  _IngredientesWidgetState createState() => _IngredientesWidgetState();
}

class _IngredientesWidgetState extends State<IngredientesWidget> {
  List<String> ingredientes = [];
  String mensaje = '';

  Future<void> obtenerIngredientes(String plato) async {
    final url = Uri.parse('https://proyecto-estructrua-dato-2.onrender.com/ingredientes/$plato');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          ingredientes = List<String>.from(data['ingredientes']);
          mensaje = '';
        });
      } else {
        setState(() {
          ingredientes = [];
          mensaje = data['mensaje'] ?? 'No se encontraron ingredientes.';
        });
      }
    } catch (e) {
      setState(() {
        ingredientes = [];
        mensaje = 'Error de conexión';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Ingredientes de un plato", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.platoController,
                decoration: InputDecoration(labelText: "Nombre del plato"),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => obtenerIngredientes(widget.platoController.text),
            ),
          ],
        ),
        if (mensaje.isNotEmpty) Text(mensaje),
        ...ingredientes.map((i) => ListTile(title: Text(i))).toList(),
      ],
    );
  }
}
