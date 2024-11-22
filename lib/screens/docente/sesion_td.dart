//
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:servicios/globals.dart';
import 'package:servicios/screens/docente/crear_td.dart';
import 'package:servicios/screens/docente/detalle_td.dart';
import 'package:servicios/screens/docente/update_sesion_ind.dart';
import 'package:servicios/screens/funcionalidad.dart';

class SesionTDScreenD extends StatefulWidget {
  final String ciclo;
  final String documento;

  const SesionTDScreenD({
    super.key,
    required this.ciclo,
    required this.documento,
  });

  @override
  State<SesionTDScreenD> createState() => _SesionTDScreenDState();
}

class _SesionTDScreenDState extends State<SesionTDScreenD> {
  Funcionalidad alert = Funcionalidad();
  List<Map<String, dynamic>> _sessionDetails = [];
  bool _isLoading = true;
  String _searchText = '';
  bool _mostrarFormulario = false;

  final TextEditingController _cicloController = TextEditingController();
  final TextEditingController _tipoTutoriaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cicloController.text = widget.ciclo;
    fetchSessionDetails(widget.ciclo, widget.documento);

    // Recibe el parámetro al regresar desde la pantalla anterior para poder recargar
    Future.delayed(Duration.zero, () {
      final shouldReload =
          // ignore: use_build_context_synchronously
          ModalRoute.of(context)?.settings.arguments as bool? ?? false;
      if (shouldReload) {
        _recargarPaginaActual();
      }
    });
  }

  // Método para recargar la página actual
  void _recargarPaginaActual() {
    setState(() {
      fetchSessionDetails(widget.ciclo, widget.documento);
    });
  }

  Future<void> fetchSessionDetails(String ciclo, String documento) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse(
        'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasEstudianteConT',
      ),
      body: {
        'DOC_EST': documento,
        'CICLO': ciclo,
        'DOC_DOC': globalCodigoDocente,
      },
    );

    if (response.statusCode == 200) {
      try {
        dynamic jsonData = json.decode(response.body);
        if (jsonData is List) {
          setState(() {
            _sessionDetails = List<Map<String, dynamic>>.from(
              jsonData.map((item) => Map<String, dynamic>.from(item)).toList(),
            );
            _isLoading = false;

            if (_sessionDetails.isNotEmpty) {
              _tipoTutoriaController.text =
                  _sessionDetails[0]['TIPOTUTORIA']?.toString() ?? '';
            }
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        // Imprime el cuerpo de la respuesta para depurar
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load session details');
    }
  }

  void _navigateToDetalleScreen(
      String sesion, String nombreCurso, String fechaTutoria, String curso) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetalleTDScreenD(
          ciclo: widget.ciclo,
          documento: widget.documento,
          sesion: sesion,
          nombreCurso: nombreCurso,
          fechaTutoria: fechaTutoria,
          curso: curso,
        ),
      ),
    );
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Sesión'),
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
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No hay ninguna sesión para el estudiante',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CrearTDScreenD(
                                ciclo: widget.ciclo,
                                documento: widget.documento,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text(
                          'Crear sesión de tutoría',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Buscar tutorías',
                          hintText: 'Ingrese el Nombre de la Asignatura',
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
                              builder: (context) => CrearTDScreenD(
                                ciclo: widget.ciclo,
                                documento: widget.documento,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text(
                          'Crear sesión de tutoría',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSectionTitle('Tutorías disponibles'),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
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
                              columnSpacing: 12,
                              columns: const [
                                DataColumn(
                                    label: Text('DETALLE',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('SESION',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                      Text('PERIODO ',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold)),
                                      Text('ACADEMICO',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold))
                                    ])),
                                DataColumn(
                                    label: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                      Text('TIPO',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold)),
                                      Text('TUTORIA',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold))
                                    ])),
                                DataColumn(
                                    label: Text('FACULTAD',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('PROGRAMA',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('NOMBRE CURSO',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('PROFESOR RESPONSABLE',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('TEMATICA',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('MODALIDAD',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('METODOLOGIA',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('FECHA TUTORIA',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('LUGAR',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('DOCUMENTO',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))),
                              ],
                              rows: _searchResults()
                                  .map(
                                    (session) => DataRow(
                                      cells: [
                                        DataCell(
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.info),
                                                onPressed: () {
                                                  _navigateToDetalleScreen(
                                                    session['NUMEROSESION']
                                                        .toString(),
                                                    session['NOMBREDELCURSO']
                                                        .toString(),
                                                    session['FECHATUTORIA']
                                                        .toString(),
                                                    session['NOMBREDELCURSO']
                                                        .toString(),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit_square,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () {
                                                  updatetutoria(
                                                      session['NUMEROSESION']
                                                          .toString(),
                                                      session['PERIODOACADEMICO']
                                                          .toString(),
                                                      session['TIPOTUTORIA']
                                                          .toString(),
                                                      session['FACULTAD']
                                                          .toString(),
                                                      session['PROGRAMA']
                                                          .toString(),
                                                      session['NOMBREDELCURSO']
                                                          .toString(),
                                                      session['PROFESORRESPONSABLE']
                                                          .toString(),
                                                      session['TEMATICA']
                                                          .toString(),
                                                      session['MODALIDAD']
                                                          .toString(),
                                                      session['METODOLOGIA']
                                                          .toString(),
                                                      session['LUGAR']
                                                          .toString(),
                                                      session['FECHATUTORIA']
                                                          .toString(),
                                                      session['DOCUMENTO']
                                                          .toString());
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(Text(session['NUMEROSESION']
                                            .toString())),
                                        DataCell(Text(
                                            session['PERIODOACADEMICO']
                                                .toString())),
                                        DataCell(SizedBox(
                                            width: 80,
                                            child: Text(session['TIPOTUTORIA']
                                                .toString()))),
                                        DataCell(Text(
                                            session['FACULTAD'].toString())),
                                        DataCell(Text(
                                            session['PROGRAMA'].toString())),
                                        DataCell(Text(session['NOMBREDELCURSO']
                                            .toString())),
                                        DataCell(Text(
                                            session['PROFESORRESPONSABLE']
                                                .toString())),
                                        DataCell(SizedBox(
                                            width: 200,
                                            child: Text(session['TEMATICA']
                                                .toString()))),
                                        DataCell(Text(
                                            session['MODALIDAD'].toString())),
                                        DataCell(Text(
                                            session['METODOLOGIA'].toString())),
                                        DataCell(Text(session['FECHATUTORIA']
                                            .toString())),
                                        DataCell(
                                            Text(session['LUGAR'].toString())),
                                        DataCell(Text(
                                            session['DOCUMENTO'].toString())),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: _mostrarFormulario
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _mostrarFormulario = false;
                });
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.close),
            )
          : null,
    );
  }

  void updatetutoria(
      String numerosesion,
      String periodoacademico,
      String tipotutoria,
      String facultad,
      String programa,
      String curso,
      String profesor,
      String tematica,
      String modalidad,
      String metologia,
      String lugar,
      String fechaTutoria,
      String documento) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => UpdateSesionIndScreenD(
              numerosesion: numerosesion,
              periodoacademico: periodoacademico,
              tipotutoria: tipotutoria,
              facultad: facultad,
              programa: programa,
              curso: curso,
              profesor: profesor,
              tematica: tematica,
              modalidad: modalidad,
              metologia: metologia,
              lugar: lugar,
              fechaTutoria: fechaTutoria,
              documento: documento)),
    );
  }
}
