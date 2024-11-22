import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:servicios/screens/docente/detalle_td.dart';
import 'package:servicios/screens/funcionalidad.dart';

class UpdateDetalleGDScreenD extends StatefulWidget {
  final String iddetallesession;
  final String fechainicio;
  final String fechafin;
  final String actividad;
  final String acuerdos;
  final String asistencia;
  final String codigoestudiantil;
  final String nombreestudiante;
  final String idGrupo;

  const UpdateDetalleGDScreenD(
      {super.key,
      required this.iddetallesession,
      required this.fechainicio,
      required this.fechafin,
      required this.actividad,
      required this.acuerdos,
      required this.asistencia,
      required this.codigoestudiantil,
      required this.nombreestudiante,
      required this.idGrupo});

  @override
  // ignore: library_private_types_in_public_api
  _UpdateDetalleGDScreenDState createState() => _UpdateDetalleGDScreenDState();
}

class _UpdateDetalleGDScreenDState extends State<UpdateDetalleGDScreenD> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorias en grupos - detallado'),
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
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Fin de la tutoría',
                  border: OutlineInputBorder(),
                ),
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
        'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasUpdateDetalleGrupal';

    Map<String, dynamic> datosFormulario = {
      'CODIGOESTUDIANTE': _codigoestudiantilController.text,
      'ASISTENCIA': _asistenciaController.text,
      'NUMEROSESION': widget.iddetallesession,
      'ACTIVIDAD': _actividadController.text,
      'ACUERDOS': _acuerdosController.text,
      'ID_GRUPO': widget.idGrupo,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: datosFormulario,
      );
      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        alert.showAlertDialogSuccess(
            // ignore: use_build_context_synchronously
            context,
            'DETALLE',
            'Actualizado detalle',
            'pro',
            null);
        // Navigator.of(context).pop();
      } else {}
    } catch (error) {
      throw ();
    }
  }
}
