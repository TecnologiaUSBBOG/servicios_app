import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:servicios/screens/docente/crear_dgd.dart';
import 'package:servicios/screens/docente/update_detalle_dg.dart';

class DetalleTDScreenD extends StatefulWidget {
  final String sesion;
  final String groupID;
  final String curso;
  final String tematica;
  final String fechaTutoria;
  final List<Map<String, dynamic>> filterestudiantes;

  const DetalleTDScreenD({
    super.key,
    required this.sesion,
    required this.groupID,
    required this.curso,
    required this.tematica,
    required this.fechaTutoria,
    required this.filterestudiantes,
  });

  @override
  State<DetalleTDScreenD> createState() => _DetalleTDScreenDState();
}

class _DetalleTDScreenDState extends State<DetalleTDScreenD> {
  // final TextEditingController? _nombreCursoController = TextEditingController();
  // ignore: unnecessary_nullable_for_final_variable_declarations
  final TextEditingController? _nombreEstudianteController =
      TextEditingController();
  // ignore: unnecessary_nullable_for_final_variable_declarations
  final TextEditingController? _sesionController = TextEditingController();
  // ignore: unnecessary_nullable_for_final_variable_declarations
  final TextEditingController? _idgrupoController = TextEditingController();

  List<Map<String, dynamic>> _sessionDetails = [];
  bool _isLoading = true;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    fetchSessionDetails(widget.sesion, widget.groupID);
    _nombreEstudianteController!.text = '';
    _sesionController!.text = widget.sesion;
    _idgrupoController!.text = widget.groupID;
  }

  List<Map<String, dynamic>> _searchResults() {
    if (_searchText.isEmpty) {
      return _sessionDetails;
    } else {
      return _sessionDetails.where((session) {
        return session.values.any((value) =>
            value.toString().toLowerCase().contains(_searchText.toLowerCase()));
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detallado'),
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            )
          : _sessionDetails.isEmpty
              ? Container(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Sesión ${widget.sesion} del curso de ${widget.curso}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Temática a tratar: ${widget.tematica}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'No se encuentra ningun detallado creado actualmente. Cree un detalle ahora.',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CrearDGDScreenD(
                                    sesion: widget.sesion,
                                    groupID: widget.groupID,
                                    fechaTuto: widget.fechaTutoria,
                                    tematica: widget.tematica,
                                    curso: widget.curso),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text(
                            'Crear detalle',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Buscar',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchText = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CrearDGDScreenD(
                                  sesion: widget.sesion,
                                  groupID: widget.groupID,
                                  fechaTuto: widget.fechaTutoria,
                                  tematica: widget.tematica,
                                  curso: widget.curso),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text(
                          'Crear detalle ',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dataTableTheme: DataTableThemeData(
                              headingRowColor: WidgetStateColor.resolveWith(
                                (states) => Colors.orange,
                              ),
                            ),
                          ),
                          child: DataTable(
                            columnSpacing: 8,
                            dataRowMaxHeight: double.infinity,
                            dataRowMinHeight: 10,
                            columns: const [
                              DataColumn(
                                  label: Text('Moficar',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Inicio Tutoria',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Fin Tutoria',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                    Text('Nombres ',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold)),
                                    Text('Completos',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))
                                  ])),
                              DataColumn(
                                  label: Text('Codigo',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Documento',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Actividad realizada',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Acuerdos y compromisos',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Asistencia',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Estado Calificacion',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold))),
                            ],
                            rows: _searchResults()
                                .map(
                                  (session) => DataRow(
                                    cells: [
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit_square,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () {
                                            updatetutoria(
                                                session['SESION'].toString(),
                                                session['FECHAINICIO']
                                                    .toString(),
                                                session['FECHAFINAL']
                                                    .toString(),
                                                session['CODIGOESTUDIANTIL']
                                                    .toString(),
                                                session['ACTIVIDADREALIZADA']
                                                    .toString(),
                                                session['ACUERDOSCOMPROMISOS']
                                                    .toString(),
                                                session['ASISTENCIA']
                                                    .toString(),
                                                session['NOMBREESTUDIANTE']
                                                    .toString(),
                                                widget.groupID);
                                          },
                                        ),
                                      ),
                                      DataCell(SizedBox(
                                          width: 100,
                                          child: Text(session['FECHAINICIO']
                                              .toString()))),
                                      DataCell(SizedBox(
                                          width: 130,
                                          child: Text(session['FECHAFINAL']
                                              .toString()))),
                                      DataCell(SizedBox(
                                          width: 130,
                                          child: Text(
                                              session['NOMBREESTUDIANTE']
                                                  .toString()))),
                                      DataCell(Text(session['CODIGOESTUDIANTIL']
                                          .toString())),
                                      DataCell(Text(
                                          session['DOCUMENTOESTUDIANTE']
                                              .toString())),
                                      DataCell(SizedBox(
                                          width: 200,
                                          child: Text(
                                              session['ACTIVIDADREALIZADA']
                                                  .toString()))),
                                      DataCell(SizedBox(
                                          width: 130,
                                          child: Text(
                                              session['ACUERDOSCOMPROMISOS']
                                                  .toString()))),
                                      DataCell(Text(
                                          session['ASISTENCIA'].toString())),
                                      DataCell(Text(
                                          session['ESTADOCALIFICACION']
                                              .toString())),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  void updatetutoria(
      String detalle,
      String fechainicio,
      String fechafin,
      String codigoestudiantil,
      String actividad,
      String acuerdos,
      String asistencia,
      String nombreestudiante,
      String idGrupo) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => UpdateDetalleGDScreenD(
        iddetallesession: detalle,
        fechainicio: fechainicio,
        fechafin: fechafin,
        actividad: actividad,
        acuerdos: acuerdos,
        asistencia: asistencia,
        codigoestudiantil: codigoestudiantil,
        nombreestudiante: nombreestudiante,
        idGrupo: idGrupo,
      ),
    ));
  }

  Future<void> fetchSessionDetails(String sesion, String groupID) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse(
          'https://academia.usbbog.edu.co/centralizacion_servicios_ios/API/Tutorias/DocentesTutoria/DetalleTutoriaGrupal.php'),
      body: {
        'SESION': sesion,
        'ID_GRUPO': groupID,
      },
    );

    if (response.statusCode == 200) {
      dynamic jsonData = json.decode(response.body);
      if (jsonData is List) {
        setState(() {
          _sessionDetails = List<Map<String, dynamic>>.from(
              jsonData.map((item) => Map<String, dynamic>.from(item)).toList());
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load session details');
    }
  }
}
