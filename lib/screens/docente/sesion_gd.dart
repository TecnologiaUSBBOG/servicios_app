import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:servicios/globals.dart';
import 'package:servicios/screens/docente/sesion_g.dart';
import 'package:servicios/screens/funcionalidad.dart';

class SesionGScreenD extends StatefulWidget {
  final String idGrupo;
  final List<Map<String, dynamic>> estudiantesgrupo;

  const SesionGScreenD(
      {super.key, required this.idGrupo, required this.estudiantesgrupo});

  @override
  State<SesionGScreenD> createState() => _SesionGScreenEState();
}

class _SesionGScreenEState extends State<SesionGScreenD> {
  Funcionalidad alert = Funcionalidad();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // ignore: unused_field
  final List<Map<String, dynamic>> _sessionDetails = [];
  // ignore: unused_field
  bool _isLoading = true;

  late String profesor;
  final TextEditingController _numeroSesionController = TextEditingController();
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
      TextEditingController(text: 'Grupal');
  // ignore: unnecessary_nullable_for_final_variable_declarations
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

  String selectedOpcionFacultad = '';
  String selectedOpcionPrograma = '';
  String selectedOpcionCurso = '';
  List<Map<String, dynamic>> _opcionFacultadList = [];
  List<Map<String, dynamic>> _opcionProgramaAcademicoList = [];
  List<Map<String, dynamic>> _opcionCursoList = [];

  @override
  void initState() {
    super.initState();
    // _fetchNextSessionNumber(widget.ciclo, widget.documento);
    // _cicloController.text = widget.ciclo;
    // _docmuentoEstudianteController.text = widget.documento;
    _loadOpcFacultad();
    _loadOpcProgramaAcademico();
    _loadOpcCurso();
    _profesorEncargado();
    obtenerNumeroSesion(widget.idGrupo);
    //enviarSolicitud();
    // traerdatos();

    //++++++++++++++++++++++++++++++++
    ciclo();
    //++++++++++++++++++++++++++++++++
  }

  Future<void> _loadOpcFacultad() async {
    try {
      List<Map<String, dynamic>> opcFacultadData = await getOpcFacultad();

      setState(() {
        _opcionFacultadList = opcFacultadData;

        if (_opcionFacultadList.isNotEmpty) {
          // Asignar el valor de 'FACULTAD' como el valor seleccionado
          selectedOpcionFacultad =
              _opcionFacultadList[0]['text']; // Cambiado a 'text'
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
          selectedOpcionPrograma = _opcionProgramaAcademicoList[0]['text'];
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
        _fechaTutoriaController!.text =
            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year} ${selectedTime.hour}:${selectedTime.minute}';
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
          value: map['text'],
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
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
      ),
      items: _opcionProgramaAcademicoList.map((map) {
        return DropdownMenuItem<String>(
          value: map['id'],
          child: SizedBox(
            width: 300,
            child: Text(map['text']),
          ),
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
          child: SizedBox(
            width: 300,
            child: Text(
              map['text'],
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
        title: const Text('Sessiones grupales'),
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
              const Text(
                'Asignación de tutoría grupal',
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
                child: const Text('Crear tutoría a estudiante',
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

  Future<void> _profesorEncargado() async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasProfesorEncargado'),
        body: {'DOC_DOC': globalCodigoDocente},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Verificar si el JSON es una lista y contiene elementos
        if (data is List && data.isNotEmpty && data[0]['PROFE'] != null) {
          String nombreProfesor = data[0]['PROFE'].toString();
          _docenteEncargadoController.text = nombreProfesor;
        } else {
          // Manejar el caso donde no hay datos o el campo 'PROFE' es nulo
          _docenteEncargadoController.text = 'No se encontró el profesor';
        }
      } else {
        throw Exception('Error al cargar el profesor encargado');
      }
    } catch (error) {
      // Manejar errores de conexión o de otro tipo
      _docenteEncargadoController.text = 'Error al cargar el profesor';
    } finally {
      setState(() {
        _isLoading = false; // Asegúrate de que esta variable esté definida
      });
    }
  }

  //DEVUELVE EL VALOR DEL PROFESOR
  String mapText(String? value) {
    return _opcionFacultadList.firstWhere((element) => element['id'] == value,
        orElse: () => {'text': 'No encontrado'})['text']!;
  }

  Future<void> enviarSolicitud() async {
    // ignore: prefer_const_declarations
    final url =
        'https://academia.usbbog.edu.co/centralizacion_servicios_ios/API/Tutorias/DocentesTutoria/CrearTutoriaGrupal.php';

    List<Map<String, String>> estudiantesData = [];

    for (Map<String, dynamic> estudianteMap in widget.estudiantesgrupo) {
      // Obtener el nombre y el documento del estudiante del mapa

      String documento = estudianteMap['CEDULA'];

      Map<String, String> estudianteData = {
        'DOCUMENTO_EST': documento,
      };
      estudiantesData.add(estudianteData);
    }

    Map<String, dynamic> datosFormulario = {
      'ESTUDIANTES': jsonEncode(estudiantesData),
      'NUMEROSESION': _numeroSesionController.text,
      'PERIODOACADEMICO': _cicloController.text,
      'TIPOTUTORIA': _tipoTutoriaController.text,
      'FACULTAD': mapText(selectedOpcionFacultad),
      'PROGRAMA': selectedOpcionPrograma,
      'NOMBREDELCURSO': selectedOpcionCurso,
      'PROFESORRESPONSABLE': _docenteEncargadoController.text,
      'TEMATICA': _tematicaTutoriaController?.text ?? '',
      'MODALIDAD': _modalidadController.text,
      'METODOLOGIA': _metodologiaController.text,
      'FECHATUTORIA': _fechaTutoriaController!.text,
      'LUGAR': _lugarTutoriaController!.text,
      'DOCUMENTOP': globalCodigoDocente,
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
            'Sesion',
            'Sesión de tutoría creada y enviada.',
            'pro',
            (BuildContext context) => SesionGVScreenD(idGrupo: widget.idGrupo));
      } else {}
    } catch (e) {
      throw ();
    }
  }

  void buscarEstudiantes(String query) async {
    final response = await http.post(
      Uri.parse(
          'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasBuscarEstudiantes'),
      body: {'Consulta_InformacionEstudiante': query},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        estudiantesEncontrados = data.map((item) {
          // Puedes elegir cómo quieres mostrar los datos
          return '${item['DOCUMENTO_EST']} / Nombre ${item['NOMBRE']}';
        }).toList();
      });
    } else {
      // Manejar errores si la solicitud al servidor falla
      setState(() {
        estudiantesEncontrados = []; // Limpiar la lista en caso de error
      });
    }
  }

  void ciclo() async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasCiclo'),
      );

      if (response.statusCode == 200) {
        // Decodifica la respuesta JSON
        Map<String, dynamic> data = json.decode(response.body);

        // Asegúrate de que el campo 'CICLO' esté presente en la respuesta
        if (data.containsKey('CICLO')) {
          setState(() {
            String ciclo =
                data['CICLO'] as String; // Obtiene el ciclo como String
            _cicloController.text =
                ciclo; // Asigna el valor al controlador de texto
          });
        } else {
          throw Exception('Campo "CICLO" no encontrado en la respuesta');
        }
      } else {
        throw Exception('Failed to load ciclo data: ${response.statusCode}');
      }
    } catch (error) {
      // Manejo de errores, imprime el error en la consola
    }
  }

  void obtenerNumeroSesion(String idGrupo) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://apps.usbbog.edu.co:8080/prod/usbbogota/TutoriasD/TutoriasNumeroSesionGrupal'),
        body: {'ID_GRUPO': idGrupo},
      );

      if (response.statusCode == 200) {
        // Decodifica la respuesta JSON
        Map<String, dynamic> data = json.decode(response.body);

        // Verifica si el campo 'CANTIDAD' está presente en la respuesta
        if (data.containsKey('CANTIDAD')) {
          setState(() {
            // Asigna el valor de 'CANTIDAD' al controlador de texto
            _numeroSesionController.text = data['CANTIDAD'].toString();
          });
        } else {
          throw Exception('Campo "CANTIDAD" no encontrado en la respuesta');
        }
      } else {
        throw Exception(
            'Failed to load session number: ${response.statusCode}');
      }
    } catch (error) {
      // Manejo de errores, imprime el error en la consola
    }
  }
}
