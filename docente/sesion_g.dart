import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:servicios/globals.dart';
import 'package:servicios/screens/docente/agregar_estudiante.dart';
import 'package:servicios/screens/docente/detalle_gd.dart';
import 'package:servicios/screens/docente/sesion_gd.dart';
import 'package:servicios/screens/docente/update_session.dart';
import 'package:servicios/screens/funcionalidad.dart';

class SesionGVScreenD extends StatefulWidget {
  final String idGrupo;

  const SesionGVScreenD({super.key, required this.idGrupo});

  @override
  State<SesionGVScreenD> createState() => _SesionGVScreenDState();
}

class _SesionGVScreenDState extends State<SesionGVScreenD> {
  final TextEditingController _searchController = TextEditingController();
  int countest1 = 0;
  int cantidadsession = 0;
  Funcionalidad alert = Funcionalidad();
  List<Map<String, dynamic>> _sessionDetails = [];
  List<Map<String, dynamic>> _originalSessionDetails = [];
  List<Map<String, dynamic>> _filterestudiantes = [];
  bool _isLoading = true;
  bool floatExtended = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _filterData(_searchController.text);
    });
    fetchSessionDetails();
    getNumeroEstudiantes();
    _datosEstudiante();
    getNumeroSessiones();
  }

  void _filterData(String query) {
    setState(() {
      if (query.isEmpty) {
        _sessionDetails =
            List<Map<String, dynamic>>.from(_originalSessionDetails);
      } else {
        _sessionDetails = _originalSessionDetails
            .where((item) => item.values.any((value) =>
                value.toString().toLowerCase().contains(query.toLowerCase())))
            .toList();
      }
    });
  }

  void _navigateToDetalleScreen(String sesion, String groupID, String curso,
      String tematica, String fechaTuto) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetalleTDScreenD(
          sesion: sesion,
          groupID: groupID,
          curso: curso,
          fechaTutoria: fechaTuto,
          tematica: tematica,
          filterestudiantes: _filterestudiantes,
        ),
      ),
    );
  }

  Widget _buildestudiante() {
    if (countest1 >= 2) {
      return _buildSessionList();
    } else {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'No hay suficientes estudiante en grupo, por Favor ingrese estuiantes para poder crear session de tutoria',
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.justify,
              ),
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AgregarEstudianteScreen(
                      idGrupo: widget.idGrupo,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text(
                'Agregar Estudiantes',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (cantidadsession >= 1)
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        dataTableTheme: DataTableThemeData(
                          headingRowColor: WidgetStateColor.resolveWith(
                            (states) => Colors.orange,
                          ),
                          dataRowColor: WidgetStateColor.resolveWith(
                            (states) =>
                                const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                      child: PaginatedDataTable(
                          columnSpacing: 8,
                          dataRowMaxHeight: double.infinity,
                          dataRowMinHeight: 32,
                          rowsPerPage: 4,
                          columns: const <DataColumn>[
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                  Text('TIPO ',
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
                                label: Text('LUGAR',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('DOCUMENTO',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('GRUPO',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('FECHA TUTORIA',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold))),
                          ],
                          source: DatasessionSource(
                              _sessionDetails,
                              context,
                              _navigateToDetalleScreen,
                              updatetutoria,
                              _filterestudiantes)),
                    ),
                  ],
                ),
              )
          ],
        ),
      );
    }
  }

  Widget _buildSessionList() {
    if (_sessionDetails.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.all(6.0),
              child: Text(
                'No hay ninguna sesión disponible. Cree una.',
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SesionGScreenD(
                            idGrupo: widget.idGrupo,
                            estudiantesgrupo: _filterestudiantes),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text(
                    'Crear sesión grupal',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                // const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AgregarEstudianteScreen(
                          idGrupo: widget.idGrupo,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text(
                    'Agregar Estudiantes',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // const SizedBox(height: 20),
          if (countest1 >= 2)
            Center(
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SesionGScreenD(
                              idGrupo: widget.idGrupo,
                              estudiantesgrupo: _filterestudiantes),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      'Crear sesión grupal',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  //const SizedBox(height: 0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AgregarEstudianteScreen(
                            idGrupo: widget.idGrupo,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      'Agregar Estudiantes',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 15),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    dataTableTheme: DataTableThemeData(
                      headingRowColor: WidgetStateColor.resolveWith(
                        (states) => Colors.orange,
                      ),
                      dataRowColor: WidgetStateColor.resolveWith(
                        (states) => const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ),
                  child: PaginatedDataTable(
                      columnSpacing: 8,
                      dataRowMaxHeight: double.infinity,
                      dataRowMinHeight: 32,
                      rowsPerPage: 4,
                      columns: const <DataColumn>[
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
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              Text('TIPO ',
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
                            label: Text('LUGAR',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('DOCUMENTO',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('GRUPO',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('FECHA TUTORIA',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold))),
                      ],
                      source: DatasessionSource(
                          _sessionDetails,
                          context,
                          _navigateToDetalleScreen,
                          updatetutoria,
                          _filterestudiantes)),
                ),
              ],
            ),
          )
        ],
      );
    }
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
      String idGrupo,
      List<Map<String, dynamic>> filterestudiantes) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => UpdateSessionScreenD(
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
          idGrupo: idGrupo,
          estudiantesgrupo: filterestudiantes),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ver Sesiones Grupo'),
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
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cantidadsession != 0)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Buscar sessiones',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                //Padding(
                //padding:const EdgeInsets.all(8.0) ,
                if (_filterestudiantes.isNotEmpty)
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            dataTableTheme: DataTableThemeData(
                              headingRowColor: WidgetStateColor.resolveWith(
                                (states) => Colors.orange,
                              ),
                              dataRowColor: WidgetStateColor.resolveWith(
                                (states) =>
                                    const Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                          child: PaginatedDataTable(
                            columnSpacing: 8,
                            dataRowMaxHeight: double.infinity,
                            dataRowMinHeight: 32,
                            header: const Text(
                              'Estudiantes en El Grupo',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22),
                            ),
                            rowsPerPage: 2,
                            columns: const <DataColumn>[
                              DataColumn(
                                  label: Text('NOMBRE ESTUDIANTE',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('ELIMINAR',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold))),
                            ],
                            source: DynamicDataSource(
                                _filterestudiantes, _removeRow, context),
                          ),
                        ),
                      ],
                    ),
                  ),
                _buildestudiante(),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        hoverColor: Colors.orange,
        elevation: 12,
        tooltip: 'Create Card',
        label: Row(
          children: [
            Column(
              children: [
                IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Column(
                              children: [
                                Icon(Icons.perm_contact_calendar_rounded,
                                    size: 70, color: Colors.blue),
                                SizedBox(height: 20),
                                Text('Estudiantes en grupo'),
                              ],
                            ),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ListView(
                                shrinkWrap: true,
                                children: [
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      dataTableTheme: DataTableThemeData(
                                        headingRowColor:
                                            WidgetStateColor.resolveWith(
                                          (states) => Colors.orange,
                                        ),
                                        dataRowColor:
                                            WidgetStateColor.resolveWith(
                                          (states) => Colors.white,
                                        ),
                                      ),
                                    ),
                                    child: PaginatedDataTable(
                                      columnSpacing: 8,
                                      dataRowMaxHeight: double.infinity,
                                      dataRowMinHeight: 32,
                                      rowsPerPage: 2,
                                      columns: const <DataColumn>[
                                        DataColumn(
                                          label: Text(
                                            'NOMBRE ESTUDIANTE',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'ELIMINAR',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                      source: DynamicDataSource1(
                                        _filterestudiantes,
                                        context,
                                        _removeRow,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'OK',
                                  style: TextStyle(
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.remove_red_eye_sharp,
                        size: 35, color: Colors.green)),
                const Text("Ver Estudiantes",
                    style: TextStyle(color: Colors.black, fontSize: 15)),
              ],
            ),
            const SizedBox(width: 20),
            if (countest1 >= 2)
              Column(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SesionGScreenD(
                                idGrupo: widget.idGrupo,
                                estudiantesgrupo: _filterestudiantes),
                          ),
                        );
                      },
                      icon: const Icon(Icons.group_add,
                          size: 35, color: Colors.blue)),
                  const Text("Session grupal",
                      style: TextStyle(color: Colors.black, fontSize: 15)),
                ],
              ),
            const SizedBox(width: 20),
            Column(children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AgregarEstudianteScreen(
                          idGrupo: widget.idGrupo,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 35, color: Colors.green)),
              const Text(
                "Estudiantes",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ]),
            const SizedBox(width: 20),
          ],
        ),
        isExtended: floatExtended,
        icon: Icon(
          floatExtended == true ? Icons.close : Icons.create,
          color: floatExtended == true ? Colors.red : Colors.black,
        ),
        onPressed: () {
          setState(() {
            floatExtended = !floatExtended;
          });
        },
        backgroundColor: floatExtended == true
            ? Colors.white.withOpacity(.7)
            : Colors.orange.withOpacity(.7),
      ),
    );
  }

  Future<int> getNumeroSessiones() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse(
            'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasCountSession'),
        body: {
          'ID_GRUPO': widget.idGrupo,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Accede directamente al campo CANTIDAD
        if (data['CANTIDAD'] != null) {
          int sessionNumber = int.parse(data['CANTIDAD'].toString());
          setState(() {
            cantidadsession = sessionNumber;
            _isLoading = false;
          });

          return cantidadsession;
        } else {
          setState(() {
            cantidadsession = 0;
            _isLoading = false;
          });
          return cantidadsession;
        }
      } else {
        return 0;
      }
    } catch (e) {
      // Manejo de errores
    }
    return 0;
  }

  Future<int> getNumeroEstudiantes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse(
            'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasCounttest'),
        body: {
          'ID_GRUPO': widget.idGrupo,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Accede directamente al campo CANTIDAD
        if (data['CANTIDAD'] != null) {
          int studentCount = int.parse(data['CANTIDAD'].toString());
          setState(() {
            countest1 = studentCount;
            _isLoading = false;
          });
          return countest1;
        } else {
          setState(() {
            countest1 = 0;
            _isLoading = false;
          });
          return countest1;
        }
      } else {
        return 0;
      }
    } catch (e) {
      // Manejo de errores
    }
    return 0;
  }

  void _removeRow(int index) {
    final rowData = _filterestudiantes[index];
    final groupId = widget.idGrupo;
    final docEstudiante = rowData['CEDULA'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Column(children: [
            Icon(Icons.delete, size: 70, color: Colors.red),
            SizedBox(height: 20),
            Text('Eliminar Estudiante'),
          ]),
          content: SingleChildScrollView(
              child: RichText(
            //textAlign: TextAlign.justify,
            text: const TextSpan(
              text: '¿Está seguro de eliminar este estudiante ?',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteRowOnServer(groupId, docEstudiante);
                setState(() {
                  _filterestudiantes.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _datosEstudiante() async {
    try {
      final response = await http.post(
        Uri.parse(
          'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasObtenerDatosEstudiantesGrupal',
        ),
        body: {'ID_GRUPO': widget.idGrupo},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            json.decode(response.body); // Cambiado a List<dynamic>
        if (data.isNotEmpty) {
          setState(() {
            // Convierte la lista de datos a un mapa
            _filterestudiantes =
                List<Map<String, dynamic>>.from(data.map((item) {
              return {
                'CEDULA': item['CEDULA'],
                'NOMBRES': item['NOMBRES'],
              };
            }));
          });
        }
      } else {
        throw Exception('Failed to load student details');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchSessionDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://academia.usbbog.edu.co/centralizacion_servicios_ios/API/Tutorias/DocentesTutoria/VerSesionGrupal.php'),
        body: {
          'ID_GRUPO': widget.idGrupo,
        },
      );

      if (response.statusCode == 200) {
        dynamic jsonData = json.decode(response.body);
        if (jsonData is List) {
          setState(() {
            _originalSessionDetails = List<Map<String, dynamic>>.from(jsonData
                .map((item) => Map<String, dynamic>.from(item))
                .toList());
            _sessionDetails =
                List<Map<String, dynamic>>.from(_originalSessionDetails);
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
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load session details');
    }
  }

  Future<void> _deleteRowOnServer(String groupId, String docEstudiante) async {
    try {
      final response = await http.post(
        Uri.parse(
          'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasEliminarEstudiante',
        ),
        body: {
          'DOC_EST': docEstudiante,
          'ID_GRUPO': groupId,
          'DOC_DOC': globalCodigoDocente,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verifica si la respuesta indica éxito
        if (data['success'] != null) {
          alert.showAlertDialogSuccess(
            // ignore: use_build_context_synchronously
            context,
            'Eliminar',
            data['success'], // Muestra el mensaje de éxito
            'pro',
            (BuildContext context) => SesionGVScreenD(idGrupo: widget.idGrupo),
          );
        } else {
          // Manejo de error si no hay mensaje de éxito
          alert.showAlertDialogError(
            // ignore: use_build_context_synchronously
            context,
            'Error',
            'No se pudo eliminar al estudiante.',
          );
        }
      } else {
        throw Exception('Failed to delete student');
      }
    } catch (e) {
      // Para depuración
      alert.showAlertDialogError(
        // ignore: use_build_context_synchronously
        context,
        'Error',
        'Ocurrió un error al intentar eliminar al estudiante.',
      );
    }
  }
}

class DatasessionSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final BuildContext context;
  final Function _navigateToDetalleScreen;
  final Function updatetutoria;
  final List<Map<String, dynamic>> _filterestudiantes;
  final int _selectedRowCount = 0;

  DatasessionSource(this.data, this.context, this._navigateToDetalleScreen,
      this.updatetutoria, this._filterestudiantes);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final session = data[index];
    return DataRow(
      cells: <DataCell>[
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.info, color: Colors.green),
                onPressed: () {
                  _navigateToDetalleScreen(
                    session['NUMEROSESION'].toString(),
                    session['GRUPO'].toString(),
                    session['NOMBREDELCURSO'].toString(),
                    session['TEMATICA'].toString(),
                    session['FECHATUTORIA'].toString(),
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
                      session['NUMEROSESION'].toString(),
                      session['PERIODOACADEMICO'].toString(),
                      session['TIPOTUTORIA'].toString(),
                      session['FACULTAD'].toString(),
                      session['PROGRAMA'].toString(),
                      session['NOMBREDELCURSO'].toString(),
                      session['PROFESORRESPONSABLE'].toString(),
                      session['TEMATICA'].toString(),
                      session['MODALIDAD'].toString(),
                      session['METODOLOGIA'].toString(),
                      session['LUGAR'].toString(),
                      session['FECHATUTORIA'].toString(),
                      session['GRUPO'].toString(),
                      _filterestudiantes);
                },
              ),
            ],
          ),
        ),
        DataCell(Text(session['NUMEROSESION'].toString())),
        DataCell(Text(session['PERIODOACADEMICO'].toString())),
        DataCell(SizedBox(
            width: 100, child: Text(session['TIPOTUTORIA'].toString()))),
        DataCell(
            SizedBox(width: 200, child: Text(session['FACULTAD'].toString()))),
        DataCell(Text(session['PROGRAMA'].toString())),
        DataCell(Text(session['NOMBREDELCURSO'].toString())),
        DataCell(Text(session['PROFESORRESPONSABLE'].toString())),
        DataCell(Text(session['TEMATICA'].toString())),
        DataCell(Text(session['MODALIDAD'].toString())),
        DataCell(Text(session['METODOLOGIA'].toString())),
        DataCell(Text(session['LUGAR'].toString())),
        DataCell(Text(session['DOCUMENTOPROFESOR'].toString())),
        DataCell(Text(session['GRUPO'].toString())),
        DataCell(Text(session['FECHATUTORIA'].toString())),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => _selectedRowCount;
}

class DynamicDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final BuildContext context;
  final Function(int) onRemoveRow;

  final int _selectedRowCount = 0;

  DynamicDataSource(this.data, this.onRemoveRow, this.context);

  void removeRow(int index) {
    if (index >= 0 && index < data.length) {
      onRemoveRow(index);
      notifyListeners();
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final rowData = data[index];
    return DataRow(cells: <DataCell>[
      DataCell(SizedBox(
          child: Text(rowData['NOMBRES'].toString(),
              style: const TextStyle(
                fontSize: 13,
              )))),
      DataCell(
        IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () {
            removeRow(index);
          },
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => _selectedRowCount;
}

class DynamicDataSource1 extends DataTableSource {
  final List<Map<String, dynamic>> data1;
  final BuildContext context1;
  final Function(int) onRemoveRow1;

  final int _selectedRowCount = 0;

  DynamicDataSource1(this.data1, this.context1, this.onRemoveRow1);

  void removeRow(int index) {
    if (index >= 0 && index < data1.length) {
      onRemoveRow1(index);
      notifyListeners();
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= data1.length) return null;
    final rowData = data1[index];
    return DataRow(cells: <DataCell>[
      DataCell(SizedBox(
          width: 150,
          child: Text(rowData['NOMBRES'].toString(),
              style: const TextStyle(
                fontSize: 13,
              )))),
      DataCell(
        IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () {
            removeRow(index);
          },
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data1.length;

  @override
  int get selectedRowCount => _selectedRowCount;
}
