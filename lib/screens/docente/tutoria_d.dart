import 'package:flutter/material.dart';
import 'package:servicios/auth.dart';
import 'package:servicios/globals.dart';
import 'package:servicios/screens/docente/credenciales_ed.dart';
import 'package:servicios/screens/docente/calendario_td.dart';
import 'package:servicios/screens/docente/grupal_td.dart';
import 'package:servicios/screens/docente/individual_td.dart';
import 'package:servicios/screens/login.dart';
import 'horario_d.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TutoriaDScreenD(),
    );
  }
}

class TutoriaDScreenD extends StatelessWidget {
  final double _buttonMargin = 30.0;
  final double _buttonWidth = double.infinity - 40.0;
  final double _iconSize = 80.0;
  final double _textSize = 20.0;
  final double _titlePadding = 20.0;
  final double _verticalSpacing = 10.0;
  final double _borderRadius = 10.0;

  const TutoriaDScreenD({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Tutorías Académicas'),
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
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: _verticalSpacing),
              _buildSectionTitle('Tipo de tutoría'),
              SizedBox(height: _verticalSpacing),
              _buildSectionButton(
                context,
                'Tutoría individual',
                Icons.person,
                const Color.fromRGBO(18, 182, 207, 1),
                () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      );
                    },
                  );

                  await Future.delayed(const Duration(seconds: 2));

                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);

                  Navigator.push(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IndividualTutoriaScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: _verticalSpacing),
              _buildSectionButton(
                context,
                'Tutoría grupal',
                Icons.group,
                const Color.fromRGBO(18, 182, 207, 1),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GrupalTutoriaScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: _verticalSpacing * 3),
              _buildSectionTitle('Calendario de sesiones de tutoría'),
              SizedBox(height: _verticalSpacing),
              _buildSectionButton(
                context,
                'Calendario de sesiones',
                Icons.calendar_month,
                const Color.fromRGBO(48, 159, 219, 1),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalendarioTD(),
                    ),
                  );
                },
              ),
            ],
          ),
        ));
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _titlePadding),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _textSize,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: _buttonMargin),
        width: _buttonWidth,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: _iconSize,
            ),
            SizedBox(height: _verticalSpacing),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: _textSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
                      Expanded(
                        child: Text(
                          globalUsername ?? 'Nombre de Usuario',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                          ),
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
                          builder: (context) => const HorarioDScreenD()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.group),
                  title: const Text('Tutorías Académicas'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TutoriaDScreenD()),
                    );
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
                          builder: (context) => const CredencialesEScreenD()),
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
}
