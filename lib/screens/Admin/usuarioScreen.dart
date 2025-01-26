// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:movilapp/router/api_service.dart'; // Importa el servicio API
import 'package:movilapp/screens/Admin/agregarScreen.dart'; // Importa la pantalla de agregar usuario
import 'package:movilapp/screens/Admin/editarScreen.dart'; // Importa la pantalla de editar credenciales

class UsuarioScreen extends StatefulWidget {
  const UsuarioScreen({super.key});

  @override
  _UsuarioScreenState createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  List<Map<String, dynamic>> usuarios = [];
  List<Map<String, dynamic>> usuariosFiltrados = [];
  bool isLoading = true;
  String filtroSeleccionado = 'Todos'; // Filtro inicial
  String query = ''; // Consulta de búsqueda

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  /// Función para obtener todos los usuarios desde la API
  Future<void> _cargarUsuarios() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Llama a la API para obtener todos los usuarios
      final usuariosData = await APIService.getAllUsers();
      setState(() {
        usuarios = usuariosData ?? [];
        usuariosFiltrados = usuarios; // Mostrar todos los usuarios inicialmente
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar usuarios: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar usuarios')),
      );
    }
  }

  /// Función para buscar usuarios según la consulta
  void _buscarUsuarios(String query) {
    setState(() {
      this.query = query;
      if (query.isEmpty) {
        usuariosFiltrados = usuarios;
      } else {
        usuariosFiltrados = usuarios.where((usuario) {
          final nombreCompleto =
              '${usuario['nombre']} ${usuario['apellido']}'.toLowerCase();
          final correo = usuario['correo'].toLowerCase();
          final input = query.toLowerCase();
          return nombreCompleto.contains(input) || correo.contains(input);
        }).toList();
      }
    });
  }

  /// Función para filtrar usuarios según el tipo seleccionado
  List<Map<String, dynamic>> _filtrarUsuarios() {
    if (filtroSeleccionado == 'Todos') {
      return usuariosFiltrados;
    } else {
      return usuariosFiltrados
          .where((usuario) => usuario['tipo_usuario'] == filtroSeleccionado)
          .toList();
    }
  }

  /// Función para navegar a AgregarScreen y manejar el resultado
  void _agregarUsuario() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgregarScreen()),
    ).then((value) {
      if (value == true) {
        _cargarUsuarios(); // Refrescar la lista de usuarios
      }
    });
  }

  /// Función para navegar a EditarCredencialesScreen y manejar el resultado
  void _editarUsuario(Map<String, dynamic> usuario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarCredencialesScreen(usuario: usuario),
      ),
    ).then((value) {
      if (value == true) {
        _cargarUsuarios(); // Refrescar la lista de usuarios
      }
    });
  }

  /// Función para eliminar un usuario
  void _eliminarUsuario(int idPersona) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este usuario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final success = await APIService.deleteUser(idPersona);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario eliminado exitosamente')),
                  );
                  _cargarUsuarios(); // Refrescar la lista de usuarios
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al eliminar el usuario')),
                  );
                }
              } catch (e) {
                print('Error al eliminar usuario: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al eliminar el usuario')),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Usuarios',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1B2A49),
        automaticallyImplyLeading: false, // Elimina el botón de retroceso si es necesario
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de búsqueda
            TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre o correo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _buscarUsuarios,
            ),
            const SizedBox(height: 10),

            // Dropdown para filtrar por tipo de usuario (Corregido)
            DropdownButtonFormField<String>(
              value: filtroSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Filtrar por Tipo',
                border: OutlineInputBorder(),
              ),
              items: <String>['Todos', 'Cliente', 'Administrador', 'Técnico']
                  .map((String tipo) {
                return DropdownMenuItem<String>(
                  value: tipo,
                  child: Text(tipo),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  filtroSeleccionado = newValue ?? 'Todos';
                  _buscarUsuarios(query);
                });
              },
            ),
            const SizedBox(height: 10),

            // Botón para agregar un nuevo usuario
            ElevatedButton.icon(
              onPressed: _agregarUsuario,
              icon: const Icon(Icons.add),
              label: const Text('Agregar Usuario'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(height: 20),

            // Lista de usuarios
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: usuariosFiltrados.isEmpty
                        ? const Center(child: Text('No se encontraron usuarios.'))
                        : ListView.builder(
                            itemCount: _filtrarUsuarios().length,
                            itemBuilder: (context, index) {
                              final usuario = _filtrarUsuarios()[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blueAccent,
                                    child: Text(
                                      usuario['nombre'][0].toUpperCase(),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text('${usuario['nombre']} ${usuario['apellido']}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Correo: ${usuario['correo']}'),
                                      Text('Teléfono: ${usuario['telefono']}'),
                                      Text('Dirección: ${usuario['direccion']}'),
                                      Text('Tipo: ${usuario['tipo_usuario']}'),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _editarUsuario(usuario),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _eliminarUsuario(usuario['id_persona']),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
