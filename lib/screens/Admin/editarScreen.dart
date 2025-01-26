// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:movilapp/router/api_service.dart'; 
class EditarCredencialesScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const EditarCredencialesScreen({super.key, required this.usuario});

  @override
  _EditarCredencialesScreenState createState() =>
      _EditarCredencialesScreenState();
}

class _EditarCredencialesScreenState extends State<EditarCredencialesScreen> {
  final _formKey = GlobalKey<FormState>();

  String nombre = '';
  String apellido = '';
  String correo = '';
  String telefono = '';
  String direccion = '';
  String contrasena = '';
  String tipoUsuario = 'Cliente'; 
  bool cargando = true; 

  @override
  void initState() {
    super.initState();
    _cargarDetallesUsuario();
  }

  /// Carga los detalles del usuario desde el objeto [usuario] pasado al widget.
  Future<void> _cargarDetallesUsuario() async {
    final usuario = widget.usuario;

    print("Datos del usuario: $usuario");

    try {
      setState(() {
        nombre = usuario['nombre'] ?? '';
        apellido = usuario['apellido'] ?? '';
        correo = usuario['correo'] ?? '';
        telefono = usuario['telefono'] ?? '';
        direccion = usuario['direccion'] ?? '';
        tipoUsuario = usuario['tipo_usuario'] ?? 'Cliente';
        cargando = false; 
      });
    } catch (e) {
      setState(() {
        cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar detalles del usuario')),
      );
    }
  }

  void _editarCredenciales() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
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

      bool exito = await APIService.updateCredenciales(
        idPersona: widget.usuario['id_persona'],
        nombre: nombre,
        apellido: apellido,
        correo: correo,
        telefono: telefono,
        direccion: direccion,
        contrasena: contrasena.isNotEmpty ? contrasena : null, 
        tipoUsuario: tipoUsuarioId,
      );

      if (exito) {
        // Mostrar mensaje de éxito antes de navegar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales actualizadas exitosamente')),
        );
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar las credenciales')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Credenciales'),
        backgroundColor: Colors.blueAccent,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Editar Información',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Nombre',
                      icon: Icons.person,
                      initialValue: nombre,
                      onSaved: (value) => nombre = value!,
                    ),
                    _buildTextField(
                      label: 'Apellido',
                      icon: Icons.person_outline,
                      initialValue: apellido,
                      onSaved: (value) => apellido = value!,
                    ),
                    _buildTextField(
                      label: 'Correo Electrónico',
                      icon: Icons.email,
                      initialValue: correo,
                      onSaved: (value) => correo = value!,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextField(
                      label: 'Teléfono',
                      icon: Icons.phone,
                      initialValue: telefono,
                      onSaved: (value) => telefono = value!,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildTextField(
                      label: 'Dirección',
                      icon: Icons.location_on,
                      initialValue: direccion,
                      onSaved: (value) => direccion = value!,
                    ),
                    _buildPasswordField(),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: tipoUsuario,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Usuario',
                        prefixIcon: Icon(Icons.people),
                        border: OutlineInputBorder(),
                      ),
                      items: <String>['Cliente', 'Administrador', 'Técnico']
                          .map((String tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo,
                          child: Text(tipo),
                        );
                      }).toList(),
                      onChanged: (String? nuevoValor) {
                        setState(() {
                          tipoUsuario = nuevoValor!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _editarCredenciales,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          'Actualizar Credenciales',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

 
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String initialValue,
    required Function(String?) onSaved,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Campo obligatorio' : null,
        onSaved: onSaved,
        keyboardType: keyboardType,
      ),
    );
  }

  /// Widget para construir el campo de contraseña.
  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Contraseña',
          prefixIcon: Icon(Icons.lock),
          border: OutlineInputBorder(),
        ),
        obscureText: true,
        validator: (value) {
        
          if (value != null && value.isNotEmpty && value.length < 6) {
            return 'La contraseña debe tener al menos 6 caracteres';
          }
          return null;
        },
        onSaved: (value) => contrasena = value ?? '',
      ),
    );
  }
}
