// ignore: file_names
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:servicios/screens/docente/inicio_d.dart';
import 'package:servicios/screens/funcionalidad.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CredencialesD3ScreenE(
        usuarioAsis: '',
        correoInstitucional: '',
        tipo: '',
        documento: '',
        emplid: '',
        fecha: '',
      ),
    );
  }
}

class CredencialesD3ScreenE extends StatelessWidget {
  final String usuarioAsis;
  final String correoInstitucional;
  final String tipo;
  final String documento;
  final String emplid;
  final String fecha;

  const CredencialesD3ScreenE(
      {super.key,
      required this.usuarioAsis,
      required this.correoInstitucional,
      required this.tipo,
      required this.documento,
      required this.emplid,
      required this.fecha});

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recuerde que la clave de acceso al sistema ASIS será notificada a su '
                  'correo institucional.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/images/logo_usb_completo.png',
                    width: 300.0,
                    height: 80.0,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Usuario ASIS: \n $usuarioAsis',
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const Center(
                              child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.orange),
                          ));
                        },
                      );

                      try {
                        final correoResponse = await http.post(
                          Uri.parse(
                              'https://academia.usbbog.edu.co/centralizacion_servicios_ios/API/Credenciales/CorreoAsisP.php'),
                          body: {
                            'USUARIO_ASIS': usuarioAsis,
                            'CORREO_INSTITUCIONAL': correoInstitucional,
                            'TIPO': tipo,
                            'DOCUMENTO': documento,
                            'CODIGO': emplid,
                            'FECHA_NACIMIENTO': fecha,
                          },
                        );

                        if (correoResponse.statusCode == 200) {
                          // ignore: use_build_context_synchronously
                          alert.showAlertDialogSuccess(context,'Credenciales', 'Se ha enviado la nueva contraseña al correo institucional.','pro',(BuildContext context) => const HomeScreenD());
                        } else {
                          // ignore: use_build_context_synchronously
                          alert.showAlertDialogError(context,'Error','Error al enviar la nueva contraseña al correo');
                        }
                      } finally {
                      
                      }
                    },
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(const Size(320, 20)),
                      backgroundColor: WidgetStateProperty.all(Colors.orange),
                    ),
                    child: const Text('Restablecer Usuario ASIS',
                        style: TextStyle(
                          color: Colors.black,
                        )),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Si tiene alguna duda o incoveniente, por favor '
                  'acerquese a la Unidad de Tecnología ubicada en el Edificio Alberto Montealegre oficina 307. ',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ));
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
        size.width * 0.7, size.height, size.width, size.height * 0.95);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
