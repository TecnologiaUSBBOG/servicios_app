import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:servicios/screens/estudiante/credito_e.dart';
import 'package:servicios/screens/estudiante/simulador_e.dart';
import 'package:servicios/screens/estudiante/tutoria_e.dart';
import 'package:servicios/screens/funcionalidad.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth.dart';
import '../../globals.dart';
import '../login.dart';
import 'credenciales_e.dart';
import 'horario_e.dart';
import 'icetex_e.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CredencialesE2ScreenE(
        usuarioAsis: '',
        correoInstitucional: '',
        correoPersonal: '',
        tipo: '',
        documento: '',
        emplid: '',
        fecha: '',
      ),
    );
  }
}
Funcionalidad alert = Funcionalidad();

class CredencialesE2ScreenE extends StatelessWidget {
  final String usuarioAsis;
  final String correoInstitucional;
  
  final String correoPersonal;
  final String tipo;
  final String documento;
  final String emplid;
  final String fecha;

  const CredencialesE2ScreenE(
      {super.key,
      required this.usuarioAsis,
      required this.correoInstitucional,
      required this.correoPersonal,
      required this.tipo,
      required this.documento,
      required this.emplid,
      required this.fecha});

  @override
  Widget build(BuildContext context) {
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
                  'Seleccione la opción de su interés para restablecer su contraseña. '
                  'Recuerde que la clave de acceso al sistema ASIS será notificada a su '
                  'correo institucional y su clave de acceso al correo institucional será '
                  'enviada al correo personal.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 25),
                Center(
                  child: Image.asset(
                    'assets/images/logo_usb_completo.png',
                    width: 300.0,
                    height: 70.0,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'Usuario ASIS: $usuarioAsis',
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
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
                              'https://academia.usbbog.edu.co/centralizacion_servicios_ios/API/Credenciales/CorreoAsis.php'),
                          body: {
                            'USUARIO_ASIS': usuarioAsis,
                            'CORREO_INSTITUCIONAL': correoInstitucional,
                            'CORREO_PERSONAL': correoPersonal,
                            'TIPO': tipo,
                            'DOCUMENTO': documento,
                            'CODIGO': emplid,
                            'FECHA_NACIMIENTO': fecha,
                          },
                        );

                        if (correoResponse.statusCode == 200) {
                          // ignore: use_build_context_synchronously
                          alert.showAlertDialogSuccess(context, 'Datos Enviados', 'Se ha enviado la nueva contraseña al correo institucional','est',null);
                        } else {
                          // ignore: use_build_context_synchronously
                          alert.showAlertDialogError(context, 'Error', 'Error al enviar la nueva contraseña al correo.');
                              
                        }
                      } finally {
                        // ignore: use_build_context_synchronously
                       
                          //alert.showAlertDialogSuccess(context, 'Datos Enviados', 'Se ha enviado la nueva contraseña al correo institucional','est',null);
                        

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
                const SizedBox(height: 18),
                Text(
                  'Correo Institucional: \n $correoInstitucional',
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 18),
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
                              'https://academia.usbbog.edu.co/centralizacion_servicios_ios/API/Credenciales/Correo365.php'),
                          body: {
                            'USUARIO_ASIS': usuarioAsis,
                            'CORREO_INSTITUCIONAL': correoInstitucional,
                            'CORREO_PERSONAL': correoPersonal,
                            'TIPO': tipo,
                            'DOCUMENTO': documento,
                            'CODIGO': emplid,
                            'FECHA_NACIMIENTO': fecha,
                          },
                        );

                        if (correoResponse.statusCode == 200) {
                          // ignore: use_build_context_synchronously
                            alert.showAlertDialogSuccess(context,'Datos Enviados', 'se ha enviado la nueva contraseña al correo personal','est',null);
                        
                        } else {
                          // ignore: use_build_context_synchronously
                          alert.showAlertDialogError(context, 'Error', 'Error al enviar la nueva contraseña al correo.');
                        }
                      } finally {

                      }  
                      
                    },
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(const Size(320, 18)),
                      backgroundColor: WidgetStateProperty.all(Colors.orange),
                    ),
                    child: const Text(
                      'Restablecer Correo Institucional',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Si tiene alguna duda o incoveniente, por favor '
                  'acerquese a la Unidad de Tecnología ubicada en el Edificio Alberto Montealegre oficina 307. ',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 18),
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
                        height: 100.0,
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
