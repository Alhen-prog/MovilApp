import 'package:flutter/material.dart';
import 'package:movilapp/screens/login_screens.dart';




void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      initialRoute: 'Login',
      routes: {
        'Login': (_) => const LoginScreen(), // Eliminado 'const'
        // Cambié a LoginScreens para que coincida con el nombre de la clase
      },
    );
  }
}
