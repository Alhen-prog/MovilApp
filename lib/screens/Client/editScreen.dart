// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:movilapp/router/api_service.dart'; // Asegúrate de que la ruta de importación sea correcta

class EditScreen extends StatefulWidget {
  final int idPersona;
  final String currentName;
  final String currentSurname;
  final String currentEmail;
  final String currentPhone;
  final String currentAddress;

  const EditScreen({
    super.key,
    required this.idPersona,
    required this.currentName,
    required this.currentSurname,
    required this.currentEmail,
    required this.currentPhone,
    required this.currentAddress,
  });

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _surnameController = TextEditingController(text: widget.currentSurname);
    _emailController = TextEditingController(text: widget.currentEmail);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _addressController = TextEditingController(text: widget.currentAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    bool success = await APIService.updateProfile(
      idPersona: widget.idPersona,
      nombre: _nameController.text.trim(),
      apellido: _surnameController.text.trim(),
      correo: _emailController.text.trim(),
      telefono: _phoneController.text.trim(),
      direccion: _addressController.text.trim(),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el perfil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: const Color(0xFF0F47F0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actualizar información',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(_nameController, 'Nombre', Icons.person),
            const SizedBox(height: 15),
            _buildTextField(_surnameController, 'Apellido', Icons.person_outline),
            const SizedBox(height: 15),
            _buildTextField(_emailController, 'Correo', Icons.email, isEmail: true),
            const SizedBox(height: 15),
            _buildTextField(_phoneController, 'Teléfono', Icons.phone, isNumber: true),
            const SizedBox(height: 15),
            _buildTextField(_addressController, 'Dirección', Icons.location_on),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F47F0),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Guardar cambios',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isEmail = false, bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF0F47F0)),
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF0F47F0)),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0F47F0)),
        ),
      ),
    );
  }
}
