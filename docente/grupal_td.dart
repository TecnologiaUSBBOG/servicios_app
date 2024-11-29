import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:servicios/globals.dart';
import 'package:servicios/screens/docente/crear_gd.dart';
import 'package:servicios/screens/docente/sesion_g.dart';
import 'package:servicios/screens/docente/sesion_gd.dart';

import 'package:servicios/screens/estudiante/credenciales_e2.dart';

class GrupalTutoriaScreen extends StatefulWidget {
  const GrupalTutoriaScreen({super.key});

  @override
  State<GrupalTutoriaScreen> createState() => _GrupalTutoriaScreenState();
}

class _GrupalTutoriaScreenState extends State<GrupalTutoriaScreen> {
  List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> _filteredData = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  @override
  void initState() {
    super.initState();
    fetchData1(); // Llama a la función para obtener los datos al iniciar el estado
  }

  void _filterData(String query) {
    setState(() {
      // Filtra los datos basándose en la consulta
      _filteredData = _data.where((item) {
        // Verifica si alguno de los valores del item contiene la consulta
        return item.values.any((value) =>
            value.toString().toLowerCase().contains(query.toLowerCase()));
      }).toList();
    });
  }

  void _navigateToDetailsPage(String idGrupo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SesionGScreenD(
          idGrupo: idGrupo,
          estudiantesgrupo: const [], // Puedes pasar una lista de estudiantes si es necesario
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutoría Grupal'),
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
      body: _filteredData.isNotEmpty
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterData,
                    decoration: const InputDecoration(
                      labelText: 'Buscar',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CrearGrupoTutoriaScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text(
                    'Crear grupo de tutoría',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _filteredData.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No hay grupos creados actualmente',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CrearGrupoTutoriaScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            child: const Text(
                              'Crear grupo de tutoría',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      )
                    : Expanded(
                        child: ListView(
                          children: [
                            Theme(
                              data: Theme.of(context).copyWith(
                                dataTableTheme: DataTableThemeData(
                                  headingRowColor: WidgetStateColor.resolveWith(
                                    (states) => Colors.orange,
                                  ),
                                  dataRowColor: WidgetStateColor.resolveWith(
                                    (states) => const Color.fromARGB(
                                        255, 255, 255, 255),
                                  ),
                                ),
                              ),
                              child: PaginatedDataTable(
                                columnSpacing: 8,
                                dataRowMaxHeight: double.infinity,
                                header: const Text(
                                  'Grupos de tutorías actuales',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                rowsPerPage: 6,
                                columns: const <DataColumn>[
                                  DataColumn(
                                      label: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                        Text('NOMBRE ',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold)),
                                        Text('GRUPO',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold))
                                      ])),
                                  DataColumn(
                                      label: Text('INFO GRUPO',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('ACCIONES',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold))),
                                ],
                                source: DynamicDataSource(
                                  _filteredData,
                                  _navigateToDetailsPage,
                                  _removeRow,
                                  _showUpdateDialog,
                                  context,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No hay grupos creados actualmente',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CrearGrupoTutoriaScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      'Crear grupo de tutoría',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showUpdateDialog(int index) {
    final TextEditingController nombreController = TextEditingController();
    final rowData = _filteredData[index];

    // Asignar el nombre actual al controlador
    nombreController.text =
        rowData['Nombre'] ?? ''; // Asegúrate de usar la clave correcta

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Column(children: [
            Icon(Icons.edit_square, size: 70, color: Colors.blue),
            SizedBox(height: 20),
            Text('Actualizar Grupo'),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Llama a la función para actualizar la fila
                _updateRow(rowData, nombreController.text);
                Navigator.of(context)
                    .pop(); // Cierra el diálogo después de actualizar
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateRow(
    Map<String, dynamic> rowData,
    String nombre,
  ) async {
    final String groupId = rowData['ID_Grupo'] ?? ''; // Manejo del caso nulo

    // Verifica si groupId está vacío
    if (groupId.isEmpty) {
      return; // Salir si falta el parámetro
    }

    try {
      final response = await http.post(
        Uri.parse(
            'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasUpdateGrupo'),
        body: {
          'NOMBRE': nombre,
          'ID_GRUPO': groupId,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] != null) {
          alert.showAlertDialogSuccess(
            // ignore: use_build_context_synchronously
            context,
            'Actualizar grupo',
            jsonResponse['success'],
            'pro',
            (BuildContext context) => const GrupalTutoriaScreen(),
          );
        } else {}
      } else {
        // Detalles adicionales sobre el error
      }
    } catch (e) {
      // Para depuración
      throw Exception('Failed to update group: $e');
    }
  }

  void _removeRow(int index) {
    final rowData = _filteredData[index];
    final groupId = rowData['ID_Grupo'] ?? ''; // Cambia 'ID_GRUPO' a 'ID_Grupo'

    if (groupId.isEmpty) {
      return; // Salir si falta el parámetro
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Column(children: [
            Icon(Icons.delete, size: 70, color: Colors.red),
            SizedBox(height: 20),
            Text('Eliminar Grupo'),
          ]),
          content: SingleChildScrollView(
              child: RichText(
            text: const TextSpan(
              text: '¿Está seguro de eliminar este grupo?',
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
                _deleteRowOnServer(groupId); // Llama a la función para eliminar
                setState(() {
                  _filteredData.removeAt(index); // Elimina la fila de la lista
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchData1() async {
    final response = await http.post(
      Uri.parse(
          'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasListaGrupos'),
      body: {
        'DOC_DOC': globalCodigoDocente,
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);

      setState(() {
        _data = List<Map<String, dynamic>>.from(jsonResponse);
        _filteredData = _data;
      });
    } else {}
  }

  Future<void> _deleteRowOnServer(String groupId) async {
    if (groupId.isEmpty) {
      return; // Salir si falta el parámetro
    }

    try {
      final response = await http.post(
        Uri.parse(
          'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasDeleteGrupo',
        ),
        body: {
          'ID_GRUPO': groupId,
          'DOC_DOC': globalCodigoDocente,
        },
      );

      if (response.statusCode == 200) {
      } else {}
    } catch (e) {
      throw Exception('Failed to delete group: $e');
    }
  }
}

class DynamicDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final Function(String) onTap;
  final Function(int) onRemoveRow;
  final Function(int) onUpdateRow;
  final BuildContext context;

  final int _selectedRowCount = 0;

  DynamicDataSource(
      this.data, this.onTap, this.onRemoveRow, this.onUpdateRow, this.context);

  void removeRow(int index) {
    if (index >= 0 && index < data.length) {
      onRemoveRow(index);
      notifyListeners();
    }
  }

  void updategrouop(int index) {
    if (index >= 0 && index < data.length) {
      onUpdateRow(index);
      notifyListeners();
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final rowData = data[index];
    return DataRow(cells: <DataCell>[
      DataCell(SizedBox(
          width: 100,
          child: Text(
              rowData['Nombre'].toString(), // Cambiado de 'NOMBRE' a 'Nombre'
              style: const TextStyle(
                fontSize: 15,
              )))),
      DataCell(
        IconButton(
          icon: const Icon(Icons.remove_red_eye_sharp, color: Colors.green),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SesionGVScreenD(
                  idGrupo:
                      rowData['ID_Grupo'].toString(), // Cambia aquí también
                ),
              ),
            );
          },
        ),
      ),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              removeRow(index);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_square, color: Colors.blue),
            onPressed: () {
              updategrouop(index);
            },
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => _selectedRowCount;
}
