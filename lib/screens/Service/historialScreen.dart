// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:movilapp/router/api_service.dart';

class HistorialReparacionesScreen extends StatefulWidget {
  final int idTecnico;

  const HistorialReparacionesScreen({super.key, required this.idTecnico});

  @override
  _HistorialReparacionesScreenState createState() => _HistorialReparacionesScreenState();
}

class _HistorialReparacionesScreenState extends State<HistorialReparacionesScreen> {
  List<Map<String, dynamic>> equiposEntregados = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEquiposEntregados();
  }

  Future<void> _fetchEquiposEntregados() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Llama a la función de API para obtener los servicios del técnico
      final servicios = await APIService.getServiciosPorTecnico(widget.idTecnico);

      if (servicios != null) {
        // Filtra los servicios con estado 'Entregado'
        setState(() {
          equiposEntregados = servicios.where((s) => s['estado_equipo'] == 'Entregado').toList();
        });
      }
    } catch (e) {
      print('Error al cargar equipos entregados: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildEquiposList() {
    if (equiposEntregados.isEmpty) {
      return const Center(child: Text('No hay equipos entregados.'));
    }

    return ListView.builder(
      itemCount: equiposEntregados.length,
      itemBuilder: (context, index) {
        final equipo = equiposEntregados[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: const Icon(Icons.devices, color: Colors.blue),
            title: Text(equipo['descripcion'] ?? 'Equipo sin descripción'),
            subtitle: Text('Monto: \$${equipo['monto'] ?? 'No asignado'}'),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Reparaciones'),
        backgroundColor: const Color(0xFF2D79F3),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildEquiposList(),
            ),
    );
  }
}
