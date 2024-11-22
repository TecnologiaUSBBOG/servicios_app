import 'package:flutter/material.dart';
import 'package:servicios/screens/estudiante/credito_e.dart';
import 'package:servicios/screens/estudiante/simulador_e2.dart';
import 'package:servicios/screens/estudiante/tutoria_e.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth.dart';
import '../../globals.dart';
import '../login.dart';
import 'credenciales_e.dart';
import 'horario_e.dart';
import 'icetex_e.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SimuladorEScreenE(),
    );
  }
}

class SimuladorEScreenE extends StatefulWidget {
  const SimuladorEScreenE({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SimuladorEScreenEState createState() => _SimuladorEScreenEState();
}

class _SimuladorEScreenEState extends State<SimuladorEScreenE> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _programaAcademicoIDController =
      TextEditingController();
  final TextEditingController _vinculacionController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _nivelAcademicoController =
      TextEditingController();
  final TextEditingController _programaAcademicoController =
      TextEditingController();
  final TextEditingController _valorMatriculaController =
      TextEditingController();
  final TextEditingController _cicloController = TextEditingController();

  String selectedOpcionFinanciacion = ''; // Inicialización
  List<Map<String, dynamic>> _opcionFinanciacionList = [];

  get jsonResponse => null;

  @override
  void initState() {
    super.initState();
    _documentoController.text = globalDocumento!;

    fetchData(globalDocumento!).then((data) {
      final Map<String, dynamic> info =
          data['info']; // Obtener info del solicitante
      String ciclo = data['ciclo']; // Obtener ciclo

      setState(() {
        _nationalIdController.text = info['NATIONAL_ID'] ?? '';
        _vinculacionController.text = info['VINCULACION'] ?? '';
        _nombreController.text = info['NOMBRES'] ?? '';
        _apellidoController.text = info['APELLIDOS'] ?? '';
        _telefonoController.text = info['PHONE'] ?? '';
        _correoController.text = info['EMAIL_ADDR'] ?? '';
        _nivelAcademicoController.text = info['NIVEL'] ?? '';
        _programaAcademicoIDController.text = info['ACAD_PROG'] ?? '';
        _programaAcademicoController.text = info['PROGRAMA'] ?? '';
        _valorMatriculaController.text = info['VALOR'] ?? '';

        // Llenar el controlador del ciclo
        _cicloController.text = ciclo;

        // Ahora llama a getOpcFinanciacion
        getOpcFinanciacion(globalDocumento!, _vinculacionController.text, ciclo)
            .then((opcFincData) {
          setState(() {
            _opcionFinanciacionList = opcFincData;
            if (_opcionFinanciacionList.isNotEmpty) {
              selectedOpcionFinanciacion =
                  _opcionFinanciacionList[0]['id']; // Asignar el primer ID
            } else {
              selectedOpcionFinanciacion = ''; // No hay opciones disponibles
            }
          });
        }).catchError((error) {
          setState(() {
            _opcionFinanciacionList = [];
            selectedOpcionFinanciacion = ''; // Resetear si hay error
          });
        });
      });
    }).catchError((error) {});
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

  Widget _buildDropdownFieldWithMap(
      String label, List<Map<String, dynamic>> opciones) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: opciones.map((map) {
        return DropdownMenuItem<String>(
          value: map['id'], // Usar el ID como valor
          child: SizedBox(
              height: 80,
              width: 200,
              child: Text(map['text'])), // Mostrar el texto
        );
      }).toList(),
      value: selectedOpcionFinanciacion.isNotEmpty
          ? selectedOpcionFinanciacion
          : null, // Valor seleccionado
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, seleccione $label';
        }
        return null;
      },
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            selectedOpcionFinanciacion =
                value; // Actualizar el valor seleccionado
          });
        }
      },
    );
  }

  Widget _buildDropdownFieldWithString(String label, List<String> opciones) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: opciones.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: (value) {
        if (opciones.isEmpty || value == null || value.isEmpty) {
          return 'Por favor, seleccione $label';
        }
        return null;
      },
      onChanged: (String? value) {},
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
      drawer: const MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionTitle('Datos del estudiante'),
              _buildTextField(
                  'Documento', 'Ingrese el documento', _nationalIdController),
              const SizedBox(height: 16),
              _buildTextField('Vinculación', 'Vinculación del estudiante',
                  _vinculacionController),
              const SizedBox(height: 16),
              _buildTextField('Nombre(s)', 'Ingrese el nombre del estudiante',
                  _nombreController),
              const SizedBox(height: 16),
              _buildTextField('Apellidos', 'Ingrese el apellido del estudiante',
                  _apellidoController),
              const SizedBox(height: 16),
              _buildTextField(
                  'Teléfono', 'Ingrese el teléfono', _telefonoController),
              const SizedBox(height: 16),
              _buildTextField('Correo institucional', 'Ingrese el correo',
                  _correoController),
              const SizedBox(height: 30),
              _buildSectionTitle('Nivel Académico'),
              _buildTextField(
                  'Nivél académico',
                  'Ingrese nivél académico al que pertenece',
                  _nivelAcademicoController),
              const SizedBox(height: 16),
              _buildTextField(
                  'Programa académico',
                  'Ingrese el programa académico al que pertenece',
                  _programaAcademicoController),
              const SizedBox(height: 16),
              _buildTextField('Valor matricula', 'Valor matricula',
                  _valorMatriculaController),
              const SizedBox(height: 16),
              _buildDropdownFieldWithMap(
                'Opción de financiación',
                _opcionFinanciacionList,
              ),
              const SizedBox(height: 16),
              _buildDropdownFieldWithString(
                'Fecha de pago',
                ['5 DÍAS HÁBILES', '20 DÍAS HÁBILES'],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const Center(
                            child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.orange),
                        ));
                      },
                    );

                    try {
                      String programaAcademicoID =
                          _programaAcademicoIDController.text;

                      final response = await http.post(
                        Uri.parse(
                          'http://apps.usbbog.edu.co:8080/prod/usbbogota/simulador/SimuladorValorCuotaInicial',
                        ),
                        body: {
                          'PROGRAMA_ACADEMICO': programaAcademicoID,
                          'OPC_FINANCIACION': selectedOpcionFinanciacion,
                        },
                      );
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context); // Cerrar el diálogo de carga
                      if (response.statusCode == 200) {
                        // Decodificar la respuesta JSON como un Map
                        Map<String, dynamic> data = json.decode(response.body);
                        // Navegar a la siguiente pantalla con los nuevos parámetros
                        Navigator.push(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                            builder: (context) => SimuladorE2ScreenE(
                              programaAcademicoID: programaAcademicoID,
                              selectedOpcionFinanciacion:
                                  selectedOpcionFinanciacion,
                              cuotaInicial: data['CUOTA_INICIAL'] ??
                                  '', // Asegúrate de que este campo exista
                              descripcion: data['OPCFIN_DESCR'] ??
                                  '', // Asegúrate de que este campo exista
                            ),
                          ),
                        );
                      } else {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Error en la solicitud al servidor'),
                          duration: Duration(seconds: 5),
                          backgroundColor: Colors.red,
                        ));
                      }
                      // ignore: empty_catches
                    } catch (error) {}
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>> fetchData(String nationalId) async {
  final response = await http.post(
    Uri.parse(
        'http://apps.usbbog.edu.co:8080/prod/usbbogota/simulador/SimuladorAutocompletado'),
    body: {'NATIONAL_ID': nationalId},
  );

  if (response.statusCode == 200) {
    // Intentar decodificar la respuesta JSON
    try {
      // Decodifica la respuesta JSON
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Verifica si el objeto contiene los datos del solicitante
      if (jsonResponse.isNotEmpty) {
        return {
          'info': jsonResponse, // Devuelve todos los datos del solicitante
          'ciclo': jsonResponse['CICLO'] ?? '', // Devuelve el ciclo
        };
      } else {
        throw Exception(
            'No se encontraron datos para el ID nacional: $nationalId');
      }
    } catch (e) {
      throw Exception('Error al decodificar JSON: $e');
    }
  } else {
    throw Exception('Error al cargar datos: ${response.statusCode}');
  }
}

Future<List<Map<String, dynamic>>> getOpcFinanciacion(
    String nationalId, String vinculacion, String ciclo) async {
  final response = await http.post(
    Uri.parse(
      'http://apps.usbbog.edu.co:8080/prod/usbbogota/simulador/SimuladorOpcionFinanciacion',
    ),
    body: {
      'NATIONAL_ID': nationalId,
      'VINCULACION': vinculacion,
      'CICLO': ciclo,
    },
  );
  if (response.statusCode == 200) {
    // Limpiar la respuesta para eliminar comas adicionales
    String cleanedResponse = response.body
        .replaceAll(RegExp(r',,+'), ','); // Elimina comas duplicadas
    cleanedResponse = cleanedResponse.replaceAll(
        RegExp(r',\s*]'), ']'); // Elimina coma antes del cierre del array

    // Decodificar la respuesta JSON como una lista
    List<dynamic> opcFincDataList = json.decode(cleanedResponse);

    // Mapea los datos a un formato adecuado
    return opcFincDataList
        .map((opc) => {
              'text': opc['D'].toString(), // Obtener el texto del campo 'D'
              'id': opc['R'].toString(), // Obtener el valor del campo 'R'
            })
        .toList();
  } else {
    throw Exception(
        'Error al cargar todas las opciones: ${response.statusCode}');
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
                          builder: (context) => const SimuladorEScreenE()),
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
