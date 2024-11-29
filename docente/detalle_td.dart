import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:servicios/globals.dart';
import 'package:servicios/screens/docente/crear_dd.dart';
import 'package:servicios/screens/docente/update_detalle_td.dart';

class DetalleTDScreenD extends StatefulWidget {
  final String ciclo;
  final String documento;
  final String sesion;
  final String nombreCurso;
  final String fechaTutoria;
  final String curso;

  const DetalleTDScreenD(
      {super.key,
      required this.ciclo,
      required this.documento,
      required this.sesion,
      required this.nombreCurso,
      required this.fechaTutoria,
      required this.curso});

  @override
  State<DetalleTDScreenD> createState() => _DetalleTDScreenDState();
}

class _DetalleTDScreenDState extends State<DetalleTDScreenD> {
  // ignore: unnecessary_nullable_for_final_variable_declarations
  final TextEditingController? _nombreCursoController = TextEditingController();
  // ignore: unnecessary_nullable_for_final_variable_declarations
  final TextEditingController? _nombreEstudianteController =
      TextEditingController();
  // ignore: unnecessary_nullable_for_final_variable_declarations
  final TextEditingController? _codigoEstudianteController =
      TextEditingController();
  // ignore: unnecessary_nullable_for_final_variable_declarations
  final TextEditingController? _fechaTutoriaController =
      TextEditingController();
  // ignore: unnecessary_nullable_for_final_variable_declarations
  final TextEditingController? _cursoController = TextEditingController();

  List<Map<String, dynamic>> _sessionDetails = [];
  bool _isLoading = true;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _datosEstudiante(widget.documento);
    fetchSessionDetails(widget.ciclo, widget.documento, widget.sesion);
    _nombreCursoController!.text = widget.nombreCurso;
    _nombreEstudianteController!.text = '';
    _codigoEstudianteController!.text = '';
    _fechaTutoriaController!.text = widget.fechaTutoria;
    _cursoController!.text = widget.curso;
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
              ? SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sesión ${widget.sesion} del curso de ${_nombreCursoController!.text}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Nombre del estudiante ${_nombreEstudianteController!.text}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'No hay ningún detalle para esta sesión. Cree un detalle ahora.',
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
                                  builder: (context) => CrearDDScreenD(
                                    ciclo: widget.ciclo,
                                    documento: widget.documento,
                                    sesion: widget.sesion,
                                    nombre: _nombreEstudianteController.text,
                                    codigoEstudiante:
                                        _codigoEstudianteController!.text,
                                    fechaTutoria: _fechaTutoriaController!.text,
                                    curso: _cursoController!.text,
                                  ),
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
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Sesión ${_sessionDetails[0]['SESION']} del curso de ${_sessionDetails[0]['CURSO']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Buscar',
                            hintText: '',
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
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CrearDDScreenD(
                                  ciclo: widget.ciclo,
                                  documento: widget.documento,
                                  sesion: _sessionDetails[0]['SESION'],
                                  nombre: _sessionDetails[0]
                                      ['NOMBREESTUDIANTE'],
                                  codigoEstudiante: _sessionDetails[0]
                                      ['CODIGO'],
                                  fechaTutoria: _fechaTutoriaController!.text,
                                  curso: _cursoController!.text,
                                ),
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
                      const SizedBox(height: 20),
                      SingleChildScrollView(
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
                                    label: Text('Modificar',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                      Text('NOMBRES ',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold)),
                                      Text('COMPLETOS',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold))
                                    ])),
                                DataColumn(
                                    label: Text('DOCUMENTO',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('CÓDIGO',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('ACTIVIDAD REALIZADA',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('ACUERDOS Y COMPROMISOS',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('INICIO TUTORÍA',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('FIN TUTORÍA',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('ASISTENCIA',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('CALIFICACIÓN HECHA',
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
                                                  session['ID_DETALLADO']
                                                      .toString(),
                                                  session['INICIO_TUTORIA']
                                                      .toString(),
                                                  session['FINAL_TUTORIA']
                                                      .toString(),
                                                  session['CODIGO'].toString(),
                                                  session['ACTIVIDADREALIZADA']
                                                      .toString(),
                                                  session['ACUERDOSYCOMPROMISOS']
                                                      .toString(),
                                                  session['ASISTENCIA']
                                                      .toString(),
                                                  session['NOMBREESTUDIANTE']
                                                      .toString(),
                                                  widget.ciclo,
                                                  widget.nombreCurso,
                                                  widget.sesion,
                                                  widget.curso,
                                                  widget.fechaTutoria,
                                                  session['DOCUMENTO']
                                                      .toString());
                                            },
                                          ),
                                        ),
                                        DataCell(SizedBox(
                                            width: 150,
                                            child: Text(
                                                session['NOMBREESTUDIANTE']
                                                    .toString()
                                                    .trim(),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                )))),
                                        DataCell(SizedBox(
                                            width: 150,
                                            child: Text(
                                                session['DOCUMENTO']
                                                    .toString()
                                                    .trim(),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                )))),
                                        DataCell(
                                            Text(session['CODIGO'].toString())),
                                        DataCell(
                                          SizedBox(
                                            width: 200.0,
                                            //height: 80,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              child: Text(
                                                session['ACTIVIDADREALIZADA']
                                                    .toString(),
                                                overflow: TextOverflow.visible,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 200.0,
                                            //height: 80,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              child: Text(
                                                session['ACUERDOSYCOMPROMISOS']
                                                    .toString(),
                                                overflow: TextOverflow.visible,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(session['INICIO_TUTORIA']
                                            .toString())),
                                        DataCell(Text(session['FINAL_TUTORIA']
                                            .toString())),
                                        DataCell(Text(
                                            session['ASISTENCIA'].toString())),
                                        DataCell(Text(
                                            session['CALIFICACIONESTUDIANTE']
                                                .toString())),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                          )),
                    ],
                  ),
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
      String ciclo,
      String nombreCurso,
      String sesion,
      String curso,
      String fechaTutoria,
      String documento) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => UpdateDetalleTDScreenD(
        iddetallesession: detalle,
        fechainicio: fechainicio,
        fechafin: fechafin,
        actividad: actividad,
        acuerdos: acuerdos,
        asistencia: asistencia,
        codigoestudiantil: codigoestudiantil,
        nombreestudiante: nombreestudiante,
        ciclo: ciclo,
        nombreCurso: nombreCurso,
        sesion: sesion,
        curso: curso,
        fechaTutoria: fechaTutoria,
        documento: documento,
      ),
    ));
  }

  Future<void> fetchSessionDetails(
      String ciclo, String documento, String sesion) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse(
          'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasDetalle'),
      body: {
        'CICLO': ciclo,
        'DOC_EST': documento,
        'SESION': sesion,
        'DOC_DOC': globalCodigoDocente,
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

  Future<void> _datosEstudiante(String documento) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasObtenerDatosEstudiante'),
        body: {'DOC_EST': documento},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List &&
            data.isNotEmpty &&
            data[0]['NOMBRE'] != null &&
            data[0]['CODIGOESTUDIANTIL'] != null) {
          String nombreEstudiante = data[0]['NOMBRE'].toString();
          String codigoEstudiante = data[0]['CODIGOESTUDIANTIL'].toString();
          _nombreEstudianteController!.text = nombreEstudiante;
          _codigoEstudianteController!.text = codigoEstudiante;
        } else {}
      } else {
        throw Exception('Failed to load next session number');
      }
    } catch (error) {
      throw ();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
