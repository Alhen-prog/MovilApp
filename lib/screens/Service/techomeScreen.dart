// ignore_for_file: file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:movilapp/router/api_service.dart';
import 'side_menu.dart';

class TecHomeScreen extends StatefulWidget {
  final int idTecnico;

  const TecHomeScreen({super.key, required this.idTecnico});

  @override
  State<TecHomeScreen> createState() => _TecHomeScreenState();
}

class _TecHomeScreenState extends State<TecHomeScreen> {
  int equiposEnReparacion = 0;
  int equiposEntregados = 0;
  int equiposReparados = 0;
  int equiposEnEspera = 0; // Representa las tareas "En Espera"
  String tecnicoNombre = '';
  String tecnicoEspecialidad = '';
  bool isLoading = true;

  Future<void> _fetchResumen() async {
    try {
      // Obtener detalles del técnico
      final tecnicoDetails = await APIService.getTecnicoDetails(widget.idTecnico);
      if (tecnicoDetails != null) {
        setState(() {
          tecnicoNombre = tecnicoDetails['nombre'] ?? 'Desconocido';
          tecnicoEspecialidad = tecnicoDetails['especialidad'] ?? 'General';
        });
      }

      // Obtener servicios del técnico
      final servicios = await APIService.getServiciosPorTecnico(widget.idTecnico);
      if (servicios != null) {
        // Imprimir los estados de los servicios para depuración
        print('Estados de servicios:');
        for (var s in servicios) {
          print(s['estado_equipo']);
        }

        // Clasificar los servicios según su estado
        final enReparacion = servicios.where((s) => s['estado_equipo'] == 'En Reparación').toList();
        final enEspera = servicios.where((s) => s['estado_equipo'] == 'En Espera').toList();
        final reparado = servicios.where((s) => s['estado_equipo'] == 'Reparado').toList();
        final entregado = servicios.where((s) => s['estado_equipo'] == 'Entregado').toList();

        setState(() {
          equiposEnReparacion = enReparacion.length;
          equiposEnEspera = enEspera.length;
          equiposReparados = reparado.length;
          equiposEntregados = entregado.length;
        });
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchResumen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Técnico - Inicio'),
        backgroundColor: const Color(0xFF2D79F3),
      ),
      drawer: SideMenu(
        tecnicoNombre: tecnicoNombre,
        tecnicoEspecialidad: tecnicoEspecialidad,
        idTecnico: widget.idTecnico,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Bienvenido, $tecnicoNombre',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Resumen de Actividades:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: <Widget>[
                        _DashboardCard(
                          title: 'Equipos en reparación',
                          count: equiposEnReparacion,
                          icon: Icons.build,
                          color: Colors.orange,
                        ),
                        _DashboardCard(
                          title: 'Equipos en espera',
                          count: equiposEnEspera,
                          icon: Icons.hourglass_empty,
                          color: Colors.yellow,
                        ),
                        _DashboardCard(
                          title: 'Equipos reparados',
                          count: equiposReparados,
                          icon: Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                        _DashboardCard(
                          title: 'Equipos entregados',
                          count: equiposEntregados,
                          icon: Icons.assignment_turned_in,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _DashboardCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
