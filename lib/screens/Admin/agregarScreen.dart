import 'package:flutter/material.dart';
import 'package:movilapp/router/api_service.dart'; 

class AgregarScreen extends StatefulWidget {
  const AgregarScreen({super.key});

  @override
  _AgregarScreenState createState() => _AgregarScreenState();
}

class _AgregarScreenState extends State<AgregarScreen> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  String apellido = '';
  String correo = '';
  String telefono = '';
  String direccion = '';
  String contrasena = '';
  String? tipoUsuario; 

  void _agregarUsuario() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (tipoUsuario == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, seleccione un tipo de usuario')),
        );
        return;
      }

      int tipoUsuarioId;

      switch (tipoUsuario) {
        case 'Cliente':
          tipoUsuarioId = 1;
          break;
        case 'Administrador':
          tipoUsuarioId = 2;
          break;
        case 'Técnico':
          tipoUsuarioId = 3;
          break;
        default:
          tipoUsuarioId = 1;
      }

      bool success = await APIService.registerUser(
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        direccion: direccion,
        correo: correo,
        contrasena: contrasena,
        tipoUsuario: tipoUsuarioId,
      );

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al agregar el usuario')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Usuario'),
        backgroundColor: const Color(0xFF1B2A49), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Información del Usuario',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2A49), 
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Nombre',
                icon: Icons.person,
                onSaved: (value) => nombre = value!,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                label: 'Apellido',
                icon: Icons.person_outline,
                onSaved: (value) => apellido = value!,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                label: 'Correo',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => correo = value!,
                validator: _emailValidator, 
              ),
              const SizedBox(height: 15),
              _buildTextField(
                label: 'Teléfono',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                onSaved: (value) => telefono = value!,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                label: 'Dirección',
                icon: Icons.home,
                onSaved: (value) => direccion = value!,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                label: 'Contraseña',
                icon: Icons.lock,
                obscureText: true,
                onSaved: (value) => contrasena = value!,
                validator: _passwordValidator, 
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: tipoUsuario,
                decoration: InputDecoration(
                  labelText: 'Tipo de Usuario',
                  prefixIcon: const Icon(Icons.account_circle),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: <String>['Cliente', 'Administrador', 'Técnico']
                    .map((String tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    tipoUsuario = newValue!;
                  });
                },
                validator: (value) => value == null ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B2A49), 
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _agregarUsuario,
                child: const Text(
                  'Agregar Usuario',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo requerido';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un correo electrónico válido';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo requerido';
    }
    if (tipoUsuario == null) {
      return 'Seleccione el tipo de usuario antes de ingresar la contraseña';
    }

    int requiredLength;
    switch (tipoUsuario) {
      case 'Cliente':
        requiredLength = 8;
        break;
      case 'Administrador':
        requiredLength = 12;
        break;
      case 'Técnico':
        requiredLength = 6;
        break;
      default:
        requiredLength = 8;
    }

    if (value.length != requiredLength) {
      return 'La contraseña debe tener $requiredLength caracteres';
    }

    return null;
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Function(String?) onSaved,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator ??
          (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
      onSaved: onSaved,
      obscureText: obscureText,
      keyboardType: keyboardType,
    );
  }
}
