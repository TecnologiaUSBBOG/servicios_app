import 'package:flutter/material.dart';
import 'package:servicios/screens/estudiante/icetex_e.dart';
import 'package:servicios/screens/estudiante/simulador_e.dart';
import 'package:servicios/screens/estudiante/tutoria_e.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth.dart';
import '../../globals.dart';
import '../login.dart';
import 'credenciales_e.dart';
import 'credito_e2.dart';
import 'horario_e.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CreditoEScreenE(),
    );
  }
}

class CreditoEScreenE extends StatefulWidget {
  const CreditoEScreenE({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreditoEScreenEState createState() => _CreditoEScreenEState();
}

class OpcionesSeleccionadasC {
  String nivelAcademico;
  String programaAcademico;
  String ciclo;

  OpcionesSeleccionadasC(
      {required this.nivelAcademico,
      required this.programaAcademico,
      required this.ciclo});
}

class _CreditoEScreenEState extends State<CreditoEScreenE> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Controladores de texto
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _vinculacionController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _nivelAcademicoController =
      TextEditingController();
  final TextEditingController _programaAcademicoIDController =
      TextEditingController();
  final TextEditingController _programaAcademicoController =
      TextEditingController();
  final TextEditingController _valorMatriculaController =
      TextEditingController();
  final TextEditingController _cicloController = TextEditingController();

  // ignore: non_constant_identifier_names

  String selectedOpcionLevel = '';
  String selectedOpcionPrograma = '';
  String selectedOpcionCiclo = '';
  List<Map<String, dynamic>> _opcionNivelAcademicoList = [];
  List<Map<String, dynamic>> _opcionProgramaAcademicoList = [];
  List<Map<String, dynamic>> _opcionCicloList = [];

  Future<List<Map<String, dynamic>>>? loadDataFuture;

  Map<String, dynamic>? _formData;

  @override
  void initState() {
    super.initState();
    _loadOpcNivelAcademico();
    _loadOpcProgramaAcademico();
    _loadOpcCiclo();
    // Cargar los datos del estudiante al iniciar
    fetchData(globalDocumento!).then((data) {
      setState(() {
        _formData = data;
        // Asignar valores a los controladores de texto
        _nationalIdController.text = _formData?['NATIONAL_ID'] ?? '';
        _vinculacionController.text = _formData?['VINCULACION'] ?? '';
        _nombreController.text = _formData?['NOMBRES'] ?? '';
        _apellidoController.text = _formData?['APELLIDOS'] ?? '';
        _telefonoController.text = _formData?['PHONE'] ?? '';
        _correoController.text = _formData?['EMAIL_ADDR'] ?? '';
        _nivelAcademicoController.text = _formData?['NIVEL'] ?? '';
        _programaAcademicoIDController.text = _formData?['ACAD_PROG'] ?? '';
        _programaAcademicoController.text = _formData?['PROGRAMA'] ?? '';
        _valorMatriculaController.text = _formData?['VALOR'] ?? '';
        _cicloController.text = _formData?['CICLO'] ?? '';
      });
    }).catchError((error) {
      // Manejo de errores adicional si es necesario
    });
  }

  Future<void> _loadOpcNivelAcademico() async {
    try {
      List<Map<String, dynamic>> opcLevelData = await getOpcLevel();
      setState(() {
        _opcionNivelAcademicoList = opcLevelData;
        if (_opcionNivelAcademicoList.isNotEmpty) {
          selectedOpcionLevel = _opcionNivelAcademicoList[0]['id'];
        } else {
          selectedOpcionLevel = 'Sin opciones disponibles';
        }
      });
    } catch (e) {
      setState(() {
        _opcionNivelAcademicoList = [];
        selectedOpcionLevel = 'Error al cargar opciones';
      });
    }
  }

  Future<void> _loadOpcProgramaAcademico() async {
    try {
      // Llamar a la función que obtiene las opciones del programa académico
      List<Map<String, dynamic>> opcProgramaData =
          await getOpcPrograma(selectedOpcionLevel);

      setState(() {
        _opcionProgramaAcademicoList = opcProgramaData;

        // Verificar si la lista de opciones no está vacía
        if (_opcionProgramaAcademicoList.isNotEmpty) {
          selectedOpcionPrograma = _opcionProgramaAcademicoList[0]['id'];
        } else {
          selectedOpcionPrograma = 'Sin opciones disponibles';
        }
      });
    } catch (e) {
      setState(() {
        _opcionProgramaAcademicoList = [];
        selectedOpcionPrograma = 'Error al cargar opciones: ${e.toString()}';
      });
    }
  }

  Future<void> _loadOpcCiclo() async {
    try {
      List<Map<String, dynamic>> opcCicloData = await getOpcCiclo();

      setState(() {
        _opcionCicloList = opcCicloData;

        if (_opcionCicloList.isNotEmpty) {
          selectedOpcionCiclo = _opcionCicloList[0]['id'];
        } else {
          selectedOpcionCiclo = 'Sin opciones disponibles';
        }
      });
    } catch (e) {
      setState(() {
        _opcionCicloList = [];
        selectedOpcionCiclo = 'Error al cargar opciones';
      });
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

  Widget _buildDropdownFieldWithLvlA(
      String label, List<String> opciones, String identifier) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: _opcionNivelAcademicoList.map((map) {
        return DropdownMenuItem<String>(
          value: map['id'],
          child: Text(map['text']),
        );
      }).toList(),
      value: selectedOpcionLevel.isNotEmpty ? selectedOpcionLevel : null,
      onChanged: (String? value) async {
        if (value != null) {
          setState(() {
            selectedOpcionLevel = value;
            selectedOpcionPrograma = '';
            _opcionProgramaAcademicoList.clear();
          });
          _startLoadingAnimation();
          try {
            await _loadOpcProgramaAcademico();
          } finally {
            _stopLoadingAnimation();
          }
        }
      },
    );
  }

  Widget _buildDropdownFieldWithProgA(
      String label, List<String> opciones, String identifier) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        //border: OutlineInputBorder(),
      ),
      items: _opcionProgramaAcademicoList.map((map) {
        return DropdownMenuItem<String>(
          value: map['id'],
          child: SizedBox(
            width: 300,
            child: Text(
              map['text'],
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
      value: selectedOpcionPrograma,
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            selectedOpcionPrograma = value;
          });
        }
      },
    );
  }

  Widget _buildDropdownFieldWithCiclo(
      String label, List<String> opciones, String identifier) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        //border: OutlineInputBorder(),
      ),
      items: _opcionCicloList.map((map) {
        return DropdownMenuItem<String>(
          value: map['id'],
          child: Text(map['text']),
        );
      }).toList(),
      value: selectedOpcionCiclo,
      validator: (value) {
        if (opciones.isEmpty || value == null || value.isEmpty) {
          return 'Por favor, seleccione $label';
        }
        return null;
      },
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            selectedOpcionCiclo = value;
          });
        }
      },
    );
  }

  void _startLoadingAnimation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        );
      },
    );
  }

  void _stopLoadingAnimation() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credito Directo USB'),
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
              _buildDropdownFieldWithCiclo(
                'Ciclo',
                _opcionCicloList.map((map) => map['text'].toString()).toList(),
                selectedOpcionCiclo,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                  'Documento', 'Ingrese el documento', _nationalIdController),
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
              const SizedBox(height: 16),
              _buildDropdownFieldWithLvlA(
                'Nivel académico',
                _opcionCicloList.map((map) => map['text'].toString()).toList(),
                selectedOpcionLevel,
              ),
              const SizedBox(height: 16),
              _buildDropdownFieldWithProgA(
                'Programa académico',
                _opcionProgramaAcademicoList
                    .map((map) => map['text'].toString())
                    .toList(),
                selectedOpcionPrograma,
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
                          ),
                        );
                      },
                    );
                    OpcionesSeleccionadasC opcionesSeleccionadasC =
                        OpcionesSeleccionadasC(
                      nivelAcademico: selectedOpcionLevel,
                      programaAcademico: selectedOpcionPrograma,
                      ciclo: selectedOpcionCiclo,
                    );

                    await Future.delayed(const Duration(seconds: 2));
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                    Navigator.push(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreditoE2ScreenE(
                          opcionesSeleccionadasC: opcionesSeleccionadasC,
                        ),
                      ),
                    );
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

  Future<Map<String, dynamic>> fetchData(String nationalId) async {
    final response = await http.post(
      Uri.parse(
        'http://apps.usbbog.edu.co:8080/prod/usbbogota/CreditoDirectoUSB/CreditoAutocompletado',
      ),
      body: {'NATIONAL_ID': nationalId},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      // Verifica si el JSON contiene los datos esperados
      if (data.isNotEmpty) {
        return data; // Retorna el mapa con los datos del estudiante
      } else {
        throw Exception(
            'El servidor no devolvió datos válidos para el usuario con el ID nacional: $nationalId');
      }
    } else {
      throw Exception('Error al cargar datos: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getOpcLevel() async {
    final response = await http.post(
      Uri.parse(
          'http://apps.usbbog.edu.co:8080/prod/usbbogota/CreditoDirectoUSB/CreditoNivelAcademico'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      // Verifica que el mapa no esté vacío
      if (data.isNotEmpty) {
        return [
          {
            'text': data['D']?.toString() ?? 'No disponible', // Manejo de nulos
            'id': data['R']?.toString() ?? 'No disponible', // Manejo de nulos
          }
        ];
      } else {
        throw Exception('No se encontraron opciones disponibles.');
      }
    } else {
      throw Exception(
          'Error al cargar todas las opciones: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getOpcPrograma(String programa) async {
    final response = await http.post(
      Uri.parse(
          'http://apps.usbbog.edu.co:8080/prod/usbbogota/icetex/IcetexProgramaAcademico'),
      body: {'PROG_ACADEMICO': programa},
    );

    if (response.statusCode == 200) {
      // Decodificar la respuesta como un mapa
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Verifica que el JSON contenga las claves esperadas
      if (jsonResponse.isNotEmpty) {
        return [
          {
            'text': jsonResponse['D']?.toString() ??
                'No disponible', // Manejo de nulos
            'id': jsonResponse['R']?.toString() ??
                'No disponible', // Manejo de nulos
          }
        ];
      } else {
        throw Exception('No se encontraron opciones disponibles.');
      }
    } else {
      throw Exception(
          'Error al cargar todas las opciones: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getOpcCiclo() async {
    final response = await http.post(
      Uri.parse(
          'http://apps.usbbog.edu.co:8080/prod/usbbogota/icetex/IcetexCicloAcademico'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> opcFincDataList = json.decode(response.body);

      // Verifica que el mapa no esté vacío
      if (opcFincDataList.isNotEmpty) {
        return [
          {
            'text': opcFincDataList['D']?.toString() ??
                'No disponible', // Manejo de nulos
            'id': opcFincDataList['R']?.toString() ??
                'No disponible', // Manejo de nulos
          }
        ];
      } else {
        throw Exception('No se encontraron opciones disponibles.');
      }
    } else {
      throw Exception(
          'Error al cargar todas las opciones: ${response.statusCode}');
    }
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
