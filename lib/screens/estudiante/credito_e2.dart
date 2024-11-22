import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:servicios/screens/estudiante/credito_e.dart';
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
      home: CreditoE2ScreenE(),
    );
  }
}

class CreditoE2ScreenE extends StatefulWidget {
  final OpcionesSeleccionadasC opcionesSeleccionadasC;

  CreditoE2ScreenE({super.key, OpcionesSeleccionadasC? opcionesSeleccionadasC})
      : opcionesSeleccionadasC = opcionesSeleccionadasC ??
            OpcionesSeleccionadasC(
                nivelAcademico: '', programaAcademico: '', ciclo: '');

  @override
  // ignore: library_private_types_in_public_api
  _CreditoE2ScreenEState createState() => _CreditoE2ScreenEState();
}

class _CreditoE2ScreenEState extends State<CreditoE2ScreenE> {
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
  // ignore: non_constant_identifier_names
  final TextEditingController _ValorCuotaIDController = TextEditingController();
  final TextEditingController _valorFinanciadoController =
      TextEditingController();

  Future<List<Map<String, dynamic>>>? loadDataFuture;

  Map<String, dynamic>? _formData;

  String? pdfPath1;
  String? pdfPath2;
  String? pdfPath3;
  String? pdfPath4;
  String? pdfPath5;
  String? pdfPath6;
  String? pdfPath7;
  String? pdfPath8;
  String? pdfPath9;
  String? pdfPath10;
  String? pdfPath11;
  String? pdfPath12;
  String? pdfPath13;

  String? selectedFileName1;
  String? selectedFileName2;
  String? selectedFileName3;
  String? selectedFileName4;
  String? selectedFileName5;
  String? selectedFileName6;
  String? selectedFileName7;
  String? selectedFileName8;
  String? selectedFileName9;
  String? selectedFileName10;
  String? selectedFileName11;
  String? selectedFileName12;
  String? selectedFileName13;

  bool allFilesSelected = false;
  bool acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _documentoController.text = globalDocumento!;

    fetchData(globalDocumento!).then((data) {
      // Cambiado de dataList a data
      // Asegúrate de que 'data' sea un mapa
      if (data.isNotEmpty) {
        setState(() {
          _formData = data; // Asignar datos a _formData
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
          _fechaPagoController.text = ''; // Inicializar si es necesario
          _valorFinanciadoController.text = _formData?['CUOTA_INICIAL'] ?? '';
          _ValorCuotaIDController.text = _formData?['R'] ?? '';
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

        String base64String = base64Encode(pdfBytes);
        base64String = base64String;

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

  Future<void> _pickPDF4() async {
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
          pdfPath4 = pdfPath;
          selectedFileName4 = pdfFileName;
          allFilesSelected = _areAllFilesSelected();
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _pickPDF5() async {
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
          pdfPath5 = pdfPath;
          selectedFileName5 = pdfFileName;
          allFilesSelected = _areAllFilesSelected();
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _pickPDF6() async {
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
          pdfPath6 = pdfPath;
          selectedFileName6 = pdfFileName;
          allFilesSelected = _areAllFilesSelected();
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _pickPDF7() async {
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
          pdfPath7 = pdfPath;
          selectedFileName7 = pdfFileName;
          allFilesSelected = _areAllFilesSelected();
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _pickPDF8() async {
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
          pdfPath8 = pdfPath;
          selectedFileName8 = pdfFileName;
          allFilesSelected = _areAllFilesSelected();
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _pickPDF9() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
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
          scaffoldMessenger.showSnackBar(
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
          pdfPath9 = pdfPath;
          selectedFileName9 = pdfFileName;
          allFilesSelected = _areAllFilesSelected();
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _pickPDF10() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
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
          scaffoldMessenger.showSnackBar(
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
          pdfPath10 = pdfPath;
          selectedFileName10 = pdfFileName;
          allFilesSelected = _areAllFilesSelected();
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _pickPDF11() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
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
          scaffoldMessenger.showSnackBar(
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
          pdfPath10 = pdfPath;
          selectedFileName11 = pdfFileName;
          allFilesSelected = _areAllFilesSelected();
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _pickPDF12() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
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
          scaffoldMessenger.showSnackBar(
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
          pdfPath10 = pdfPath;
          selectedFileName12 = pdfFileName;
          allFilesSelected = _areAllFilesSelected();
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _pickPDF13() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
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
          scaffoldMessenger.showSnackBar(
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
          pdfPath10 = pdfPath;
          selectedFileName13 = pdfFileName;
          allFilesSelected = _areAllFilesSelected();
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  bool _areAllFilesSelected() {
    return pdfPath1 != null &&
        pdfPath2 != null &&
        pdfPath3 != null &&
        pdfPath4 != null &&
        pdfPath5 != null &&
        pdfPath6 != null &&
        pdfPath7 != null;
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
        title: const Text('Crédito Directo USB'),
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
              Column(
                children: [
                  const SizedBox(height: 25),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      'Formulario de solicitud de crédito diligenciado y firmado. *',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _pickPDF1(),
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(const Size(320, 20)),
                      backgroundColor: WidgetStateProperty.all(Colors.orange),
                    ),
                    child: const Text(
                      'SELECCIONAR FORMULARIO',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 05),
                  if (selectedFileName1 != null)
                    Text('Archivo seleccionado: $selectedFileName1'),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      'Carta de respuesta emitida por Vicerrectoría '
                      'Financiera donde indica número de cuotas y fechas. *',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _pickPDF2(),
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(const Size(320, 20)),
                      backgroundColor: WidgetStateProperty.all(Colors.orange),
                    ),
                    child: const Text(
                      'SELECCIONAR CARTA RESPUESTA',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 05),
                  if (selectedFileName2 != null)
                    Text('Archivo seleccionado: $selectedFileName2'),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      'Copia del documento de identidad del '
                      'estudiante. *',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _pickPDF3(),
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(const Size(320, 20)),
                      backgroundColor: WidgetStateProperty.all(Colors.orange),
                    ),
                    child: const Text(
                      'SELECCIONAR DOCUMENTO ESTUDIANTE',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 05),
                  if (selectedFileName3 != null)
                    Text('Archivo seleccionado: $selectedFileName3'),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      'Copia del documento de identidad del codeudor. *',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _pickPDF4(),
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(const Size(320, 20)),
                      backgroundColor: WidgetStateProperty.all(Colors.orange),
                    ),
                    child: const Text(
                      'SELECCIONAR DOCUMENTO CODEUDOR',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 05),
                  if (selectedFileName4 != null)
                    Text('Archivo seleccionado: $selectedFileName4'),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      'Carta de instrucciones Firmada, Con huella, datos en los campos de firma '
                      'únicamente, y Autenticada por estudiante y codeudor. *',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _pickPDF5(),
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(const Size(320, 20)),
                      backgroundColor: WidgetStateProperty.all(Colors.orange),
                    ),
                    child: const Text(
                      'SELECCIONAR CARTA INSTRUCCIONES',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 05),
                  if (selectedFileName5 != null)
                    Text('Archivo seleccionado: $selectedFileName5'),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      'Clausula compromisoria diligenciada únicamente en los campos de '
                      'Firma y datos y autenticada por estudiante y codeudor. *',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _pickPDF6(),
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(const Size(320, 20)),
                      backgroundColor: WidgetStateProperty.all(Colors.orange),
                    ),
                    child: const Text(
                      'SELECCIONAR CLAUSULA',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 05),
                  if (selectedFileName6 != null)
                    Text('Archivo seleccionado: $selectedFileName6'),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      'Pagaré únicamente diligenciado en la parte de firma y huellas, '
                      'por estudiante y codeudor, Se recuerda que el pagaré no se '
                      'autentica, de hacerlo se tendrá que repetir. *',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _pickPDF7(),
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(const Size(320, 20)),
                      backgroundColor: WidgetStateProperty.all(Colors.orange),
                    ),
                    child: const Text(
                      'SELECCIONAR PAGARÉ',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 05),
                  if (selectedFileName7 != null)
                    Text('Archivo seleccionado: $selectedFileName7'),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      'Si indicó que es empleado adjuntar certificado laboral no mayor '
                      'a 30 días que incluya sueldo, fecha de ingreso y tipo de contrato.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _pickPDF8(),
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(const Size(320, 20)),
                      backgroundColor: WidgetStateProperty.all(Colors.orange),
                    ),
                    child: const Text(
                      'SELECCIONAR CERTIFICADO LABORAL',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 05),
                  if (selectedFileName8 != null)
                    Text('Archivo seleccionado: $selectedFileName8'),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      'Si indicó que es empleado adjuntar certificado de ingresos '
                      'y retenciones del año inmediatamente anterior en FORMATO 220 DIAN.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _pickPDF9(),
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(const Size(320, 20)),
                      backgroundColor: WidgetStateProperty.all(Colors.orange),
                    ),
                    child: const Text(
                      'SELECCIONAR CERTIFICADO I/R',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 05),
                  if (selectedFileName9 != null)
                    Text('Archivo seleccionado: $selectedFileName9'),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      'Adjuntar declaración de renta (Si está obligado a declarar).',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _pickPDF10(),
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(const Size(320, 20)),
                      backgroundColor: WidgetStateProperty.all(Colors.orange),
                    ),
                    child: const Text(
                      'SELECCIONAR DECLARACIÓN RENTA',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 05),
                  if (selectedFileName10 != null)
                    Text('Archivo seleccionado: $selectedFileName10'),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      'Si indicó que es independiente, adjuntar certificado '
                      'de ingresos por un contador el cual debe incluir copia de la cédula y tarjeta profesional del contador.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _pickPDF11(),
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(const Size(320, 20)),
                      backgroundColor: WidgetStateProperty.all(Colors.orange),
                    ),
                    child: const Text(
                      'SELECCIONAR CERTIFICADO INGRESOS',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 05),
                  if (selectedFileName11 != null)
                    Text('Archivo seleccionado: $selectedFileName11'),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      'En caso de presentar ingresos adicionales, adjuntar '
                      'certificado de ingresos por un contador el cual debe incluir copia de la cédula y tarjeta profesional del contador.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _pickPDF12(),
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(const Size(320, 20)),
                      backgroundColor: WidgetStateProperty.all(Colors.orange),
                    ),
                    child: const Text(
                      'SELECCIONAR CERTIFICADO INGRESOS',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 05),
                  if (selectedFileName12 != null)
                    Text('Archivo seleccionado: $selectedFileName12'),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      'Si indicó que es independiente, y es persona jurídica, '
                      'certificado de Cámara y Comercio no mayor a 30 días.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _pickPDF13(),
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(const Size(320, 20)),
                      backgroundColor: WidgetStateProperty.all(Colors.orange),
                    ),
                    child: const Text(
                      'SELECCIONAR DOCUMENTO',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 05),
                  if (selectedFileName13 != null)
                    Text('Archivo seleccionado: $selectedFileName13'),
                  const SizedBox(height: 25),
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
                                launchUrl(Uri.parse(url));
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
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Verificar si todos los archivos PDF han sido seleccionados
    if (pdfPath1 == null ||
        pdfPath2 == null ||
        pdfPath3 == null ||
        pdfPath4 == null ||
        pdfPath5 == null ||
        pdfPath6 == null ||
        pdfPath7 == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content:
              Text('Por favor, seleccione todos los archivos PDF requeridos.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    final client = http.Client();

    try {
      if (_formData == null) {
        return;
      }

      // Obtener valores de los controladores
      String documento = _documentoController.text;
      String ciclo = _cicloController.text;
      String nombres = _nombreController.text;
      String apellidos = _apellidoController.text;
      String correo = _correoController.text;
      String telefono = _telefonoController.text;
      String telefonolimpio = limpiarTelefono(telefono);
      String programa = _programaAcademicoController.text;
      String idPrograma = _programaAcademicoIDController.text;

      if (nombres.isEmpty ||
          apellidos.isEmpty ||
          correo.isEmpty ||
          telefono.isEmpty) {
        return;
      }

      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          );
        },
      );

      // Realizar la solicitud HTTP
      final response = await client.post(
        Uri.parse(
            'http://apps.usbbog.edu.co:8080/prod/usbbogota/CreditoDirectoUSB/CreditoEnviarDatosRenovacion'),
        body: {
          'DOCUMENTO': documento,
          'CICLO': ciclo,
          'NOMBRES': nombres,
          'APELLIDOS': apellidos,
          'CORREO': correo,
          'TELEFONO': telefonolimpio,
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

          List<int> pdfBytes4 = await File(pdfPath4!).readAsBytes();
          String pdfBase64_4 = base64Encode(pdfBytes4);
          await enviarArchivosPDF(idProceso, pdfBase64_4, selectedFileName4!);

          List<int> pdfBytes5 = await File(pdfPath5!).readAsBytes();
          String pdfBase64_5 = base64Encode(pdfBytes5);
          await enviarArchivosPDF(idProceso, pdfBase64_5, selectedFileName5!);

          List<int> pdfBytes6 = await File(pdfPath6!).readAsBytes();
          String pdfBase64_6 = base64Encode(pdfBytes6);
          await enviarArchivosPDF(idProceso, pdfBase64_6, selectedFileName6!);

          List<int> pdfBytes7 = await File(pdfPath7!).readAsBytes();
          String pdfBase64_7 = base64Encode(pdfBytes7);
          await enviarArchivosPDF(idProceso, pdfBase64_7, selectedFileName7!);

          List<int> pdfBytes8 = await File(pdfPath8!).readAsBytes();
          String pdfBase64_8 = base64Encode(pdfBytes8);
          await enviarArchivosPDF(idProceso, pdfBase64_8, selectedFileName8!);

          List<int> pdfBytes9 = await File(pdfPath9!).readAsBytes();
          String pdfBase64_9 = base64Encode(pdfBytes9);
          await enviarArchivosPDF(idProceso, pdfBase64_9, selectedFileName9!);

          List<int> pdfBytes10 = await File(pdfPath10!).readAsBytes();
          String pdfBase64_10 = base64Encode(pdfBytes10);
          await enviarArchivosPDF(idProceso, pdfBase64_10, selectedFileName10!);

          List<int> pdfBytes11 = await File(pdfPath11!).readAsBytes();
          String pdfBase64_11 = base64Encode(pdfBytes11);
          await enviarArchivosPDF(idProceso, pdfBase64_11, selectedFileName11!);

          List<int> pdfBytes12 = await File(pdfPath12!).readAsBytes();
          String pdfBase64_12 = base64Encode(pdfBytes12);
          await enviarArchivosPDF(idProceso, pdfBase64_12, selectedFileName12!);

          List<int> pdfBytes13 = await File(pdfPath13!).readAsBytes();
          String pdfBase64_13 = base64Encode(pdfBytes13);
          await enviarArchivosPDF(idProceso, pdfBase64_13, selectedFileName13!);

          // ignore: use_build_context_synchronously
          alert.showAlertDialogSuccess(context, 'Datos enviado',
              'Solicitud enviada con éxito', 'est', null);
        } else {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Error al enviar la solicitud.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
          // ignore: use_build_context_synchronously
          alert.showAlertDialogSuccess(
              // ignore: use_build_context_synchronously
              context,
              'Error',
              'Error al enviar la solicitud',
              'est',
              null);
        }
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Error en la solicitud HTTP.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      client.close();
    }
  }

  Future<void> enviarArchivosPDF(
      String idProceso, String pdfBase64, String pdfFileName) async {
    const String url =
        'http://apps.usbbog.edu.co:8080/prod/usbbogota/CreditoDirectoUSB/CreditoEnvioArchivosRenovacion';

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
        if (response.body.isEmpty) {
          throw ('Error: Response body is empty.');
        }

        try {
          Map<String, dynamic> responseData = jsonDecode(response.body);
          if (responseData['status'] == 'success') {
          } else {}
        } catch (e) {
          throw ('Error al decodificar la respuesta JSON: $e');
        }
      } else {
        throw ('Error en la solicitud HTTP. Código de estado: ${response.statusCode}');
      }
    } catch (error) {
      throw ('Error en la solicitud HTTP: $error');
    }
  }

  Future<Map<String, dynamic>> fetchData(String nationalId) async {
    final response = await http.post(
      Uri.parse(
        'http://apps.usbbog.edu.co:8080/prod/usbbogota/CreditoDirectoUSB/CreditoAutocompletado/$nationalId',
      ),
      body: {'NATIONAL_ID': nationalId},
    );

    // Verificar si la respuesta fue exitosa
    if (response.statusCode == 200) {
      // Decodificar la respuesta JSON
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
}

String limpiarTelefono(String telefono) {
  return telefono.replaceAll(
      RegExp(r'\D'), ''); // Reemplaza todos los caracteres que no son dígitos
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
                        height: 100.0,
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
