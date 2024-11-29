import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:servicios/screens/estudiante/icetex_e.dart';
import 'package:servicios/screens/estudiante/simulador_e.dart';
import 'package:servicios/screens/estudiante/tutoria_e.dart';
import 'package:servicios/screens/funcionalidad.dart';
import '../../auth.dart';
import '../../globals.dart';
import '../login.dart';
import 'credenciales_e.dart';
import 'horario_e.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: IcetexE2ScreenE(),
    );
  }
}

class IcetexE2ScreenE extends StatefulWidget {
  final OpcionesSeleccionadas opcionesSeleccionadas;

  IcetexE2ScreenE({super.key, OpcionesSeleccionadas? opcionesSeleccionadas})
      : opcionesSeleccionadas = opcionesSeleccionadas ??
            OpcionesSeleccionadas(
                nivelAcademico: '', programaAcademico: '', ciclo: '');

  @override
  State<IcetexE2ScreenE> createState() => _IcetexE2ScreenEState();
}

class _IcetexE2ScreenEState extends State<IcetexE2ScreenE> {
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
  final TextEditingController _fechaPagoController = TextEditingController();
  final TextEditingController _valorCuotaIDController = TextEditingController();
  final TextEditingController _valorFinanciadoController =
      TextEditingController();

  Future<List<Map<String, dynamic>>>? loadDataFuture;

  Map<String, dynamic>? _formData;

  String? pdfPath1;
  String? pdfPath2;
  String? pdfPath3;
  String? selectedFileName1;
  String? selectedFileName2;
  String? selectedFileName3;
  bool allFilesSelected = false;
  bool acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _documentoController.text = globalDocumento!;

    fetchData(globalDocumento!).then((dataList) {
      if (dataList.isNotEmpty) {
        // ignore: collection_methods_unrelated_type
        final Map<String, dynamic> data = dataList[0];
        setState(() {
          _formData = data;
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
          _fechaPagoController.text = '';
          _valorFinanciadoController.text = _formData?['CUOTA_INICIAL'] ?? '';
          _valorCuotaIDController.text = _formData?['R'] ?? '';
        });
      } else {
        throw Exception('Respuesta inesperada del servidor');
      }
    }).catchError((error) {});
  }

  Future<void> _pickPDF1() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        String pdfPath = result.files.single.path!;
        String pdfFileName = result.files.single.name;

        List<int> pdfBytes = await File(pdfPath).readAsBytes();
        // ignore: unused_local_variable
        String pdfBase64 = base64Encode(pdfBytes);

        if (pdfBytes.length > (2 * 1024 * 1024)) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('El tamaño del archivo "$pdfFileName" supera los 2 MB.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
          return;
        }

        setState(() {
          pdfPath1 = pdfPath;
          selectedFileName1 = pdfFileName;
          allFilesSelected = _areAllFilesSelected();
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _pickPDF2() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        String pdfPath = result.files.single.path!;
        String pdfFileName = result.files.single.name;

        List<int> pdfBytes = await File(pdfPath).readAsBytes();
        // ignore: unused_local_variable
        String pdfBase64 = base64Encode(pdfBytes);

        if (pdfBytes.length > (2 * 1024 * 1024)) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('El tamaño del archivo "$pdfFileName" supera los 2 MB.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
          return;
        }

        setState(() {
          pdfPath2 = pdfPath;
          selectedFileName2 = pdfFileName;
          allFilesSelected = _areAllFilesSelected();
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _pickPDF3() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        String pdfPath = result.files.single.path!;
        String pdfFileName = result.files.single.name;

        List<int> pdfBytes = await File(pdfPath).readAsBytes();
        // ignore: unused_local_variable
        String pdfBase64 = base64Encode(pdfBytes);

        if (pdfBytes.length > (2 * 1024 * 1024)) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('El tamaño del archivo "$pdfFileName" supera los 2 MB.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
          return;
        }

        setState(() {
          pdfPath3 = pdfPath;
          selectedFileName3 = pdfFileName;
          allFilesSelected = _areAllFilesSelected();
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  bool _areAllFilesSelected() {
    return pdfPath1 != null && pdfPath2 != null && pdfPath3 != null;
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
        title: const Text('Renovación ICETEX'),
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
              _buildSectionTitle('Documentos Requeridos'),
              const Text(
                'Seleccione el archivo correspondiente. Cuando desee '
                'enviarlos oprima el check de políticas seguido del botón "Enviar Solicitud". Por favor '
                'verifique los archivos seleccionados antes del envío de la solicitud, solo se permite PDF. Puede '
                'reemplazar o cancelar la selección de cualquier archivo antes de realizar el envío. ',
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Cargue aquí la orden de matrícula. *',
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _pickPDF1(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      'SELECCIONAR ORDEN MATRICULA',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (selectedFileName1 != null)
                    Text('Archivo seleccionado: $selectedFileName1'),
                  const SizedBox(height: 20),
                  const Text(
                    'Cargue aquí formato de actualización de datos. Recuerde diligenciar los campos '
                    'de ciudad, fecha y en el caso de la firma sólo la línea que contiene su número de '
                    'documento, las tres líneas siguientes son para recibido de la universidad. *',
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _pickPDF2(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      'SELECCIONAR FORMATO DE DATOS',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (selectedFileName2 != null)
                    Text('Archivo seleccionado: $selectedFileName2'),
                  const SizedBox(height: 20),
                  const Text(
                    'Cargue aquí el tabulado de notas descargado desde la plataforma Asis: Recuerde que el '
                    'promedio permitido para renovar su crédito con ICETEX es 3.0 en adelante, si se encuentra '
                    'por debajo de éste promedio no podemos proceder con la solicitud. *',
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _pickPDF3(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      'SELECCIONAR TABULADO DE NOTAS',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (selectedFileName3 != null)
                    Text('Archivo seleccionado: $selectedFileName3'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Theme(
                    data: ThemeData(
                      unselectedWidgetColor: Colors.orange,
                    ),
                    child: Checkbox(
                      value: acceptedTerms,
                      onChanged: (value) {
                        setState(() {
                          acceptedTerms = value!;
                        });
                      },
                      activeColor: Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          const TextSpan(
                            text: 'He leído, acepto y autorizo las ',
                            style: TextStyle(fontSize: 10, color: Colors.black),
                          ),
                          TextSpan(
                            text: 'políticas de uso y privacidad',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                const url =
                                    'https://www.usbbog.edu.co/politicas-de-uso-y-privacidad/';
                                // ignore: deprecated_member_use
                                launch(url);
                              },
                          ),
                          const TextSpan(
                            text: '. *',
                            style: TextStyle(fontSize: 10, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    acceptedTerms && allFilesSelected ? _submitForm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text(
                  'Enviar Solicitud',
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

  void _submitForm() async {
    Funcionalidad alert = Funcionalidad();
    if (pdfPath1 == null || pdfPath2 == null || pdfPath3 == null) {
      return;
    }
    final client = http.Client();

    try {
      String documento = _documentoController.text;
      String ciclo = _cicloController.text;
      String nombres = _nombreController.text;
      String apellidos = _apellidoController.text;
      String correo = _correoController.text;
      String telefono = _telefonoController.text;
      String telefonoLimpio = limpiarTelefono(telefono);
      String programa = _programaAcademicoController.text;
      String idPrograma = _programaAcademicoIDController.text;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ));
        },
      );
      ScaffoldMessenger.of(context);
      final response = await http.post(
        Uri.parse(
            'http://apps.usbbog.edu.co:8080/prod/usbbogota/icetex/IcetexEnviarDatosRenovacion'),
        body: {
          'DOCUMENTO': documento,
          'CICLO': ciclo,
          'NOMBRES': nombres,
          'APELLIDOS': apellidos,
          'CORREO': correo,
          'TELEFONO': telefonoLimpio,
          'COD_PROGRAMA': idPrograma,
          'PROGRAMA': programa,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          String idProceso = responseData['ID_PROCESO'].toString();

          List<int> pdfBytes1 = await File(pdfPath1!).readAsBytes();
          String pdfBase64_1 = base64Encode(pdfBytes1);
          await enviarArchivosPDF(idProceso, pdfBase64_1, selectedFileName1!);

          List<int> pdfBytes2 = await File(pdfPath2!).readAsBytes();
          String pdfBase64_2 = base64Encode(pdfBytes2);
          await enviarArchivosPDF(idProceso, pdfBase64_2, selectedFileName2!);

          List<int> pdfBytes3 = await File(pdfPath3!).readAsBytes();
          String pdfBase64_3 = base64Encode(pdfBytes3);
          await enviarArchivosPDF(idProceso, pdfBase64_3, selectedFileName3!);

          // ignore: use_build_context_synchronously
          alert.showAlertDialogSuccess(context, 'Datos enviado',
              'Solicitud enviada con éxito', 'est', null);
        } else {
          // ignore: use_build_context_synchronously
          alert.showAlertDialogError(
              // ignore: use_build_context_synchronously
              context,
              'Error',
              'Error al enviar la solicitud.');
        }
      } else {
        //cambiar la varibale telefonolimpio por telefono
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error en la solicitud HTTP. '),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (error) {
      // Si ocurre algún error durante el proceso, manejarlo aquí.

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error durante la solicitud HTTP'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      client.close();
    }
  }

  Future<void> enviarArchivosPDF(
      String idProceso, String pdfBase64, String pdfFileName) async {
    const String url =
        'http://apps.usbbog.edu.co:8080/prod/usbbogota/icetex/IcetexEnvioArchivosRenovacion';

    try {
      Map<String, dynamic> requestBody = {
        "ID_PROCESO": idProceso,
        "pdf_file": pdfBase64,
        "pdfFileName": pdfFileName,
      };
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> responseData = jsonDecode(response.body);
          if (responseData['status'] == 'success') {
          } else {
            throw ('Error en la respuesta: ${responseData['message']}');
          }
        } catch (e) {
          throw ('Error al decodificar la respuesta JSON: $e');
        }
        if (response.statusCode != 200) {
          throw ('Error en la solicitud HTTP, código de estado: ${response.statusCode}');
        }
      } else {
        throw ('Error en la solicitud HTTP, código de estado: ${response.statusCode}');
      }
      // ignore: empty_catches
    } catch (error) {}
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

  String limpiarTelefono(String telefono) {
    return telefono.replaceAll(
        RegExp(r'\D'), ''); // Reemplaza todos los caracteres que no son dígitos
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
                          builder: (context) => IcetexE2ScreenE(
                                opcionesSeleccionadas: null,
                              )),
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
