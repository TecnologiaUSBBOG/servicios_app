import 'dart:convert';
import 'package:flutter/material.dart';
import '../globals.dart';
import 'package:http/http.dart' as http;

class LoginResponse {
  final List<UserItem> items;

  LoginResponse({required this.items});

  factory LoginResponse.fromJson(List<dynamic> json) {
    // Convertir la lista de JSON directamente a una lista de UserItem
    List<UserItem> itemsList = json.map((i) => UserItem.fromJson(i)).toList();
    return LoginResponse(items: itemsList);
  }
}

class UserItem {
  final String documento;
  final String emplid;
  final String nombre;
  final String nit;

  UserItem({
    required this.documento,
    required this.emplid,
    required this.nombre,
    required this.nit,
  });

  factory UserItem.fromJson(Map<String, dynamic> json) {
    return UserItem(
      documento: json['documento'] ?? "",
      emplid: json['emplid'] ?? "",
      nombre: json['nombre'] ?? "",
      nit: json['nit'] ?? "",
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _usernameController = TextEditingController();
  final bool _loginError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.yellow],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset('assets/images/logousb2.png', height: 200),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _usernameController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'ID Usuario',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => authenticateUser(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text('Iniciar Sesión',
                            style: TextStyle(
                              color: Colors.black,
                            )),
                      ),
                    ],
                  ),
                ),
                Builder(
                  builder: (BuildContext context) {
                    if (_loginError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error: Usuario inválido'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return Container();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void authenticateUser(BuildContext context) async {
    final String username = _usernameController.text;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (username.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingrese su ID de usuario'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    const String authenticationEndpoint =
        'http://apps.usbbog.edu.co:8080/prod/usbbogota/login/login';

    try {
      // Cambiar a método POST
      final response = await http.post(
        Uri.parse(authenticationEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username, // Cambia esto según lo que tu API espera
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        LoginResponse loginResponse = LoginResponse.fromJson(data);

        // Comprobar si hay items disponibles
        if (loginResponse.items.isNotEmpty) {
          UserItem user = loginResponse.items.first; // Tomamos el primer item

          globalCodigoEstudiante = user.emplid;
          globalUsername = user.nombre;
          globalDocumento = user.documento;
          // Manejar roles de usuario según el valor de NIT
          if (user.nit == 'DOC') {
            globalCodigoDocente = user.documento;
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('Bienvenid@, $globalUsername'),
                backgroundColor: Colors.green,
              ),
            );
            // ignore: use_build_context_synchronously
            Navigator.pushReplacementNamed(context, '/docente/inicioD');
          } else if (user.nit == 'NO') {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('Bienvenid@, $globalUsername'),
                backgroundColor: Colors.green,
              ),
            );
            // ignore: use_build_context_synchronously
            Navigator.pushReplacementNamed(context, '/estudiante/inicioE');
          }
        } else {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('No se encontraron usuarios con ese ID'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Hubo un problema al procesar la solicitud'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Hubo un problema al procesar la solicitud'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }
}
