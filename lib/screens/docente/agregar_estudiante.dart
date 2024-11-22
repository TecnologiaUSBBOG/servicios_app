import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:servicios/globals.dart';
import 'package:servicios/screens/docente/sesion_g.dart';
import 'package:servicios/screens/funcionalidad.dart';

class AgregarEstudianteScreen extends StatefulWidget {
  final String idGrupo;

  const AgregarEstudianteScreen({super.key, required this.idGrupo});

  @override
  State<AgregarEstudianteScreen> createState() =>
      _AgregarEstudianteScreenState();
}

class _AgregarEstudianteScreenState extends State<AgregarEstudianteScreen> {
  Funcionalidad alert = Funcionalidad();

  // Data variables
  List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> _filteredData = [];
  final List<Map<String, dynamic>> _selectedStudents = [];
  List<bool> _isCheckedList = [];

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data when the widget is initialized
  }

  Future<void> fetchData() async {
    final response = await http.post(
      Uri.parse(
        'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasListaEstudiantes',
      ),
      body: {'DOC_DOC': globalCodigoDocente},
    );

    if (response.statusCode == 200) {
      setState(() {
        List<dynamic> jsonResponse = json.decode(response.body);
        _data = jsonResponse
            .map((item) {
              return {
                'DOCUMENTO': item['DOCUMENTO'],
                'CODIGOESTUDIANTIL': item['CODIGOESTUDIANTIL'],
                'PRIMER_NOMBRE': item['PRIMER_NOMBRE'],
                'SEGUNDO_NOMBRE': item['SEGUNDO_NOMBRE'].trim(),
                'PRIMER_APELLIDO': item['PRIMER_APELLIDO'],
                'SEGUNDO_APELLIDO': item['SEGUNDO_APELLIDO'].trim(),
              };
            })
            .toList()
            .cast<Map<String, dynamic>>();

        _filteredData =
            _data; // Inicializa los datos filtrados con todos los datos
        _isCheckedList = List<bool>.filled(
            _data.length, false); // Inicializa la lista de checkboxes
      });
    } else {
      throw Exception('Falla al cargar la data');
    }
  }

  void _filterData(String query) {
    setState(() {
      _filteredData = _data
          .where((item) =>
              item.values.any((value) => value.toString().contains(query)))
          .toList();
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      _isCheckedList[index] = !_isCheckedList[index];
      if (_isCheckedList[index]) {
        _selectedStudents.add(_filteredData[index]);
      } else {
        _selectedStudents.removeWhere((student) =>
            student['DOCUMENTO'] == _filteredData[index]['DOCUMENTO']);
      }
    });
  }

  void _navigateToDetailsPage(String ciclo, String documento) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const AgregarEstudianteScreen(idGrupo: 'tu_id_grupo_aqui'),
      ),
    );
  }

  Future<void> agregarEstudiante(
      String nombreEst, String idGrupo, String documentoEst) async {
    if (idGrupo.isEmpty || nombreEst.isEmpty) {
      throw Exception(
          'El ID del grupo o el nombre del estudiante no pueden estar vacíos.');
    }

    const url =
        'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasAgregarEstudiantesGrupos';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'DOCUMENTOP': globalCodigoDocente,
          'NOMBRE_EST': nombreEst,
          'DOCUMENTO_EST': documentoEst,
          'ID_GRUPO': idGrupo,
        },
      );
      if (response.statusCode == 200) {
        final respuesta = json.decode(response.body);

        // Verifica si la respuesta contiene el campo 'value'
        if (respuesta['value'] != null) {
          if (respuesta['value'] == true) {
            // ignore: use_build_context_synchronously
            alert.showAlertDialogError(context, 'Error Encontrado',
                'El estudiante $nombreEst ya se encuentra en grupo');
          } else if (respuesta['value'] == false) {
            alert.showAlertDialogSuccess(
              // ignore: use_build_context_synchronously
              context,
              'Estudiante agregado',
              'El estudiante fue agregado a la tutoría, recuerda que para crear una sesión al menos debe tener 2 estudiantes.',
              'pro',
              (BuildContext context) => SesionGVScreenD(idGrupo: idGrupo),
            );
          }
        } else {
          throw Exception('Respuesta inesperada del servidor.');
        }
      } else {
        throw Exception(
            'Falla en agregar el estudiante. Código de error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falla en agregar el estudiante: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Estudiante'),
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
              onChanged: _filterData,
              decoration: const InputDecoration(
                labelText: 'Buscar',
                hintText: 'Ingrese el código o Documento del estudiante',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              for (var student in _selectedStudents) {
                String nombreEstudinate =
                    '${student['PRIMER_NOMBRE']} ${student['SEGUNDO_NOMBRE']} ${student['PRIMER_APELLIDO']} ${student['SEGUNDO_APELLIDO']}';
                agregarEstudiante(nombreEstudinate, widget.idGrupo,
                    student['DOCUMENTO'].toString());
              }
              _selectedStudents.clear();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
            child: const Text(
              'Agregar Estudiante',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: Theme(
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
                    header: const Text(
                      'Listado estudiantes',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    rowsPerPage: 15, // Número de filas por página
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text(
                          'Seleccionar',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'DOCUMENTO',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'CODIGO ',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'ESTUDIANTIL',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      DataColumn(
                        label: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'NOMBRE',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'COMPLETO',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ],
                    source: DynamicDataSource(
                      _filteredData,
                      _selectedStudents,
                      _isCheckedList,
                      _toggleSelection,
                      _navigateToDetailsPage,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DynamicDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final List<Map<String, dynamic>> selectedStudents;
  final List<bool> isCheckedList;
  final Function(int) toggleSelection;
  final Function(String, String) onTap;

  DynamicDataSource(this.data, this.selectedStudents, this.isCheckedList,
      this.toggleSelection, this.onTap);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final rowData = data[index];

    return DataRow(
      cells: <DataCell>[
        DataCell(
          Checkbox(
            value: isCheckedList[index],
            onChanged: (bool? value) {
              toggleSelection(index);
            },
          ),
        ),
        DataCell(Text(rowData['DOCUMENTO'].toString())),
        DataCell(Text(rowData['CODIGOESTUDIANTIL']
            .toString())), // Imprime el código estudiantil
        DataCell(Text(
          '${rowData['PRIMER_NOMBRE']} ${rowData['SEGUNDO_NOMBRE'].trim()} ${rowData['PRIMER_APELLIDO']} ${rowData['SEGUNDO_APELLIDO'].trim()}',
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount =>
      selectedStudents.length; // Ajusta esto si es necesario
}
