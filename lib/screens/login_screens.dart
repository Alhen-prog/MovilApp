import 'package:flutter/material.dart';
import 'package:movilapp/router/api_service.dart';
import 'package:movilapp/screens/Admin/adminScreen.dart';
import 'package:movilapp/screens/Client/inicioScreen.dart';
import 'package:movilapp/screens/Client/registerscreens.dart';
import 'Service/techomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _loginWithCredentials() async {
    final email = _userController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showAlertDialog('Por favor, ingrese sus credenciales.');
      return;
    }

    setState(() {
      _isLoading = true; // Mostrar indicador de carga
    });

    try {
      final loginResponse = await APIService.login(email, password);

      if (loginResponse != null) {
        final role = loginResponse['role'];

        if (role == 'Cliente') {
          final idCliente = loginResponse['idCliente'];
          // Mostrar mensaje de éxito
          _showAlertDialog('Inicio de sesión exitoso');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(idCliente: idCliente), // Proporciona idCliente
            ),
            (route) => false,
          );
        } else if (role == 'Técnico') {
          final idTecnico = loginResponse['idTecnico'];
          _showAlertDialog('Inicio de sesión exitoso');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TecHomeScreen(idTecnico: idTecnico)),
          );
        } else if (role == 'Administrador') {
          _showAlertDialog('Inicio de sesión exitoso');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomeScreen()), // Aquí no pasamos idCliente
          );
        } else {
          _showAlertDialog('Rol desconocido.');
        }
      } else {
        // Mostrar alerta si las credenciales son incorrectas
        _showAlertDialog('Credenciales inválidas o error de autenticación');
      }
    } catch (e) {
      _showAlertDialog('Error al conectar con el servidor.');
    } finally {
      setState(() {
        _isLoading = false; // Ocultar indicador de carga
      });
    }
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alerta'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // Fondo con gradiente
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F47F0), Color(0xFFACB6E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Contenido principal
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título
                            const Center(
                              child: Text(
                                'Computer House - Service',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Nombre de usuario',
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            InputField(
                              controller: _userController,
                              icon: Icons.person,
                              placeholder: 'Ingrese su Usuario',
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Contraseña',
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            InputField(
                              controller: _passwordController,
                              icon: Icons.lock,
                              placeholder: 'Ingrese su Contraseña',
                              isPassword: true,
                              textInputAction: TextInputAction.done,
                            ),
                            const SizedBox(height: 30),
                            Center(
                              child: ElevatedButton(
                                onPressed: _loginWithCredentials,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F47F0),
                                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Iniciar sesión',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Center(
                              child: Text(
                                "¿No tienes una cuenta?",
                                style: TextStyle(color: Color(0xFF333333), fontSize: 14),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Center(
                                child: Text(
                                  'Regístrate',
                                  style: TextStyle(
                                    color: Color(0xFF2D79F3),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String placeholder;
  final bool isPassword;
  final TextInputAction textInputAction;

  const InputField({
    super.key,
    required this.controller,
    required this.icon,
    required this.placeholder,
    this.isPassword = false,
    this.textInputAction = TextInputAction.done,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF333333)),
        hintText: placeholder,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(15),
      ),
    );
  }
}
