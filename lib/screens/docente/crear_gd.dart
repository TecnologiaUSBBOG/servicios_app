import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:servicios/globals.dart';
import 'package:servicios/screens/funcionalidad.dart';
import 'package:servicios/screens/docente/grupal_td.dart';

class CrearGrupoTutoriaScreen extends StatefulWidget {
  const CrearGrupoTutoriaScreen({super.key});

  @override
  State<CrearGrupoTutoriaScreen> createState() =>
      _CrearGrupoTutoriaScreenState();
}

class _CrearGrupoTutoriaScreenState extends State<CrearGrupoTutoriaScreen> {
  Funcionalidad alert = Funcionalidad();
  final TextEditingController _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Grupo'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.yellow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del grupo',
                prefixIcon: Icon(Icons.add),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                crearGrupo(context, _nombreController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text(
                'Crear grupo de tutoría',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void crearGrupo(BuildContext context, String nombreGrupo) async {
    if (nombreGrupo.isEmpty) {
      return; // Salir si el nombre está vacío
    }

    try {
      final response = await http.post(
        Uri.parse(
          'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasCrearGrupo',
        ),
        body: {
          'NOMBRE_G': nombreGrupo,
          'DOC_DOC': globalCodigoDocente,
        },
      );

      if (response.statusCode == 200) {
        // Decodifica la respuesta JSON
        final jsonResponse = json.decode(response.body);

        // Verifica si la respuesta indica éxito
        if (jsonResponse['success'] != null) {
          // Muestra un mensaje de éxito
          alert.showAlertDialogSuccess(
            // ignore: use_build_context_synchronously
            context,
            'GRUPO SESSION',
            jsonResponse['success'], // Mensaje de éxito desde la respuesta
            'pro',
            (BuildContext context) => const GrupalTutoriaScreen(),
          );
        } else {
          // Manejo si no hay mensaje de éxito
        }
      } else {
        // Detalles adicionales sobre el error
      }
    } catch (e) {
      // Para depuración
      throw Exception('Failed to create group: $e');
    }
  }
}
