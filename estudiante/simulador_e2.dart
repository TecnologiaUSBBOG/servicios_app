import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:servicios/screens/estudiante/credito_e.dart';
import 'package:servicios/screens/estudiante/tutoria_e.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth.dart';
import '../../globals.dart';
import '../login.dart';
import 'credenciales_e.dart';
import 'horario_e.dart';
import 'icetex_e.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SimuladorE2ScreenE(
        programaAcademicoID: 'B0001', // Reemplaza con un ID válido
        selectedOpcionFinanciacion:
            'opcion1', // Reemplaza con una opción válida
        cuotaInicial: '1000000', // Reemplaza con un valor válido
        descripcion:
            'Descripción del simulador', // Reemplaza con una descripción válida
      ),
    );
  }
}

class SimuladorE2ScreenE extends StatefulWidget {
  final String programaAcademicoID;
  final String selectedOpcionFinanciacion;
  final String descripcion; // Agregado
  final String cuotaInicial; // Agregado

  const SimuladorE2ScreenE({
    super.key,
    required this.programaAcademicoID,
    required this.selectedOpcionFinanciacion,
    required this.descripcion, // Inicializado
    required this.cuotaInicial, // Inicializado
  });

  @override
  // ignore: library_private_types_in_public_api
  _SimuladorE2ScreenEState createState() => _SimuladorE2ScreenEState();
}

class _SimuladorE2ScreenEState extends State<SimuladorE2ScreenE> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controladores de texto para los campos de entrada
  // Controladores de texto para los campos de entrada
  final TextEditingController _cuotaInicialController = TextEditingController();
  final TextEditingController _financiacionController = TextEditingController();
  final TextEditingController _porcentajeCIController = TextEditingController();
  final TextEditingController _numeroCuotasController = TextEditingController();
  final TextEditingController _interesCteController = TextEditingController();
  final TextEditingController _interesMraController = TextEditingController();

  // Variables para almacenar sumas de capital, interés corriente y valor de cuota
  double _sumaCapital = 0.0;
  double _sumaInteresCorriente = 0.0;
  double _sumaValorCuota = 0.0;

  // Datos del formulario y amortización
// Almacena los datos del formulario
  List<Map<String, dynamic>> _amortizacionData =
      []; // Almacena los datos de amortización

  @override
  void dispose() {
    // Limpia los controladores al eliminar el widget
    _cuotaInicialController.dispose();
    _financiacionController.dispose();
    _porcentajeCIController.dispose();
    _numeroCuotasController.dispose();
    _interesCteController.dispose();
    _interesMraController.dispose();
    super.dispose(); // Llama al método dispose de la clase base
  }

  @override
  void initState() {
    super.initState();

    // Obtener valores iniciales
    getValores(widget.programaAcademicoID, widget.selectedOpcionFinanciacion)
        .then((data) {
      // Verifica si se recibió un objeto válido
      if (data.isNotEmpty) {
        setState(() {
// Asigna los datos recibidos a _formData

          // Ajusta el acceso a las claves según el nuevo formato JSON
          _cuotaInicialController.text = getStringOrDefault(
              data, 'CUOTA_INICIAL'); // Ajusta según sea necesario
          _financiacionController.text = getStringOrDefault(
              data, 'OPCFIN_DESCR'); // Ajusta según sea necesario
          _porcentajeCIController.text = getStringOrDefault(
              data, 'OPCFIN_CUOTA_INICIAL'); // Ajusta según sea necesario
          _numeroCuotasController.text = getStringOrDefault(
              data, 'OPCFIN_NUM_CUOTAS'); // Ajusta según sea necesario
          _interesCteController.text = getStringOrDefault(
              data, 'OPCFIN_TASA_INTCOR'); // Ajusta según sea necesario
          _interesMraController.text = getStringOrDefault(
              data, 'OPCFIN_TASA_INTMOR'); // Ajusta según sea necesario
        });
        _calcularSumas(); // Calcula las sumas después de establecer los valores
      } else {
        throw Exception(
            'No se encontraron datos para el programa y opción de financiación especificados.');
      }
    }).catchError((error) {
      // Manejo de errores al obtener valores
    });

    // Obtener datos de amortización
    getValoresAmortizacion(
            widget.programaAcademicoID, widget.selectedOpcionFinanciacion)
        .then((result) {
      if (result.isNotEmpty && result.containsKey('data')) {
        setState(() {
          // Asigna la lista de amortización
          _amortizacionData = List<Map<String, dynamic>>.from(result['data']);
        });
        _calcularSumas(); // Calcula las sumas después de establecer los datos de amortización
      } else {
        throw Exception(
            'No se encontraron datos de amortización para el programa y opción de financiación especificados.');
      }
    }).catchError((error) {
      // Manejo de errores al obtener datos de amortización
    });
  }

// Método auxiliar para manejar valores nulos en la UI
  String getStringOrDefault(Map<String, dynamic> map, String key) {
    return (map[key] != null)
        ? map[key].toString()
        : ''; // Devuelve una cadena vacía si el valor es nulo
  }

  void _calcularSumas() {
    // Verifica si hay datos de amortización
    if (_amortizacionData.isNotEmpty) {
      double sumaCapital = 0.0;
      double sumaInteresCorriente = 0.0;
      double sumaValorCuota = 0.0;

      for (var cuota in _amortizacionData) {
        // Asegúrate de que las claves existen y son válidas
        sumaCapital += _getValueFromCuota(cuota, 'Capital');
        sumaInteresCorriente += _getValueFromCuota(cuota, 'Interes_Corriente');
        sumaValorCuota += _getValueFromCuota(cuota, 'Valor_Cuota');
      }

      setState(() {
        _sumaCapital = sumaCapital;
        _sumaInteresCorriente = sumaInteresCorriente;
        _sumaValorCuota = sumaValorCuota;
      });
    }
  }

// Método auxiliar para obtener el valor de una cuota
  double _getValueFromCuota(Map<String, dynamic> cuota, String key) {
    if (cuota.containsKey(key) && cuota[key] != null) {
      return _parseCurrency(cuota[key]);
    }
    return 0.0; // Devuelve 0.0 si la clave no existe o el valor es nulo
  }

// Método auxiliar para convertir cadenas de moneda a double
  double _parseCurrency(String value) {
    // Asegúrate de manejar correctamente los valores nulos
    if (value.isEmpty) return 0.0; // Manejo adicional para cadenas vacías
    return double.tryParse(
            value.replaceAll(',', '').replaceAll('\$', '').trim()) ??
        0.0; // Devuelve 0.0 si no se puede parsear
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

  Widget _buildTextField(
      String label, String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (controller.text.isEmpty) {
          return 'Por favor, ingrese $label';
        }
        return null;
      },
    );
  }

  Widget _buildAmortizationItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildTotalItem(String label, double value) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            ' \$${NumberFormat.decimalPattern().format(value)}',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador Financiero'),
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionTitle('Datos de la Simulación'),
              _buildTextField('Financiación', 'Financiación seleccionada',
                  _financiacionController),
              const SizedBox(height: 16),
              _buildTextField('Cuota Inicial', 'Valor cuota inicial',
                  _cuotaInicialController),
              const SizedBox(height: 16),
              _buildSectionTitle('Resumen Financiación'),
              DataTable(
                columns: const [
                  DataColumn(
                    label: Text(
                      'Atributo',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Valor',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: [
                  DataRow(cells: [
                    const DataCell(Text('Porcentaje Inicial')),
                    DataCell(Text(_porcentajeCIController.text.isNotEmpty
                        ? _porcentajeCIController.text
                        : 'N/A')),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Cuota Inicial')),
                    DataCell(Text(_cuotaInicialController.text.isNotEmpty
                        ? _cuotaInicialController.text
                        : 'N/A')),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Número Cuotas')),
                    DataCell(Text(_numeroCuotasController.text.isNotEmpty
                        ? _numeroCuotasController.text
                        : 'N/A')),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Interés Corriente')),
                    DataCell(Text(_interesCteController.text.isNotEmpty
                        ? _interesCteController.text
                        : 'N/A')),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Interés Mora')),
                    DataCell(Text(_interesMraController.text.isNotEmpty
                        ? _interesMraController.text
                        : 'N/A')),
                  ]),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Amortización del Crédito Periodo Mensual'),
              ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // Evita el desplazamiento del ListView
                itemCount: _amortizacionData.length,
                itemBuilder: (context, index) {
                  final cuota = _amortizacionData[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cuota Nº ${cuota['Num_Cuotas']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildAmortizationItem('Capital',
                              cuota['Capital'] ?? 'N/A'), // Manejo de nulos
                          _buildAmortizationItem(
                              'Días Crédito',
                              cuota['Dias_Credito'] ??
                                  'N/A'), // Manejo de nulos
                          _buildAmortizationItem(
                              'Interés Corriente',
                              cuota['Interes_Corriente'] ??
                                  'N/A'), // Corrección de clave
                          _buildAmortizationItem('Valor Cuota',
                              cuota['Valor_Cuota'] ?? 'N/A'), // Manejo de nulos
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Column(
                // Cambiar a Column para evitar problemas de scroll
                children: [
                  _buildTotalItem('Capital Total', _sumaCapital),
                  _buildTotalItem(
                      'Interés Corriente Total', _sumaInteresCorriente),
                  _buildTotalItem('Valor Cuota Total', _sumaValorCuota),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Para realizar algún trámite, solicitud o tener mayor información, por favor '
                'dirígete a la Unidad de Crédito y Cartera, ubicada en el Edificio Diego Barroso oficina 103.',
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getValores(
      String programa, String opcFinc) async {
    final response = await http.post(
      Uri.parse(
          'http://apps.usbbog.edu.co:8080/prod/usbbogota/simulador/SimuladorValorCuotaInicial'),
      body: {'PROGRAMA_ACADEMICO': programa, 'OPC_FINANCIACION': opcFinc},
    );

    if (response.statusCode == 200) {
      // Decodifica la respuesta JSON
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      // Verifica si el objeto contiene las claves esperadas
      if (jsonResponse.isNotEmpty && jsonResponse.containsKey('OPCFIN_ID')) {
        return jsonResponse; // Devuelve el objeto completo
      } else {
        throw Exception(
            'El servidor no devolvió datos válidos para el usuario con el programa "$programa" y opción de financiación "$opcFinc"');
      }
    } else {
      throw Exception('Error al cargar datos: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getValoresAmortizacion(
      String programa, String opcFinc) async {
    final response = await http.post(
      Uri.parse(
          'http://apps.usbbog.edu.co:8080/prod/usbbogota/simulador/SimuladorAmortizacion'),
      body: {'PROGRAMA_ACADEMICO': programa, 'OPC_FINANCIACION': opcFinc},
    );

    if (response.statusCode == 200) {
      try {
        // Decodifica la respuesta JSON
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        // Verifica si el objeto contiene la clave 'data'
        if (jsonResponse.isNotEmpty && jsonResponse.containsKey('data')) {
          // Extrae la lista de datos
          List<Map<String, dynamic>> dataList =
              List<Map<String, dynamic>>.from(jsonResponse['data']);

          // Extrae el ciclo si está presente
          String ciclo = jsonResponse['CICLO'] ??
              ''; // Manejo de nulos asegurando que nunca sea null
          return {
            'data': dataList,
            'CICLO': ciclo,
          }; // Devuelve los datos y el ciclo
        } else {
          throw Exception(
              'El servidor no devolvió datos válidos para el usuario con el programa "$programa" y opción de financiación "$opcFinc"');
        }
      } catch (e) {
        throw Exception('Error al decodificar JSON: $e');
      }
    } else {
      throw Exception('Error al cargar datos: ${response.statusCode}');
    }
  }

// Método auxiliar para manejar valores nulos en la UI
  String safeGetString(Map<String, dynamic> map, String key) {
    return (map[key] != null)
        ? map[key].toString()
        : 'N/A'; // Devuelve 'N/A' si el valor es nulo
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
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                  ),
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
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Horario de Clases'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HorarioEScreenE()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.group),
                  title: const Text('Solicitar Tutoría'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TutoriaEScreenE()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Simulador Financiero'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SimuladorE2ScreenE(
                                programaAcademicoID: '',
                                selectedOpcionFinanciacion: '',
                                cuotaInicial: '',
                                descripcion: '',
                              )),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.rotate_left),
                  title: const Text('Renovación ICETEX'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const IcetexEScreenE()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.check),
                  title: const Text('Crédito Directo USB'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreditoEScreenE()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.checklist_rtl),
                  title: const Text('Evaluaciones Profesores'),
                  onTap: () {
                    const String enlaceevalucacion =
                        'https://campus.usbco.edu.co/psp/USCS90PR/EMPLOYEE/HRMS/c/USB_LINKDOCTE_MNU.USB_DCTELINK_CMP.GBL';
                    _abrirEnlace(enlaceevalucacion);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Restablecer Credenciales'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CredencialesEScreenE()),
                    );
                  },
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

  Future<void> _abrirEnlace(String enlaceevalucacion) async {
    if (await canLaunchUrl(Uri.parse(enlaceevalucacion))) {
      await launchUrl(Uri.parse(enlaceevalucacion));
    } else {
      throw 'No se pudo abrir el enlace $enlaceevalucacion';
    }
  }
}
