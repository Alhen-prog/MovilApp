import 'package:flutter/material.dart';
import 'package:movilapp/router/api_service.dart'; // Asegúrate de que el import sea correcto
// ignore: unused_import
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  Future<void> registrarCliente() async {
    // Validar que los campos obligatorios estén llenos
    if (_nombreController.text.isEmpty ||
        _apellidoController.text.isEmpty ||
        _telefonoController.text.isEmpty ||
        _correoController.text.isEmpty ||
        _contrasenaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos obligatorios.')),
      );
      return;
    }

    bool success = await APIService.crearCliente(
      nombre: _nombreController.text,
      apellido: _apellidoController.text,
      telefono: _telefonoController.text,
      direccion: _direccionController.text,
      correo: _correoController.text,
      contrasena: _contrasenaController.text,
    );

    if (success) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso.')),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);  // Volver a la pantalla anterior
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar cliente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F47F0), Color(0xFFACB6E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width * 0.85,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEFEF).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF333333), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Registro - Computer House',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Nombre', Icons.person, _nombreController),
                      const SizedBox(height: 10),
                      _buildTextField('Apellido', Icons.person, _apellidoController),
                      const SizedBox(height: 10),
                      _buildTextField('Teléfono', Icons.phone, _telefonoController),
                      const SizedBox(height: 10),
                      _buildTextField('Dirección (opcional)', Icons.home, _direccionController),
                      const SizedBox(height: 10),
                      _buildTextField('Correo Electrónico', Icons.email, _correoController),
                      const SizedBox(height: 10),
                      _buildTextField('Contraseña', Icons.lock, _contrasenaController, isPassword: true),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: registrarCliente,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: const Color(0xFF0F47F0),
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Registrar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          "¿Ya tienes una cuenta?",
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Center(
                          child: Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              color: Color(0xFF2D79F3),
                              fontSize: 12,
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

  // Widget para crear los campos de texto
  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF000000),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF333333)),
            hintText: label,
            filled: true,
            fillColor: const Color(0xFFFFFFFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
