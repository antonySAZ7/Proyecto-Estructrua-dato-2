import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GustosWidget extends StatefulWidget {
  final TextEditingController usuarioController;

  GustosWidget({required this.usuarioController});

  @override
  _GustosWidgetState createState() => _GustosWidgetState();
}

class _GustosWidgetState extends State<GustosWidget> {
  List<String> gustos = [];
  String mensaje = '';

  Future<void> obtenerGustosNeo4j(String usuario) async {
    final url = Uri.parse('https://proyecto-estructrua-dato-2.onrender.com/gustos_n4j?usuario=$usuario');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data.containsKey('gustos')) {
        setState(() {
          gustos = List<String>.from(data['gustos']);
          mensaje = '';
        });
      } else {
        setState(() {
          gustos = [];
          mensaje = data['mensaje'] ?? 'No se encontraron gustos.';
        });
      }
    } catch (e) {
      setState(() {
        gustos = [];
        mensaje = 'Error de conexión';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Gustos del usuario (Neo4j)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.usuarioController,
                decoration: InputDecoration(labelText: "Nombre del usuario"),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => obtenerGustosNeo4j(widget.usuarioController.text),
            ),
          ],
        ),
        if (mensaje.isNotEmpty) Text(mensaje),
        ...gustos.map((g) => ListTile(title: Text(g))).toList(),
      ],
    );
  }
}

