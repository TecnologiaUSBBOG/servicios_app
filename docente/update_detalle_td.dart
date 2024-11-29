import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:servicios/screens/docente/detalle_td.dart';
import 'package:servicios/screens/funcionalidad.dart';

class UpdateDetalleTDScreenD extends StatefulWidget {
  final String iddetallesession;
  final String fechainicio;
  final String fechafin;
  final String actividad;
  final String acuerdos;
  final String asistencia;
  final String codigoestudiantil;
  final String nombreestudiante;
  final String ciclo;
  final String sesion;
  final String nombreCurso;
  final String curso;
  final String fechaTutoria;
  final String documento;

  const UpdateDetalleTDScreenD({
    super.key,
    required this.iddetallesession,
    required this.fechainicio,
    required this.fechafin,
    required this.actividad,
    required this.acuerdos,
    required this.asistencia,
    required this.codigoestudiantil,
    required this.nombreestudiante,
    required this.ciclo,
    required this.sesion,
    required this.nombreCurso,
    required this.curso,
    required this.fechaTutoria,
    required this.documento,
  });

  @override
  // ignore: library_private_types_in_public_api
  _UpdateDetalleTDScreenDState createState() => _UpdateDetalleTDScreenDState();
}

class _UpdateDetalleTDScreenDState extends State<UpdateDetalleTDScreenD> {
  Funcionalidad alert = Funcionalidad();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // ignore: unused_field
  final List<Map<String, dynamic>> _sessionDetails = [];
  List<bool> asistenciaEstudiantes = [];

  // ignore: unused_field
  final bool _isLoading = true;
  bool asistencia = false;

  final TextEditingController _nombreEstudianteController =
      TextEditingController();
  final TextEditingController _codigoestudiantilController =
      TextEditingController();
  final TextEditingController _actividadController = TextEditingController();
  final TextEditingController _acuerdosController = TextEditingController();
  final TextEditingController _inicioTutoriaController =
      TextEditingController();
  final TextEditingController _finTutoriaController = TextEditingController();
  final TextEditingController _asistenciaController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    cargardatos();
    //crearDetalle();
    // _datosEstudiante(widget.groupID);
  }

  void cargardatos() {
    _inicioTutoriaController.text = widget.fechainicio;
    _finTutoriaController.text = alert.fechaformatea(widget.fechafin);
    _nombreEstudianteController.text = widget.nombreestudiante;
    _codigoestudiantilController.text = widget.codigoestudiantil;
    _actividadController.text = widget.actividad;
    _acuerdosController.text = widget.acuerdos;
    _asistenciaController.text = widget.asistencia;
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

  Future<void> _selectDate(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextStyle? style = theme.textTheme.titleMedium;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
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
        _selectTime(context);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: colorScheme.copyWith(
              primary: Colors.orange,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        _finTutoriaController.text =
            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year} ${selectedTime.hour}:${selectedTime.minute}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorias en Invidual - detallado'),
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              const SizedBox(height: 60),
              TextFormField(
                controller: _inicioTutoriaController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Inicio de la tutoría',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _finTutoriaController,
                decoration: const InputDecoration(
                  labelText: 'Fin de la tutoría',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () {
                  _selectDate(context);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, seleccione una fecha de fin de tutoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nombreEstudianteController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Nombre del estudiante',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _codigoestudiantilController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Codigo  estudiantil',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _actividadController,
                decoration: const InputDecoration(
                  labelText: 'Actividad realizada',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la actividad realizada';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _acuerdosController,
                decoration: const InputDecoration(
                  labelText: 'Acuerdos y compromisos',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la actividad realizada';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _asistenciaController,
                decoration: const InputDecoration(
                  labelText: 'Asistencia',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _startLoadingAnimation();
                    actualizar();
                  } else {
                    alert.showAlertDialogError(context, 'Error',
                        'Por favor, complete todos los campos correctamente.');
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Guardar cambios',
                    style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> actualizar() async {
    const url =
        'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasUpdateDetalleTB';

    Map<String, dynamic> datosFormulario = {
      'NUMEROSESION': widget.iddetallesession,
      'CODIGOESTUDIANTE': _codigoestudiantilController.text,
      'ACTIVIDAD': _actividadController.text,
      'ACUERDOS': _acuerdosController.text,
      'ASISTENCIA': _asistenciaController.text,
      'FECH_FIN': _finTutoriaController.text,
    };
    try {
      final response = await http.post(
        Uri.parse(url),
        body: datosFormulario,
      );
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Check for success message in the response
        if (jsonResponse['success'] != null) {
          // ignore: use_build_context_synchronously
          alert.showAlertDialogSuccess(
              // ignore: use_build_context_synchronously
              context,
              'DETALLE',
              jsonResponse['success'], // Use the success message from JSON
              'pro',
              (BuildContext context) => DetalleTDScreenD(
                  ciclo: widget.ciclo,
                  documento: widget.documento,
                  sesion: widget.sesion,
                  nombreCurso: widget.nombreCurso,
                  fechaTutoria: widget.fechaTutoria,
                  curso: widget.curso));
        } else {
          // Handle unexpected response structure
          alert.showAlertDialogError(
              // ignore: use_build_context_synchronously
              context, 'Error', 'No se recibió el mensaje de éxito.');
        }
      } else {
        // Handle non-200 responses
        // ignore: use_build_context_synchronously
        alert.showAlertDialogError(context, 'Error',
            'Error al actualizar el detalle. Código de estado: ${response.statusCode}');
      }
    } catch (error) {
      // Handle exceptions
      // ignore: use_build_context_synchronously
      alert.showAlertDialogError(context, 'Error', 'Ocurrió un error: $error');
    }
  }
}
