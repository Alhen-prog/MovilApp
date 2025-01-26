import 'package:flutter/material.dart';
import 'package:movilapp/screens/login_screens.dart';
import 'configuracionScreen.dart';
import 'techomeScreen.dart';
import 'solicitudScreen.dart';
import 'equipoScreen.dart';

class SideMenu extends StatelessWidget {
  final String tecnicoNombre;
  final String tecnicoEspecialidad;
  final int idTecnico; // Agrega el idTecnico como parámetro en SideMenu

  const SideMenu({
    super.key,
    required this.tecnicoNombre,
    required this.tecnicoEspecialidad,
    required this.idTecnico, // Asegúrate de que idTecnico sea requerido
  });

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF2D79F3)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tecnicoNombre,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  'Especialidad: $tecnicoEspecialidad',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TecHomeScreen(idTecnico: idTecnico), // Pasa el idTecnico aquí
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Gestión de Equipos'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EquipoScreen(
                    tecnicoNombre: tecnicoNombre,
                    tecnicoEspecialidad: tecnicoEspecialidad,
                    idTecnico: idTecnico, // Pasa el idTecnico aquí
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Solicitudes de Servicio'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SolicitudScreen(
                    tecnicoNombre: tecnicoNombre,
                    tecnicoEspecialidad: tecnicoEspecialidad,
                    idTecnico: idTecnico, // Pasa el idTecnico aquí
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfiguracionScreen(
                    tecnicoNombre: tecnicoNombre,
                    tecnicoEspecialidad: tecnicoEspecialidad,
                    idTecnico: idTecnico, // Pasa el idTecnico aquí
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
