import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:servicios/globals.dart';
import 'package:servicios/screens/docente/detalle_td.dart';
import 'package:servicios/screens/funcionalidad.dart';

class CrearDDScreenD extends StatefulWidget {
  final String ciclo;
  final String documento;
  final String sesion;
  final String nombre;
  final String codigoEstudiante;
  final String fechaTutoria;
  final String curso;

  const CrearDDScreenD({
    super.key,
    required this.ciclo,
    required this.documento,
    required this.sesion,
    required this.nombre,
    required this.codigoEstudiante,
    required this.fechaTutoria,
    required this.curso,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CrearDDScreenDState createState() => _CrearDDScreenDState();
}

class _CrearDDScreenDState extends State<CrearDDScreenD> {
   Funcionalidad alert= Funcionalidad(); 
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // ignore: unused_field
  final List<Map<String, dynamic>> _sessionDetails = [];
  // ignore: unused_field
  final bool _isLoading = true;

  final TextEditingController _numeroSesionController = TextEditingController();
  final TextEditingController _nombreEstudianteController =
      TextEditingController();
  final TextEditingController _documentoEstudianteController =
      TextEditingController();
  final TextEditingController _codigoEstudianteController =
      TextEditingController();
  final TextEditingController _asistenciaController = TextEditingController();
  // ignore: unnecessary_nullable_for_final_variable_declarations
  final TextEditingController? _actividadController = TextEditingController();
  // ignore: unnecessary_nullable_for_final_variable_declarations
  final TextEditingController? _acuerdosController = TextEditingController();
  // ignore: unnecessary_nullable_for_final_variable_declarations
  final TextEditingController? _inicioTutoriaController =
      TextEditingController();
  // ignore: unnecessary_nullable_for_final_variable_declarations
  final TextEditingController? _finTutoriaController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  // ignore: unnecessary_nullable_for_final_variable_declarations
  final TextEditingController? _cursoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _documentoEstudianteController.text = widget.documento;
    _numeroSesionController.text = widget.sesion;
    _nombreEstudianteController.text = widget.nombre;
    _codigoEstudianteController.text = widget.codigoEstudiante;
    _inicioTutoriaController!.text = widget.fechaTutoria;
    _cursoController!.text = widget.curso;
    //crearDetalle(widget.ciclo);
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
        _finTutoriaController!.text =
            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year} ${selectedTime.hour}:${selectedTime.minute}';
      });
    }
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

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Detalle'),
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
              const Text(
                'Detallado de sesión',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _numeroSesionController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Número de sesión',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nombreEstudianteController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Nombre estudiante',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _documentoEstudianteController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Documento',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _codigoEstudianteController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Código estudiantil',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Asistencia',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem<String>(
                    value: 'Si',
                    child: Text('Si asistió'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'No',
                    child: Text('No asistió'),
                  ),
                ],
                onChanged: (value) {
                  _asistenciaController.text = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, seleccione una opción de asistencia';
                  }
                  return null;
                },
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
                controller: _inicioTutoriaController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Inicio de la tutoría',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () {
                  _selectDate(context);
                },
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _startLoadingAnimation();
                    crearDetalle(widget.ciclo);
                  } else {
                    alert.showAlertDialogError(context, 'Error', 'Por favor, complete todos los campos correctamente.');
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Crear detalle',
                    style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> crearDetalle(String ciclo) async {
    // ignore: prefer_const_declarations
    final url =
        'https://academia.usbbog.edu.co/centralizacion_servicios_ios/API/Tutorias/DocentesTutoria/CrearDetalleTutoria.php';

    Map<String, String> datosFormulario = {
      'NUMEROSESION': _numeroSesionController.text,
      'NOMBRE_EST': _nombreEstudianteController.text,
      'DOCUMENTO_EST': _documentoEstudianteController.text,
      'CODIGO_EST': _codigoEstudianteController.text,
      'ACTIVIDAD': _actividadController?.text ?? '',
      'ACUERDO': _acuerdosController?.text ?? '',
      'ASISTENCIA': _asistenciaController.text,
      'FECH_INICIO': _inicioTutoriaController!.text,
      'FECH_FIN': _finTutoriaController!.text,
      'CURSO': _cursoController!.text,
      'DOC_DOC': globalCodigoDocente,
      'CICLO': ciclo,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: datosFormulario,
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        alert.showAlertDialogSuccess(context,'DETALLE','Detalle Creado','pro',(BuildContext context) => DetalleTDScreenD(ciclo: ciclo, documento: _documentoEstudianteController.text, sesion: _numeroSesionController.text, nombreCurso: _cursoController.text, fechaTutoria:widget.fechaTutoria , curso: _cursoController.text));
      } else {}
      // ignore: empty_catches
    } catch (error) {}
  }
}
