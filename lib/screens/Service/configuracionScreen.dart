// ignore_for_file: file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:movilapp/screens/Service/historialScreen.dart';
import 'side_menu.dart';

class ConfiguracionScreen extends StatefulWidget {
  final String tecnicoNombre;
  final String tecnicoEspecialidad;
  final int idTecnico;

  const ConfiguracionScreen({
    super.key,
    required this.tecnicoNombre,
    required this.tecnicoEspecialidad,
    required this.idTecnico,
  });

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  bool notificacionesActivadas = true;
  bool modoDisponibilidad = true;

  Future<void> _mostrarAdvertencia(String mensaje, Function onConfirm) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Advertencia'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cambiarEstadoNotificaciones(bool estado) async {
    _mostrarAdvertencia(
      '¿Está seguro de que desea ${estado ? 'activar' : 'desactivar'} las notificaciones de nuevos servicios?',
      () {
        setState(() {
          notificacionesActivadas = estado;
        });
        print('Estado de notificaciones actualizado: $estado');
      },
    );
  }

  Future<void> _cambiarDisponibilidad(bool estado) async {
    _mostrarAdvertencia(
      '¿Está seguro de que desea cambiar al modo ${estado ? 'disponible' : 'no disponible'}?',
      () {
        setState(() {
          modoDisponibilidad = estado;
        });
        print('Disponibilidad del técnico actualizada: $estado');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración del Técnico'),
        backgroundColor: const Color(0xFF2D79F3),
      ),
      drawer: SideMenu(
        tecnicoNombre: widget.tecnicoNombre,
        tecnicoEspecialidad: widget.tecnicoEspecialidad,
        idTecnico: widget.idTecnico,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Preferencias de Trabajo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications, color: Color(0xFF2D79F3)),
                title: const Text('Notificaciones de Nuevos Servicios'),
                trailing: Switch(
                  value: notificacionesActivadas,
                  activeColor: const Color(0xFF2D79F3),
                  onChanged: (bool value) {
                    _cambiarEstadoNotificaciones(value);
                  },
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.wifi, color: Color(0xFF2D79F3)),
                title: const Text('Modo de Disponibilidad'),
                trailing: Switch(
                  value: modoDisponibilidad,
                  activeColor: const Color(0xFF2D79F3),
                  onChanged: (bool value) {
                    _cambiarDisponibilidad(value);
                  },
                ),
              ),
              const Divider(height: 40, thickness: 1),
              const Text(
                'Historial de Reparaciones',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history, color: Color(0xFF2D79F3)),
                title: const Text('Equipos Entregados'),
                onTap: () {
                  // Navega a la pantalla de historial pasando el id del técnico
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistorialReparacionesScreen(idTecnico: widget.idTecnico),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
