// ignore_for_file: unnecessary_nullable_for_final_variable_declarations

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:servicios/globals.dart';
import 'package:servicios/screens/docente/detalle_gd.dart';
//import 'package:servicios/screens/docente/detalle_td.dart';
import 'package:servicios/screens/funcionalidad.dart';

class CrearDGDScreenD extends StatefulWidget {
  final String sesion;
  final String groupID;
  final String fechaTuto;
  final String tematica;
  final String curso;

  const CrearDGDScreenD(
      {super.key,
      required this.sesion,
      required this.groupID,
      required this.fechaTuto,
      required this.tematica,
      required this.curso});

  @override
  // ignore: library_private_types_in_public_api
  _CrearDGDScreenDState createState() => _CrearDGDScreenDState();
}

class _CrearDGDScreenDState extends State<CrearDGDScreenD> {
  Funcionalidad alert = Funcionalidad();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // ignore: unused_field
  List<Map<String, dynamic>> _sessionDetails = [];
  List<bool> asistenciaEstudiantes = [];

  // ignore: unused_field
  bool _isLoading = true;
  bool asistencia = false;

  final TextEditingController _numeroSesionController = TextEditingController();
  final TextEditingController? _actividadController = TextEditingController();
  final TextEditingController? _acuerdosController = TextEditingController();
  final TextEditingController? _inicioTutoriaController =
      TextEditingController();
  final TextEditingController? _finTutoriaController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _numeroSesionController.text = widget.sesion;
    _inicioTutoriaController!.text = widget.fechaTuto;
    //crearDetalle();
    _datosEstudiante(widget.groupID);
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

  List<Widget> _buildStudentDetails(List<Map<String, dynamic>> students) {
    List<Widget> widgets = [];

    // Asegúrate de que la lista de asistencia tenga el mismo tamaño que la lista de estudiantes
    if (asistenciaEstudiantes.length != students.length) {
      asistenciaEstudiantes = List<bool>.filled(students.length, false);
    }

    for (int i = 0; i < students.length; i++) {
      widgets.add(
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.orange,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            title: Text(
              'Documento: ${students[i]['cedula']}', // Cambiado a 'cedula'
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Nombre: ${students[i]['nombres']}', // Cambiado a 'nombres'
              style: const TextStyle(fontSize: 14),
            ),
            trailing: Checkbox(
              value: asistenciaEstudiantes[i],
              onChanged: (bool? value) {
                setState(() {
                  asistenciaEstudiantes[i] = value ?? false;
                });
              },
              activeColor: Colors.orange,
            ),
          ),
        ),
      );
    }

    return widgets;
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
                'Detallado de sesión grupal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ..._buildStudentDetails(_sessionDetails),
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _startLoadingAnimation();
                    crearDetalle(
                      estudiantesData: _sessionDetails,
                      asistenciaEstudiantes: asistenciaEstudiantes,
                      numeroSesion: _numeroSesionController.text,
                      fechaInicio: _inicioTutoriaController!.text,
                      fechaFin: _finTutoriaController!.text,
                      actividad: _actividadController!.text,
                      acuerdos: _acuerdosController!.text,
                      idGrupo: widget.groupID,
                    );
                  } else {
                    alert.showAlertDialogError(context, 'Error',
                        'Por favor, complete todos los campos correctamente.');
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

  Future<void> _datosEstudiante(String groupID) async {
    setState(() {
      _isLoading = true; // Asegúrate de que esta variable esté definida
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasObtenerDatosEstudiantesGrupal'),
        body: {'ID_GRUPO': groupID},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verifica si el JSON es una lista y contiene elementos
        if (data is List && data.isNotEmpty) {
          setState(() {
            // Mapea los datos a una lista de mapas
            _sessionDetails = data.map<Map<String, dynamic>>((item) {
              // Para depuración
              return {
                'cedula': item['CEDULA']?.toString() ?? 'No disponible',
                'nombres': item['NOMBRES']?.toString() ?? 'No disponible',
              };
            }).toList();
          });
        } else {
          // Manejar el caso donde no hay datos
          setState(() {
            _sessionDetails = []; // O manejar como desees
          });
        }
      } else {
        throw Exception(
            'Error al cargar los detalles del estudiante: ${response.statusCode}');
      }
    } catch (error) {
      // Manejo de errores
    } finally {
      setState(() {
        _isLoading = false; // Asegúrate de que esta variable esté definida
      });
    }
  }

  Future<void> crearDetalle({
    required List<Map<String, dynamic>> estudiantesData,
    required List<bool> asistenciaEstudiantes,
    required String numeroSesion,
    required String fechaInicio,
    required String fechaFin,
    required String actividad,
    required String acuerdos,
    required String idGrupo,
  }) async {
    const url =
        'https://academia.usbbog.edu.co/centralizacion_servicios_ios/API/Tutorias/DocentesTutoria/CrearDetalleTutoriaGrupal.php';

    List<Map<String, dynamic>> asistenciaData = [];

    for (int i = 0; i < estudiantesData.length; i++) {
      Map<String, dynamic> estudianteData = {
        'CEDULA': estudiantesData[i]['CEDULA'],
        'NOMBRES': estudiantesData[i]['NOMBRES'],
        'ASISTENCIA': asistenciaEstudiantes[i] ? 'Si' : 'No',
      };
      asistenciaData.add(estudianteData);
    }

    Map<String, dynamic> datosFormulario = {
      'ESTUDIANTES': jsonEncode(estudiantesData),
      'ASISTENCIA': jsonEncode(asistenciaData),
      'NUMEROSESION': numeroSesion,
      'FECHA_INICIO': fechaInicio,
      'FECHA_FIN': fechaFin,
      'ACTIVIDAD': actividad,
      'ACUERDOS': acuerdos,
      'ID_GRUPO': idGrupo,
      'DOC_DOC': globalCodigoDocente,
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
            'Detalle Creado',
            'pro',
            (BuildContext context) => DetalleTDScreenD(
                  sesion: numeroSesion,
                  groupID: idGrupo,
                  curso: widget.curso,
                  tematica: widget.tematica,
                  fechaTutoria: fechaInicio,
                  filterestudiantes: const [],
                ));
      } else {}
    } catch (error) {
      throw ();
    }
  }
}
