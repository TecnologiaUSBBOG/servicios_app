import 'dart:io';
import 'package:flutter/material.dart';
import 'package:servicios/screens/docente/inicio_d.dart';
import 'package:servicios/screens/estudiante/inicio_e.dart';
import 'screens/splash_screen.dart';

void main() {
  // Desactivar verificación SSL en desarrollo
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Mueve esto al principio

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Quita el banner de debug
      routes: {
        '/estudiante/inicioE': (context) => const HomeScreenE(),
        '/docente/inicioD': (context) => const HomeScreenD(),
      },
      home: const SplashScreen(),
    );
  }
}
