// ignore: file_names
// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:servicios/screens/estudiante/credito_e.dart';
import 'package:servicios/screens/estudiante/simulador_e.dart';
import 'package:servicios/screens/estudiante/tutoria_e.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth.dart';
import '../../globals.dart';
import '../login.dart';
import 'credenciales_e.dart';
import 'icetex_e.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HorarioEScreenE(),
    );
  }
}

class HorarioEScreenE extends StatefulWidget {
  const HorarioEScreenE({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HorarioEScreenEState createState() => _HorarioEScreenEState();
}

class _HorarioEScreenEState extends State<HorarioEScreenE> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _originalHorarioData = [];
  List<dynamic> _filteredHorarioData = [];

  @override
  void initState() {
    super.initState();
    _fetchHorarioData();
  }

  void _filterHorarioData(String query) {
    setState(() {
      _filteredHorarioData = _originalHorarioData
          .where((horario) =>
              horario['datos'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horario de Clases'),
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
      drawer: const MyDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterHorarioData,
              decoration: const InputDecoration(
                labelText: 'Buscar',
                hintText: 'Ingrese el Nombre de la Asignatura',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _buildHorarioList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHorarioList() {
    if (_filteredHorarioData.isEmpty) {
      return const Center(
        child: Text(
          'No hay datos disponibles',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredHorarioData.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(
              _filteredHorarioData[index]['datos'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Día: ${_filteredHorarioData[index]['fecha_inicio_dia'].trim()}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hora: ${_filteredHorarioData[index]['fecha_inicio']} - ${_filteredHorarioData[index]['fecha_fin']}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchHorarioData() async {
    try {
      final String codigo = globalCodigoEstudiante;
      final response = await http.post(
        Uri.parse(
            'http://apps.usbbog.edu.co:8080/prod/usbbogota/Horario/HorarioEstudante'),
        body: {'Codigo': codigo},
      );

      if (response.statusCode == 200) {
        List<dynamic> horarioData = json.decode(response.body);
        setState(() {
          _originalHorarioData = horarioData;
          _filteredHorarioData = horarioData;
        });
      } else {
        _showError('Error al cargar el horario');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.orange),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/logo_acreditacion.png',
                        width: 300.0,
                        height: 80.0,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        globalUsername ?? 'Nombre de Usuario',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDrawerItem(
                  context,
                  Icons.schedule,
                  'Horario de Clases',
                  const HorarioEScreenE(),
                ),
                _buildDrawerItem(
                  context,
                  Icons.group,
                  'Solicitar Tutoría',
                  const TutoriaEScreenE(),
                ),
                _buildDrawerItem(
                  context,
                  Icons.attach_money,
                  'Simulador Financiero',
                  const SimuladorEScreenE(),
                ),
                _buildDrawerItem(
                  context,
                  Icons.rotate_left,
                  'Renovación ICETEX',
                  const IcetexEScreenE(),
                ),
                _buildDrawerItem(
                  context,
                  Icons.check,
                  'Crédito Directo USB',
                  const CreditoEScreenE(),
                ),
                ListTile(
                  leading: const Icon(Icons.checklist_rtl),
                  title: const Text('Evaluaciones Profesores'),
                  onTap: () {
                    const String enlaceEvaluacion =
                        'https://campus.usbco.edu.co/psp/USCS90PR/EMPLOYEE/HRMS/c/USB_LINKDOCTE_MNU.USB_DCTELINK_CMP.GBL';
                    _abrirEnlace(enlaceEvaluacion);
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.lock,
                  'Restablecer Credenciales',
                  const CredencialesEScreenE(),
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Cerrar Sesión'),
                  onTap: () {
                    Navigator.pop(context);
                    AuthManager.logout();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginView()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cerrando sesión...'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.orange,
            child: Text(
              appVersion,
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(
      BuildContext context, IconData icon, String title, Widget destination) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }

  Future<void> _abrirEnlace(String enlaceEvaluacion) async {
    if (await canLaunch(enlaceEvaluacion)) {
      await launch(enlaceEvaluacion);
    } else {
      throw 'No se pudo abrir el enlace $enlaceEvaluacion';
    }
  }
}
