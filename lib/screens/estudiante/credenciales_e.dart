// ignore: file_names
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:servicios/screens/estudiante/credito_e.dart';
import 'package:servicios/screens/estudiante/simulador_e.dart';
import 'package:servicios/screens/estudiante/tutoria_e.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth.dart';
import '../../globals.dart';
import '../login.dart';
import 'credenciales_e2.dart';
import 'horario_e.dart';
import 'icetex_e.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import '../funcionalidad.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CredencialesEScreenE(),
    );
  }
}

class CredencialesEScreenE extends StatefulWidget {
  const CredencialesEScreenE({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CredencialesEScreenEState createState() => _CredencialesEScreenEState();
}

class _CredencialesEScreenEState extends State<CredencialesEScreenE> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  // MaskTextInputFormatter _dateMaskFormatter = MaskTextInputFormatter(
  //     mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});

  Funcionalidad alert = Funcionalidad();
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    Locale myLocale = Localizations.localeOf(context);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextStyle? style = theme.textTheme.titleMedium;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2101),
      locale: myLocale,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: colorScheme.copyWith(
              primary: Colors.orange,
              onPrimary: Colors.white,
            ),
            textTheme: theme.textTheme.copyWith(
              titleMedium: style?.copyWith(color: Colors.orange),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restablecer Credenciales'),
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
              TextField(
                controller: _idController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Número de identificación',
                  hintText: 'Ingrese el documento',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              DateTimeField(
                format: DateFormat('dd/MM/yyyy'),
                controller: _dateController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Fecha de nacimiento',
                  hintText: 'Seleccione la fecha',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onShowPicker: (context, currentValue) async {
                  await _selectDate(context);
                  return selectedDate;
                },
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

                    try {
                      // Obtener y dividir la fecha en el formato "DD/MM/YYYY"
                      final fechaTexto = _dateController.text.trim();
                      final dateParts = fechaTexto.split('/');

                      if (dateParts.length != 3) {
                        throw 'Formato de fecha incorrecto. Usa DD/MM/YYYY.';
                      }

                      // Extraer día, mes y año
                      final dia = dateParts[0];
                      final mes = dateParts[1];
                      final anio = dateParts[2];

                      // Validar día, mes y año
                      if (int.tryParse(dia) == null ||
                          int.tryParse(mes) == null ||
                          int.tryParse(anio) == null) {
                        throw 'Día, mes o año no son válidos.';
                      }

                      // Asegurarnos de que el documento esté en el formato correcto
                      final documento = _idController.text.trim();
                      if (documento.isEmpty) {
                        throw 'Documento no puede estar vacío';
                      }

                      final response = await http.post(
                        Uri.parse(
                          'http://apps.usbbog.edu.co:8080/prod/usbbogota/credenciales/Verificacion',
                        ),
                        body: {
                          'documento': documento,
                          'dia': dia,
                          'mes': mes,
                          'anio': anio,
                        },
                      );

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);

                      if (response.statusCode == 200) {
                        Map<String, dynamic> data = json.decode(response.body);
                        // Extraer los datos del JSON
                        String usuarioAsis = data['USUARIO_ASIS']?.trim() ?? '';
                        String correoInstitucional =
                            data['CORREO_INSTITUCIONAL']?.trim() ?? '';
                        String correoPersonal =
                            data['CORREO_PERSONAL']?.trim() ?? '';
                        String tipo = data['TIPO']?.trim() ?? '';
                        String documentoResponse =
                            data['DOCUMENTO']?.trim() ?? '';
                        String emplid = data['CODIGO']?.trim() ?? '';

                        if (usuarioAsis.isNotEmpty &&
                            correoInstitucional.isNotEmpty) {
                          Navigator.push(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => CredencialesE2ScreenE(
                                usuarioAsis: usuarioAsis,
                                correoInstitucional: correoInstitucional,
                                correoPersonal: correoPersonal,
                                tipo: tipo,
                                documento: documentoResponse,
                                emplid: emplid,
                                fecha:
                                    '', // Aquí puedes agregar la fecha si es necesario
                              ),
                            ),
                          );
                        } else {
                          // ignore: use_build_context_synchronously
                          alert.showAlertDialogError(
                            // ignore: use_build_context_synchronously
                            context,
                            'Datos incorrectos',
                            'No se encontraron resultados para esta búsqueda',
                          );
                        }
                      } else {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error en la solicitud'),
                            duration: Duration(seconds: 5),
                            backgroundColor: Colors.red,
                          ),
                        );
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
