// ignore: file_names
import 'package:flutter/material.dart';
import 'package:servicios/screens/estudiante/credito_e.dart';
import 'package:servicios/screens/estudiante/simulador_e.dart';
import 'package:servicios/screens/funcionalidad.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth.dart';
import '../../globals.dart';
import '../login.dart';
import 'credenciales_e.dart';
import 'horario_e.dart';
import 'icetex_e.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TutoriaEScreenE(),
    );
  }
}

class TutoriaEScreenE extends StatefulWidget {
  const TutoriaEScreenE({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TutoriaEScreenEState createState() => _TutoriaEScreenEState();
}

class _TutoriaEScreenEState extends State<TutoriaEScreenE> {
// Clave para el formulario
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controladores de texto para los campos de entrada
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _correoInstitucionalController =
      TextEditingController();
  final TextEditingController _tematicaTutoriaController =
      TextEditingController(); // Controlador para temática de tutoría

  // Listas para almacenar datos
  List<String> programas = [];
  List<String> programasAll = [];
  String correoEstudiante = '';

  // Variables para opciones seleccionadas
  String selectedOpcionProgramaT = '';
  String selectedOpcionCursoT = '';
  String selectedOpcionTeachT = '';

  // Listas para opciones de programas académicos, cursos y docentes
  List<Map<String, dynamic>> _opcionProgramaAcademicoListT = [];
  List<Map<String, dynamic>> _opcionCursoTList = [];
  List<Map<String, dynamic>> _opcionTeachTList = [];

  // Opción seleccionada por defecto
  String selectedOption = 'Individual';

  // Controlador para un campo de texto adicional
  TextEditingController textFieldController = TextEditingController();

  // Listas para estudiantes seleccionados y encontrados
  List<String> selectedStudents = [];
  List<String> estudiantesEncontrados = [];

  // Variables de estado para la interfaz
  bool showEstudiantesList = false;
  bool atLeastOneStudentSelected = false;

  @override
  @override
  void initState() {
    super.initState();

    // Cargar datos iniciales
    _loadOpcProgramaAcademico();
    _loadProgramas();
    _loadCorreoEstudiante();

    // Configurar el controlador de texto para buscar estudiantes
    textFieldController.addListener(() {
      if (textFieldController.text.isNotEmpty) {
        buscarEstudiantes(textFieldController.text);
      }
    });

    // Asignar valores iniciales a los controladores de texto
    _documentoController.text = globalDocumento ?? ''; // Manejo de nulos
    _usernameController.text = globalUsername ?? ''; // Manejo de nulos

    // Realizar búsqueda inicial si el campo no está vacío
    if (textFieldController.text.isNotEmpty) {
      buscarEstudiantes(textFieldController.text);
    }
  }

  Future<void> _loadProgramas() async {
    try {
      // Obtiene la lista de programas del estudiante
      List<String>? programasData =
          await getProgramasEstudiante(globalDocumento!);

      // Actualiza el estado con los programas obtenidos
      setState(() {
        programas = programasData.isNotEmpty
            ? programasData
            : []; // Asigna la lista o un arreglo vacío
      });
    } catch (e) {
      // Manejo de errores: imprime el error y asigna un arreglo vacío
      setState(() {
        programas = []; // Asegura que la lista esté vacía en caso de error
      });
    }
  }

  Future<void> _loadCorreoEstudiante() async {
    try {
      // Obtiene el correo del estudiante
      String correoData = await getCorreoEstudiante(globalDocumento!);

      // Actualiza el estado con el correo obtenido
      setState(() {
        correoEstudiante = correoData; // Asigna el correo obtenido
        _correoInstitucionalController.text =
            correoEstudiante; // Actualiza el controlador del campo de texto
      });
    } catch (e) {
      // Manejo de errores: imprime el error y asigna una cadena vacía
      setState(() {
        correoEstudiante =
            ''; // Asegura que el correo esté vacío en caso de error
        _correoInstitucionalController
            .clear(); // Limpia el campo de texto en caso de error
      });
    }
  }

  Future<void> _loadOpcProgramaAcademico() async {
    try {
      // Obtiene las opciones de programas académicos
      List<Map<String, dynamic>> opcProgramaData = await getOpcPrograma();

      setState(() {
        _opcionProgramaAcademicoListT = opcProgramaData;

        // Asigna la primera opción si no se ha seleccionado ninguna
        if (_opcionProgramaAcademicoListT.isNotEmpty) {
          selectedOpcionProgramaT = selectedOpcionProgramaT.isEmpty
              ? _opcionProgramaAcademicoListT[0]['id']
              : selectedOpcionProgramaT;
        } else {
          selectedOpcionProgramaT = 'Sin opciones disponibles';
        }
      });
    } catch (e) {
      // Manejo de errores: imprime el error y asigna un mensaje
      setState(() {
        _opcionProgramaAcademicoListT = [];
        selectedOpcionProgramaT = 'Error al cargar opciones';
      });
    }
  }

  Future<List<Map<String, dynamic>>> _loadOpcCursos(String programa) async {
    try {
      // Obtiene las opciones de cursos
      List<Map<String, dynamic>> opcCursoData = await getOpcCurso(programa);

      setState(() {
        _opcionCursoTList = opcCursoData;

        // Asigna la primera opción si hay cursos disponibles
        selectedOpcionCursoT = _opcionCursoTList.isNotEmpty
            ? _opcionCursoTList[0]['id']
            : 'Sin opciones disponibles';
      });

      return opcCursoData;
    } catch (e) {
      // Manejo de errores: imprime el error y asigna un mensaje
      setState(() {
        _opcionCursoTList = [];
        selectedOpcionCursoT = 'Error al cargar opciones';
      });

      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _loadOpcTeachT(String curso) async {
    try {
      List<Map<String, dynamic>> opcTeachData = await getOpcTeach(curso);

      setState(() {
        _opcionTeachTList = opcTeachData;

        if (_opcionTeachTList.isNotEmpty) {
          selectedOpcionTeachT = _opcionTeachTList[0]['id'];
        } else {
          selectedOpcionTeachT = 'Sin opciones disponibles';
        }
      });

      return opcTeachData;
    } catch (e) {
      setState(() {
        _opcionTeachTList = [];
        selectedOpcionTeachT = 'Error al cargar opciones';
      });

      return [];
    }
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

  Widget _buildTextField(
      String label, String hint, TextEditingController? controller) {
    return TextFormField(
      controller: controller,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (controller == null && (value == null || value.isEmpty)) {
          return 'Por favor, ingrese $label';
        }
        return null;
      },
    );
  }

  Widget _buildTextFieldUnloked(
      String label, String hint, TextEditingController? controller) {
    return TextFormField(
      controller: _tematicaTutoriaController,
      enabled: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingrese $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField(String label, List<String> opciones) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: opciones.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: (value) {
        if (opciones.isEmpty || value == null || value.isEmpty) {
          return 'Por favor, seleccione $label';
        }
        return null;
      },
      onChanged: (String? value) {},
    );
  }

  Widget _buildDropdownFieldWithProg(
      String label, List<String> opciones, String identifier) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
      ),
      items: _opcionProgramaAcademicoListT.map((map) {
        return DropdownMenuItem<String>(
          value: map['id'],
          child: SizedBox(
            width: 300,
            child: Text(map['text']),
          ),
        );
      }).toList(),
      value:
          selectedOpcionProgramaT.isNotEmpty ? selectedOpcionProgramaT : null,
      onChanged: (String? value) async {
        if (value != null) {
          setState(() {
            selectedOpcionProgramaT = value;
            selectedOpcionCursoT = '';
            _opcionCursoTList.clear();
            selectedOpcionTeachT = '';
            _opcionTeachTList.clear();
          });
          _startLoadingAnimation();
          try {
            await _loadOpcProgramaAcademico();
            await _loadOpcCursos(selectedOpcionProgramaT);
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
      items: _opcionCursoTList.map((map) {
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
      validator: (value) {
        if (opciones.isEmpty || value == null || value.isEmpty) {
          return 'Por favor, seleccione un Programa de tutoria';
        }
        return null;
      },
      value: selectedOpcionCursoT.isNotEmpty ? selectedOpcionCursoT : null,
      onChanged: (String? value) async {
        if (value != null) {
          setState(() {
            selectedOpcionCursoT = value;
            selectedOpcionTeachT = '';
            _opcionTeachTList.clear();
          });
          _startLoadingAnimation();
          try {
            await _loadOpcTeachT(selectedOpcionCursoT);
          } finally {
            _stopLoadingAnimation();
          }
        }
      },
    );
  }

  Widget _buildDropdownFieldWithTeach(
      String label, List<String> opciones, String identifier) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        //border: OutlineInputBorder(),
      ),
      items: _opcionTeachTList.map((map) {
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
      validator: (value) {
        if (opciones.isEmpty || value == null || value.isEmpty) {
          return 'Por favor, seleccione un curso ';
        }
        return null;
      },
      value: selectedOpcionTeachT,
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            selectedOpcionTeachT = value;
            _showAlertDialog(mapText(value), maphorario(value));
          });
        }
      },
    );
  }

  //DEVUELVE EL VALOR DEL PROFESOR
  String mapText(String? value) {
    return _opcionTeachTList.firstWhere((element) => element['id'] == value,
        orElse: () => {'text': 'No encontrado'})['text']!;
  }

  //DEVUELVE EL VALOR DE FRNAJA HORARIO
  String maphorario(String? value) {
    return _opcionTeachTList.firstWhere((element) => element['id'] == value,
        orElse: () => {'horario': 'No encontrado'})['horario']!;
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
    Funcionalidad alert = Funcionalidad();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Tutoría'),
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
              _buildTextField(
                  'Documento', 'Ingrese el documento', _documentoController),
              const SizedBox(height: 16),
              _buildTextField('Estudiante', 'Ingrese el nombre del estudiante',
                  _usernameController),
              const SizedBox(height: 16),
              _buildTextField('Correo institucional', 'Ingrese el correo',
                  _correoInstitucionalController),
              const SizedBox(height: 16),
              _buildDropdownField('Programa', programas),
              const SizedBox(height: 30),
              _buildSectionTitle('Datos de la tutoría'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(7.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  value: selectedOption,
                  onChanged: (String? value) {
                    setState(() {
                      selectedOption = value ?? '';
                    });
                  },
                  items: ['Individual', 'Grupal'].map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                ),
              ),
              if (selectedOption == 'Grupal') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: textFieldController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar estudiante',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () {
                    setState(() {
                      showEstudiantesList = true;
                    });
                  },
                ),
                if (showEstudiantesList &&
                    estudiantesEncontrados.isNotEmpty) ...[
                  // Lista de estudiantes encontrados
                  SizedBox(
                    // Agregado para envolver ListView y evitar conflictos de desplazamiento
                    height: 200, // Ajusta según sea necesario
                    child: ListView.builder(
                      itemCount: estudiantesEncontrados.length > 5
                          ? 5
                          : estudiantesEncontrados.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(estudiantesEncontrados[index]),
                          onTap: () {
                            setState(() {
                              selectedStudents
                                  .add(estudiantesEncontrados[index]);
                              textFieldController.clear();
                              showEstudiantesList = false;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                  'Selecciona un estudiante para eliminar'),
                              content: Column(
                                children: selectedStudents.map((student) {
                                  return ListTile(
                                    title: Text(student),
                                    onTap: () {
                                      setState(() {
                                        selectedStudents.remove(student);
                                        Navigator.of(context)
                                            .pop(); // Cierra el diálogo
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Eliminar',
                          style: TextStyle(
                            color: Colors.black,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  height: 150,
                  child: ListView(
                    children: selectedStudents.map((student) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                        child: ListTile(
                          title: Text(student),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _buildDropdownFieldWithProg(
                'Programa de la tutoria',
                _opcionProgramaAcademicoListT
                    .map((map) => map['text'].toString())
                    .toList(),
                selectedOpcionProgramaT,
              ),
              const SizedBox(height: 16),
              _buildDropdownFieldWithCurso(
                'Curso de la tutoría',
                _opcionCursoTList.map((map) => map['text'].toString()).toList(),
                selectedOpcionCursoT,
              ),
              const SizedBox(height: 16),
              _buildDropdownFieldWithTeach(
                'Profesores de tuturìa',
                _opcionCursoTList.map((map) => map['text'].toString()).toList(),
                selectedOpcionTeachT,
              ),
              const SizedBox(height: 16),
              _buildTextFieldUnloked(
                'Temática',
                'Tema a tratar en la tutoría',
                _tematicaTutoriaController,
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  _startLoadingAnimation();
                  if (selectedOption == 'Grupal' && selectedStudents.isEmpty) {
                    _stopLoadingAnimation();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Debe seleccionar al menos un estudiante para la opción grupal.'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 5),
                      ),
                    );
                  } else {
                    if (_formKey.currentState?.validate() ?? false) {
                      _stopLoadingAnimation();
                      enviarSolicitud();
                      alert.showAlertDialogSuccess(context, 'Datos Enviados',
                          'Solicitud Enviada', 'est', null);
                    } else {
                      _stopLoadingAnimation();

                      alert.showAlertDialogError(context, 'Error',
                          'Por favor, complete todos los campos requeridos');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Enviar solicitud',
                    style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>> getProgramasEstudiante(String documento) async {
    final response = await http.post(
      Uri.parse(
          'http://apps.usbbog.edu.co:8080/prod/usbbogota/app/TutoriaBuscarp'),
      body: {'CODIGO': documento},
    );
    if (response.statusCode == 200) {
      // Decodifica la respuesta JSON
      List<dynamic> programasData = json.decode(response.body);

      // Verifica si la lista no está vacía
      if (programasData.isNotEmpty) {
        // Devuelve la lista de programas como una lista de cadenas
        return programasData
            .map<String>((programa) => programa.toString())
            .toList();
      } else {
        throw Exception('No se encontraron programas para el estudiante.');
      }
    } else {
      throw Exception(
          'Error al cargar los programas del estudiante: ${response.statusCode}');
    }
  }

  Future<String> getCorreoEstudiante(String documento) async {
    final response = await http.post(
      Uri.parse(
          'http://apps.usbbog.edu.co:8080/prod/usbbogota/app/TutoriasBuscarC'),
      body: {'codigo': documento},
    );

    if (response.statusCode == 200) {
      // Decodifica la respuesta JSON
      List<dynamic> responseData = json.decode(response.body);
      // Verifica si hay al menos un elemento en la lista
      if (responseData.isNotEmpty && responseData[0].containsKey("correo")) {
        String correo = responseData[0]["correo"]
            .toString(); // Accede al primer elemento y su clave "correo"
        return correo;
      } else {
        throw Exception(
            'No se encontró el correo del estudiante en la respuesta');
      }
    } else {
      throw Exception('Error al cargar el correo del estudiante');
    }
  }

  Future<List<Map<String, dynamic>>> getOpcPrograma() async {
    final response = await http.post(
      Uri.parse(
          'http://apps.usbbog.edu.co:8080/prod/usbbogota/app/TutoriaPrograma'),
    );

    if (response.statusCode == 200) {
      // Decodifica la respuesta JSON
      List<dynamic> opcFincDataList = json.decode(response.body);
      // Verifica si la lista no está vacía
      if (opcFincDataList.isNotEmpty) {
        return opcFincDataList.map<Map<String, dynamic>>((opc) {
          return {
            'text': opc['D'].toString(), // Accede al campo 'D'
            'id': opc['R'].toString(), // Accede al campo 'R'
          };
        }).toList();
      } else {
        throw Exception(
            'No se encontraron opciones de programa en la respuesta');
      }
    } else {
      throw Exception(
          'Error al cargar todas las opciones: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getOpcCurso(String programa) async {
    final response = await http.post(
        Uri.parse(
            'http://apps.usbbog.edu.co:8080/prod/usbbogota/app/TutoriaCurso'),
        body: {'prog': programa});

    if (response.statusCode == 200) {
      // print('Cuerpo de la respuesta (Opciones de programa academico): ${response.body}');
      List<dynamic> opcFincDataList = json.decode(response.body);
      return opcFincDataList
          .map<Map<String, dynamic>>((opc) => {
                'text': opc['D'].toString(),
                'id': opc['R'].toString(),
              })
          .toList();
    } else {
      throw Exception('Error al cargar todas las opciones');
    }
  }

  Future<List<Map<String, dynamic>>> getOpcTeach(String curso) async {
    final response = await http.post(
        Uri.parse(
            'http://apps.usbbog.edu.co:8080/prod/usbbogota/app/TutoriaBuscarp'),
        body: {'curso': curso});
    if (response.statusCode == 200) {
      List<dynamic> opcFincDataList = json.decode(response.body);

      return opcFincDataList
          .map<Map<String, dynamic>>((opc) => {
                'horario': opc['HORARIO_TUTORIA'].toString(),
                'text': opc['PROFESOR'].toString(),
                'id': opc['NATIONAL_ID_DOC'].toString(),
              })
          .toList();
    } else {
      throw Exception('Error al cargar todas las opciones');
    }
  }

  void buscarEstudiantes(String query) async {
    try {
      // Codifica el query para evitar problemas con caracteres especiales
      Uri.encodeComponent(query);
      final response = await http.post(
        Uri.parse(
            'http://apps.usbbog.edu.co:8080/prod/usbbogota/app/TutoriaBuscarE'),
        body: {'CursoTutInformacionoria': query},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          // Mapea los datos para obtener la lista de estudiantes
          estudiantesEncontrados =
              data.map((item) => item['DATO'] as String).toList();
        });
      } else {
        // Manejo de errores si la respuesta no es exitosa
        throw Exception(
            'Error al buscar estudiantes: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Manejo de excepciones durante la solicitud o decodificación
    }
  }

  Future<void> enviarSolicitud() async {
    const url =
        'https://academia.usbbog.edu.co/centralizacion_servicios_ios/API/Tutorias/FormularioTutoria/EnvioSolicitudCorreo.php';

    Map<String, String> datosFormulario = {
      'DOCUMENTO': _documentoController.text,
      'NOMBREAPELLIDO': _usernameController.text,
      'CORREO_INST': _correoInstitucionalController.text,
      'CARRERA': selectedOpcionProgramaT,
      'MATERIA_TUTORIA': selectedOpcionCursoT,
      'CODIGOPROFESOR': selectedOpcionTeachT,
      'TEMATICA_TUTORIA': _tematicaTutoriaController.text,
    };

    if (selectedOption == 'Grupal') {
      datosFormulario['TIPOTUTORIA'] = selectedOption;
      datosFormulario['INTEGRANTES'] = selectedStudents.join(', ');
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        body: datosFormulario,
      );

      if (response.statusCode == 200) {
      } else {}
      // ignore: empty_catches
    } catch (error) {}
  }

  //Muestra el mensaje de las horas franjas tutorias
  void _showAlertDialog(String value, String value2) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Column(children: [
            Icon(Icons.error_outline, size: 70, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'TENGA EN CUENTA QUE:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23, // Tamaño de la fuente del texto
                fontWeight: FontWeight.bold, // Peso de la fuente (negrita)
                color: Colors.black, // Color del texto
              ),
            ),
          ]),
          content: SingleChildScrollView(
              child: RichText(
            //textAlign: TextAlign.justify,
            text: TextSpan(
              text:
                  'El Horario de Atencion de Tutorías Academicas del profesor',
              style: const TextStyle(fontSize: 16, color: Colors.black),
              children: [
                TextSpan(
                    text: '$value.',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
                const TextSpan(
                    text: 'ES \n',
                    style: TextStyle(
                      fontSize: 17,
                    )),
                const WidgetSpan(child: SizedBox(height: 16)),
                TextSpan(
                  text: '${value2.split(';').join('\n')}.',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        20.0), // Aquí puedes ajustar el radio del borde
                  ),
                ),
              ),
              child: const Text('Entendido'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
