import 'package:flutter/material.dart';
import 'logic.dart';
import 'widgets/categoria_widget.dart';
import 'widgets/ingredientes_widget.dart';
import 'widgets/gustos_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recomendador de Comidas',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: RecomendacionesApp(),
    );
  }
}

class RecomendacionesApp extends StatefulWidget {
  @override
  _RecomendacionesAppState createState() => _RecomendacionesAppState();
}

class _RecomendacionesAppState extends State<RecomendacionesApp> {
  TextEditingController usuarioController = TextEditingController();
  TextEditingController tipoController = TextEditingController();
  TextEditingController platoController = TextEditingController();

  List<String> recomendaciones = [];
  String nota = '';

  Future<void> cargarRecomendaciones() async {
    final data = await obtenerRecomendaciones(usuarioController.text);
    setState(() {
      recomendaciones = List<String>.from(data['recomendaciones']);
      nota = data['nota'] ?? '';
    });
  }

  Future<void> mostrarSaludables() async {
    final datos = await obtenerComidasSaludables();
    setState(() {
      recomendaciones = datos;
      nota = "Comidas saludables encontradas";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sistema de Recomendaciones')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: usuarioController,
              decoration: InputDecoration(labelText: "Nombre del usuario"),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: cargarRecomendaciones,
                  child: Text("Recomendar"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: mostrarSaludables,
                  child: Text("Ver saludables"),
                ),
              ],
            ),
            if (nota.isNotEmpty) Text(nota, style: TextStyle(fontWeight: FontWeight.bold)),
            ...recomendaciones.map((r) => ListTile(title: Text(r))),
            Divider(),
            CategoriaWidget(tipoController: tipoController),
            Divider(),
            IngredientesWidget(platoController: platoController),
            Divider(),
            GustosWidget(usuarioController: usuarioController),
          ],
        ),
      ),
    );
  }
}
