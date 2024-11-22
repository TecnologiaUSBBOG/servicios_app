import 'dart:convert';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:servicios/screens/docente/Credenciales_d2.dart';
import 'package:servicios/screens/docente/Credenciales_d3.dart';
import 'package:servicios/screens/funcionalidad.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CredencialesEScreenD(),
    );
  }
}

class CredencialesEScreenD extends StatefulWidget {
  const CredencialesEScreenD({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CredencialesEScreenDState createState() => _CredencialesEScreenDState();
}

class _CredencialesEScreenDState extends State<CredencialesEScreenD> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  // MaskTextInputFormatter _dateMaskFormatter = MaskTextInputFormatter(
  //     mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});

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
    Funcionalidad alert = Funcionalidad();
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionTitle('Datos del Profesor'),
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
                      final response = await http.post(
                        Uri.parse(
                          'https://academia.usbbog.edu.co/centralizacion_servicios_ios/API/Credenciales/Validacion.php',
                        ),
                        body: {
                          'identificacion': _idController.text,
                          'fecha': _dateController.text,
                        },
                      );
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      if (response.statusCode == 200) {
                        Map<String, dynamic> data = json.decode(response.body);
                        String usuarioAsis = data['USUARIO_ASIS']?.trim() ?? '';
                        String correoInstitucional =
                            data['CORREO_INSTITUCIONAL']?.trim() ?? '';
                        String correoPersonal =
                            data['CORREO_PERSONAL']?.trim() ?? '';

                        if (usuarioAsis.isNotEmpty &&
                            correoInstitucional.isNotEmpty) {
                          if (correoPersonal.isNotEmpty &&
                              correoPersonal != (null) &&
                              correoPersonal != 'DOCENTE') {
                            Navigator.push(
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(
                                builder: (context) => CredencialesD2ScreenE(
                                  usuarioAsis: data['USUARIO_ASIS'],
                                  correoInstitucional:
                                      data['CORREO_INSTITUCIONAL'],
                                  correoPersonal: data['CORREO_PERSONAL'],
                                  tipo: data['TIPO'],
                                  documento: data['DOCUMENTO'],
                                  emplid: data['CODIGO'],
                                  fecha: data['FECHA_NACIMIENTO'],
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(
                                builder: (context) => CredencialesD3ScreenE(
                                  usuarioAsis: data['USUARIO_ASIS'],
                                  correoInstitucional:
                                      data['CORREO_INSTITUCIONAL'],
                                  tipo: data['TIPO'],
                                  documento: data['DOCUMENTO'],
                                  emplid: data['CODIGO'],
                                  fecha: data['FECHA_NACIMIENTO'],
                                ),
                              ),
                            );
                          }
                          //}
                        } else {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'No se encontraron resultados para esta búsqueda.',
                              ),
                              duration: Duration(seconds: 5),
                              backgroundColor: Colors.red,
                            ),
                          );
                          // ignore: use_build_context_synchronously
                          alert.showAlertDialogError(context,'Error','No se encontraron resultados para esta búsqueda.');
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
                        // ignore: use_build_context_synchronously
                        alert.showAlertDialogError(context,'Error','Error en la solicitud');
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
