import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:servicios/globals.dart';
import 'package:servicios/screens/docente/sesion_td.dart';
import 'package:servicios/screens/funcionalidad.dart';

class UpdateSesionIndScreenD extends StatefulWidget {
  final String numerosesion;
  final String periodoacademico;
  final String tipotutoria;
  final String facultad;
  final String programa;
  final String curso;
  final String profesor;
  final String tematica;
  final String modalidad;
  final String metologia;
  final String lugar;
  final String fechaTutoria;
  final String documento;

  const UpdateSesionIndScreenD(
      {super.key,
      required this.numerosesion,
      required this.periodoacademico,
      required this.tipotutoria,
      required this.facultad,
      required this.programa,
      required this.curso,
      required this.profesor,
      required this.tematica,
      required this.modalidad,
      required this.metologia,
      required this.lugar,
      required this.fechaTutoria,
      required this.documento});

  @override
  State<UpdateSesionIndScreenD> createState() => _UpdateSesionIndScreenDState();
}

class _UpdateSesionIndScreenDState extends State<UpdateSesionIndScreenD> {
  Funcionalidad alert = Funcionalidad();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // ignore: unused_field
  final List<Map<String, dynamic>> _sessionDetails = [];
  // ignore: unused_field
  final bool _isLoading = true;

  late String profesor;
  final TextEditingController _numeroSesionController = TextEditingController();
  final TextEditingController _docuemtoController = TextEditingController();
  final TextEditingController _cicloController = TextEditingController();
  final TextEditingController _tipoTutoriaController =
      TextEditingController(text: 'Tutoría académica');
  final TextEditingController _docenteEncargadoController =
      TextEditingController();
  // ignore: unnecessary_nullable_for_final_variable_declarations
  final TextEditingController? _tematicaTutoriaController =
      TextEditingController();
  final TextEditingController _modalidadController = TextEditingController();
  final TextEditingController _metodologiaController =
      TextEditingController(text: 'Individual');
  // ignore: unnecessary_nullable_for_final_variable_declarationss, unnecessary_nullable_for_final_variable_declarations
  final TextEditingController? _fechaTutoriaController =
      TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  // ignore: unnecessary_nullable_for_final_variable_declarations
  final TextEditingController? _lugarTutoriaController =
      TextEditingController();

  //++++++++++++++++++++++++++++++++++
  TextEditingController textFieldController = TextEditingController();
  List<String> estudiantesEncontrados = [];
  List<String> selectedStudents = [];
  bool showEstudiantesList = false;
  bool atLeastOneStudentSelected = false;
  List<String> cicloE = [];
  //++++++++++++++++++++++++++++++++++

  String fechaformatea(String fecha) {
    try {
      DateTime dateTime =
          DateTime.parse(fecha); // Asegúrate de que 'fecha' esté en formato ISO
      return DateFormat('MMM dd, yyyy')
          .format(dateTime); // Cambia el formato según sea necesario
    } catch (e) {
      return fecha; // Retorna la fecha original si hay un error
    }
  }

  String selectedOpcionFacultad = '';
  String selectedOpcionPrograma = '';
  String selectedOpcionCurso = '';
  List<Map<String, dynamic>> _opcionFacultadList = [];
  List<Map<String, dynamic>> _opcionProgramaAcademicoList = [];
  List<Map<String, dynamic>> _opcionCursoList = [];

  @override
  void initState() {
    super.initState();
    _loadOpcFacultad();
    _loadOpcProgramaAcademico();
    _loadOpcCurso();
    cargardatos();
  }

  void cargardatos() {
    _numeroSesionController.text = widget.numerosesion;
    _cicloController.text = widget.periodoacademico;
    _tipoTutoriaController.text = widget.tipotutoria;
    _docenteEncargadoController.text = widget.profesor;
    _tematicaTutoriaController?.text = widget.tematica;
    _modalidadController.text = widget.modalidad;
    _metodologiaController.text = widget.metologia;
    _lugarTutoriaController?.text = widget.lugar;

    // Formatear la fecha usando fechaformatea
    // Para depuración
    _fechaTutoriaController?.text = fechaformatea(widget.fechaTutoria);
  }

  Future<void> _loadOpcFacultad() async {
    try {
      List<Map<String, dynamic>> opcFacultadData = await getOpcFacultad();

      setState(() {
        _opcionFacultadList = opcFacultadData;

        if (_opcionFacultadList.isNotEmpty) {
          selectedOpcionFacultad = _opcionFacultadList[0]['id'];
        } else {
          selectedOpcionFacultad = 'Sin opciones disponibles';
        }
      });
    } catch (e) {
      setState(() {
        _opcionFacultadList = [];
        selectedOpcionFacultad = 'Error al cargar opciones';
      });
    }
  }

  Future<void> _loadOpcProgramaAcademico() async {
    try {
      List<Map<String, dynamic>> opcProgramaData =
          await getOpcPrograma(selectedOpcionFacultad);

      setState(() {
        _opcionProgramaAcademicoList = opcProgramaData;
        if (_opcionProgramaAcademicoList.isNotEmpty) {
          selectedOpcionPrograma = _opcionProgramaAcademicoList[0]['id'];
        } else {
          selectedOpcionPrograma = 'Sin opciones disponibles';
        }
      });
    } catch (e) {
      setState(() {
        _opcionProgramaAcademicoList = [];
        selectedOpcionPrograma = 'Error al cargar opciones';
      });
    }
  }

  Future<void> _loadOpcCurso() async {
    try {
      List<Map<String, dynamic>> opcCursoData =
          await getOpcCurso(selectedOpcionPrograma);

      setState(() {
        _opcionCursoList = opcCursoData;

        if (_opcionCursoList.isNotEmpty) {
          selectedOpcionCurso = _opcionCursoList[0]['id'];
        } else {
          selectedOpcionCurso = 'Sin opciones disponibles';
        }
      });
    } catch (e) {
      setState(() {
        _opcionCursoList = [];
        selectedOpcionCurso = 'Error al cargar opciones';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // Formato ISO 8601
        _fechaTutoriaController!.text =
            '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')} ${selectedTime.hour}:${selectedTime.minute}';
      });
    }
  }

  Widget _buildDropdownFieldWithFacultad(
      String label, List<String> opciones, String identifier) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        //border: OutlineInputBorder(),
      ),
      items: _opcionFacultadList.map((map) {
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
      value: selectedOpcionFacultad.isNotEmpty ? selectedOpcionFacultad : null,
      onChanged: (String? value) async {
        if (value != null) {
          setState(() {
            selectedOpcionFacultad = value;
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

  Widget _buildDropdownFieldWithPrograma(
      String label, List<String> opciones, String identifier) {
    // Ordenar _opcionFacultadList moviendo widget.facultad al principio
    _opcionProgramaAcademicoList.sort((a, b) {
      // Si a es igual a widget.facultad, lo coloca primero
      if (a['text'] == widget.programa) {
        return -1; // Retorna -1 para a antes que b
      }
      // Si b es igual a widget.facultad, lo coloca primero
      else if (b['text'] == widget.programa) {
        return 1; // Retorna 1 para b antes que a
      }
      // De lo contrario, compara normalmente
      else {
        return a['text']!.compareTo(b['text']!);
      }
    });

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
      ),
      items: _opcionProgramaAcademicoList.map((map) {
        return DropdownMenuItem<String>(
          value: map['id'],
          child: SizedBox(
              width: 300,
              child: SizedBox(
                width: 300,
                child: Text(
                  map['text'],
                  overflow: TextOverflow.ellipsis,
                ),
              )),
        );
      }).toList(),
      value: selectedOpcionPrograma,
      validator: (value) {
        if (opciones.isEmpty || value == null || value.isEmpty) {
          return 'Por favor, seleccione una Facultad';
        }
        return null;
      },
      onChanged: (String? value) async {
        if (value != null) {
          setState(() {
            selectedOpcionPrograma = value;
          });
          _startLoadingAnimation();
          try {
            await _loadOpcCurso();
          } finally {
            _stopLoadingAnimation();
          }
        }
      },
    );
  }

  Widget _buildDropdownFieldWithCurso(
      String label, List<String> opciones, String identifier) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        //border: OutlineInputBorder(),
      ),
      items: _opcionCursoList.map((map) {
        return DropdownMenuItem<String>(
          value: map['id'],
          child: SizedBox(width: 300, child: Text(map['text'])),
        );
      }).toList(),
      value: selectedOpcionCurso,
      validator: (value) {
        if (opciones.isEmpty || value == null || value.isEmpty) {
          return 'Por favor, seleccione $label';
        }
        return null;
      },
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            selectedOpcionCurso = value;
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
        title: const Text('Asignación de tutoría'),
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
              const SizedBox(height: 20),
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
                controller: _cicloController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Periodo académico',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _tipoTutoriaController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Tipo de tutoría',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              _buildDropdownFieldWithFacultad(
                'Facultad',
                _opcionFacultadList
                    .map((map) => map['text'].toString())
                    .toList(),
                selectedOpcionFacultad,
              ),
              const SizedBox(height: 20),
              _buildDropdownFieldWithPrograma(
                'Programa académico',
                _opcionProgramaAcademicoList
                    .map((map) => map['text'].toString())
                    .toList(),
                selectedOpcionPrograma,
              ),
              const SizedBox(height: 20),
              _buildDropdownFieldWithCurso(
                'Curso',
                _opcionCursoList.map((map) => map['text'].toString()).toList(),
                selectedOpcionCurso,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _docenteEncargadoController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Profesor responsable',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _tematicaTutoriaController,
                decoration: const InputDecoration(
                  labelText: 'Temática',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la tematica';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: widget.modalidad,
                decoration: const InputDecoration(
                  labelText: 'Modalidad',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem<String>(
                    value: 'Presencial',
                    child: Text('Presencial'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Virtual',
                    child: Text('Virtual'),
                  ),
                ],
                onChanged: (value) {
                  _modalidadController.text = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, seleccione modalidad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _metodologiaController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Metodología',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _fechaTutoriaController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de la tutoría',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () {
                  _selectDate(context);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, seleccione una fecha de tutoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _lugarTutoriaController,
                decoration: const InputDecoration(
                  labelText: 'Lugar de la tutoría o link de invitación',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el lugar de tuturía.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _docuemtoController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Documento',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    enviarSolicitud();
                  } else {
                    alert.showAlertDialogError(context, 'Error',
                        'No se puedo crear la sesion de tutoria');
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Guardar Cambios',
                    style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getOpcFacultad() async {
    final response = await http.post(
      Uri.parse(
          'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasOpcionFacultad'),
    );

    if (response.statusCode == 200) {
      List<dynamic> opcFincDataList = json.decode(response.body);
      return opcFincDataList
          .map<Map<String, dynamic>>((opc) => {
                'text': opc['FACULTAD'].toString(),
                'id': opc['FACULTAD2'].toString(), // Cambiado a FACULTAD2
              })
          .toList();
    } else {
      throw Exception('Error al cargar todas las opciones');
    }
  }

  Future<List<Map<String, dynamic>>> getOpcPrograma(String programa) async {
    final response = await http.post(
        Uri.parse(
            'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasOpcionProgramaAcademico'),
        body: {'PROG_ACADEMICO': programa});

    if (response.statusCode == 200) {
      List<dynamic> opcFincDataList = json.decode(response.body);

      return opcFincDataList
          .map<Map<String, dynamic>>((opc) => {
                'text': opc['PROGRAMA'].toString(), // Cambiado a 'PROGRAMA'
                'id': opc['PROGRAMA2']
                    .toString(), // Cambiado a 'PROGRAMA2' si necesitas un ID
              })
          .toList();
    } else {
      throw Exception('Error al cargar todas las opciones');
    }
  }

  Future<List<Map<String, dynamic>>> getOpcCurso(String curso) async {
    final response = await http.post(
        Uri.parse(
            'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasOpcionCurso'),
        body: {'CURSO': curso});

    if (response.statusCode == 200) {
      List<dynamic> opcFincDataList = json.decode(response.body);

      return opcFincDataList
          .map<Map<String, dynamic>>((opc) => {
                'text': opc['MATERIA'].toString(), // Usar 'MATERIA' como texto
                'id': opc['MATERIA2'].toString(), // Usar 'MATERIA2' como ID
              })
          .toList();
    } else {
      throw Exception('Error al cargar todas las opciones');
    }
  }

  Future<void> enviarSolicitud() async {
    // ignore: prefer_const_declarations
    final url =
        'https://academia.usbbog.edu.co/centralizacion_servicios_ios/API/Tutorias/DocentesTutoria/updatetb.php';

    Map<String, dynamic> datosFormulario = {
      'ESTUDIANTES': _docuemtoController.text,
      'NUMEROSESION': _numeroSesionController.text,
      'PERIODOACADEMICO': _cicloController.text,
      'TIPOTUTORIA': _tipoTutoriaController.text,
      'FACULTAD': selectedOpcionFacultad,
      'PROGRAMA': selectedOpcionPrograma,
      'NOMBREDELCURSO': selectedOpcionCurso,
      'PROFESORRESPONSABLE': _docenteEncargadoController.text,
      'TEMATICA': _tematicaTutoriaController?.text ?? '',
      'MODALIDAD': _modalidadController.text,
      'METODOLOGIA': _metodologiaController.text,
      'FECHATUTORIA': _fechaTutoriaController?.text,
      'LUGAR': _lugarTutoriaController!.text,
      'DOCUMENTOP': globalCodigoDocente,
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
            'Sesion',
            'Actualizacion Sesion .',
            'pro',
            (BuildContext context) => SesionTDScreenD(
                ciclo: widget.periodoacademico, documento: widget.documento));
      } else {}
    } catch (e) {
      throw ();
    }
  }
}
