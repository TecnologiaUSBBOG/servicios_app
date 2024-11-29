import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:servicios/globals.dart';

class Tutoria {
  final String fechaTutoria;
  final String nombresEstudiante;
  final String nombreCurso;
  final String profesorResponsable;
  final String tematica;
  final String modalidad;
  final String lugar;
  final String metodologia;

  Tutoria({
    required this.fechaTutoria,
    required this.nombresEstudiante,
    required this.nombreCurso,
    required this.profesorResponsable,
    required this.tematica,
    required this.modalidad,
    required this.lugar,
    required this.metodologia,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CalendarioTD(),
    );
  }
}

class CalendarioTD extends StatefulWidget {
  const CalendarioTD({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalendarioScreenDState createState() => _CalendarioScreenDState();
}

class _CalendarioScreenDState extends State<CalendarioTD> {
  dynamic _data;
  late List<Tutoria> _filteredTutorias;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTutorias();
    _filteredTutorias = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Tutorías'),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                _filterTutorias(query);
              },
              decoration: const InputDecoration(
                hintText:
                    'Buscar por: FECHA,CURSO,TEMATICA, MODALIDAD,LUGAR O METEOLOGIA',
                helper: Text(
                    'Buscar por: FECHA,CURSO,TEMATICA, MODALIDAD,LUGAR O METEOLOGIA'),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: _filteredTutorias.isNotEmpty
                ? _buildTutoriasList()
                : const Center(
                    child: Text(
                      'No hay tutorías con esa información',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _filterTutorias(String query) {
    if (_data is List<dynamic>) {
      final filteredTutorias = _data.where((tutoria) {
        final fechaTutoria = tutoria['FECHATUTORIA']?.toLowerCase() ?? '';
        final nombresEstudiante = tutoria['NOMBRES']?.toLowerCase() ?? '';
        final nombreCurso = tutoria['NOMBREDELCURSO']?.toLowerCase() ?? '';
        final profesorResponsable =
            tutoria['PROFESORRESPONSABLE']?.toLowerCase() ?? '';
        final tematica = tutoria['TEMATICA']?.toLowerCase() ?? '';
        final modalidad = tutoria['MODALIDAD']?.toLowerCase() ?? '';
        final lugar = tutoria['LUGAR']?.toLowerCase() ?? '';
        final metodologia = tutoria['METODOLOGIA']?.toLowerCase() ?? '';

        // Verifica si alguno de los campos contiene la consulta
        return fechaTutoria.contains(query.toLowerCase()) ||
            nombresEstudiante.contains(query.toLowerCase()) ||
            nombreCurso.contains(query.toLowerCase()) ||
            profesorResponsable.contains(query.toLowerCase()) ||
            tematica.contains(query.toLowerCase()) ||
            modalidad.contains(query.toLowerCase()) ||
            lugar.contains(query.toLowerCase()) ||
            metodologia.contains(query.toLowerCase());
      }).toList();

      setState(() {
        _filteredTutorias = List<Tutoria>.from(
          filteredTutorias.map(
            (tutoria) => Tutoria(
              fechaTutoria: tutoria['FECHATUTORIA'] ?? '',
              nombresEstudiante: tutoria['NOMBRES'] ?? '',
              nombreCurso: tutoria['NOMBREDELCURSO'] ?? '',
              profesorResponsable: tutoria['PROFESORRESPONSABLE'] ?? '',
              tematica: tutoria['TEMATICA'] ?? '',
              modalidad: tutoria['MODALIDAD'] ?? '',
              lugar: tutoria['LUGAR'] ?? '',
              metodologia: tutoria['METODOLOGIA'] ?? '',
            ),
          ),
        );
      });
    } else {}
  }

  Widget _buildTutoriasList() {
    if (_data == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      );
    }

    if (_data is Map<String, dynamic> && _data!['error'] != null) {
      return Center(child: Text('Error: ${_data!['error']}'));
    }

    return ListView.builder(
      itemCount: _filteredTutorias.length,
      itemBuilder: (context, index) {
        final tutoria = _filteredTutorias[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: _getColorForMetodologia(tutoria.metodologia),
                width: 3.0,
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fecha: ${_formatFecha(tutoria.fechaTutoria)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Estudiante: ${tutoria.nombresEstudiante}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Curso: ${tutoria.nombreCurso}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Profesor: ${tutoria.profesorResponsable}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Temática: ${tutoria.tematica}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Modalidad: ${tutoria.modalidad}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Lugar: ${tutoria.lugar}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Metodología: ${tutoria.metodologia}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatFecha(String fecha) {
    return fecha;
  }

  Color _getColorForMetodologia(String metodologia) {
    return metodologia == 'Individual' ? Colors.orange : Colors.green;
  }

  Future<void> _fetchTutorias() async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasCalendarioGrupo'),
        body: {'DOC_DOC': globalCodigoDocente},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // Verifica si la respuesta es una lista
        if (responseData is List<dynamic>) {
          setState(() {
            _data = responseData
                .map((tutoria) {
                  try {
                    return Tutoria(
                      fechaTutoria: tutoria['FECHATUTORIA'],
                      nombresEstudiante: tutoria['NOMBRE'],
                      nombreCurso: tutoria['NOMBREDELCURSO'],
                      profesorResponsable: tutoria['PROFESOR'],
                      tematica: tutoria['TEMATICA'],
                      modalidad: tutoria['MODALIDAD'],
                      lugar: tutoria['LUGAR'],
                      metodologia: tutoria['METODOLOGIA'],
                    );
                  } catch (e) {
                    return null; // Devuelve null en caso de error
                  }
                })
                .whereType<Tutoria>()
                .toList(); // Filtra los nulos
            _filteredTutorias = _data; // Asigna los datos filtrados
          });
        } else {}
      } else {}
      // ignore: empty_catches
    } catch (e) {}
  }
}
