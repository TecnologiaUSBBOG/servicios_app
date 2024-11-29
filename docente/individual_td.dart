import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:servicios/globals.dart';
import 'package:servicios/screens/docente/sesion_td.dart';

class IndividualTutoriaScreen extends StatefulWidget {
  const IndividualTutoriaScreen({super.key});

  @override
  State<IndividualTutoriaScreen> createState() =>
      _IndividualTutoriaScreenState();
}

class _IndividualTutoriaScreenState extends State<IndividualTutoriaScreen> {
  List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> _filteredData = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.post(
        Uri.parse(
          'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasDListadoDeEstudiantes',
        ),
        body: {'DOC_DOC': globalCodigoDocente},
      );

      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        List<dynamic> jsonData = json.decode(response.body);
        // Convertir el JSON a una lista de mapas
        setState(() {
          _data = List<Map<String, dynamic>>.from(jsonData);
          _filteredData = _data;
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      // Manejo de errores
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

  void _navigateToDetailsPage(String ciclo, String documento) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SesionTDScreenD(
          ciclo: ciclo,
          documento: documento,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutoría Individual'),
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
                hintText: 'Ingrese el codigo o Documento del estudiante',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
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
                          (states) => const Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ),
                  child: PaginatedDataTable(
                    columnSpacing: 8,
                    dataRowMaxHeight: double.infinity,

                    header: const Text(
                      'Listado estudiantes tutorías',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    rowsPerPage: 15, // Número de filas por página
                    columns: const <DataColumn>[
                      DataColumn(
                          label: Text('VER MÁS',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('CICLO',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('DOCUMENTO',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Text('CODIGO ',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            Text('ESTUDIANTIL',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold))
                          ])),
                      DataColumn(
                          label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Text('PRIMER',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            Text('NOMBRE',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold))
                          ])),
                      DataColumn(
                          label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Text('SEGUNDO ',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            Text('NOMBRE',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold))
                          ])),
                      DataColumn(
                          label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Text('PRIMER ',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            Text('APELLIDO',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold))
                          ])),
                      DataColumn(
                          label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Text('SEGUNDO',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            Text('APELLIDO',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold))
                          ])),
                      DataColumn(
                          label: Text('CORREO PERSONAL',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('CORREO INSTITUCIONAL',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('PROGRAMA',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('VINCULACION',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('FACULTAD',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold))),
                    ],
                    source: DynamicDataSource(
                      _filteredData,
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
  final Function(String, String) onTap;
  final int _selectedRowCount = 0;

  DynamicDataSource(this.data, this.onTap);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final rowData = data[index];
    return DataRow(cells: <DataCell>[
      DataCell(
        IconButton(
          icon: const Icon(Icons.remove_red_eye_sharp, color: Colors.green),
          onPressed: () {
            onTap(rowData['CICLO'].toString(), rowData['DOCUMENTO'].toString());
          },
        ),
      ),
      DataCell(Text(rowData['CICLO'].toString())),
      DataCell(Text(rowData['DOCUMENTO'].toString())),
      DataCell(Text(rowData['CODIGOESTUDIANTIL'].toString())),
      DataCell(Text(rowData['PRIMERNOMBRE'].toString())),
      DataCell(Text(rowData['SEGUNDONOMBRE'].toString())),
      DataCell(Text(rowData['PRIMERAPELLIDO'].toString())),
      DataCell(Text(rowData['SEGUNDOAPELLIDO'].toString())),
      DataCell(Text(rowData['CORREOPERSONAL'].toString())),
      DataCell(Text(rowData['CORREOINSTITUCIONAL'].toString())),
      DataCell(Text(rowData['PROGRAMA'].toString())),
      DataCell(Text(rowData['VINCULACION'].toString())),
      DataCell(Text(rowData['FACULTAD'].toString())),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => _selectedRowCount;
}
