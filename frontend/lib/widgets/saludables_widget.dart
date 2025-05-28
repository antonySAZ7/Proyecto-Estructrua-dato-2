import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SaludablesWidget extends StatefulWidget {
  @override
  _SaludablesWidgetState createState() => _SaludablesWidgetState();
}

class _SaludablesWidgetState extends State<SaludablesWidget> {
  List<String> comidas = [];

  Future<void> obtenerSaludables() async {
    final url = Uri.parse('https://proyecto-estructrua-dato-2.onrender.com/saludables');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final datos = json.decode(response.body);
        setState(() {
          comidas = List<String>.from(datos['comidas_saludables']);
        });
      } else {
        setState(() {
          comidas = ['Error al obtener datos'];
        });
      }
    } catch (e) {
      setState(() {
        comidas = ['Error de conexión'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerSaludables();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Comidas Saludables", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ...comidas.map((c) => ListTile(title: Text(c))).toList(),
      ],
    );
  }
}
