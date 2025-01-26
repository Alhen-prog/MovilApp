// ignore_for_file: file_names, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:movilapp/router/api_service.dart'; // Asegúrate de tener la importación correcta
import 'side_menu.dart';

class SolicitudScreen extends StatefulWidget {
  final String tecnicoNombre;
  final String tecnicoEspecialidad;
  final int idTecnico;

  const SolicitudScreen({
    super.key,
    required this.tecnicoNombre,
    required this.tecnicoEspecialidad,
    required this.idTecnico,
  });

  @override
  State<SolicitudScreen> createState() => _SolicitudScreenState();
}

class _SolicitudScreenState extends State<SolicitudScreen> {
  List<Map<String, dynamic>> solicitudesPorAceptar = [];
  bool isLoading = true;
  String errorMessage = '';

  // Función para obtener los servicios "Por Aceptar"
  Future<void> _fetchSolicitudes() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Llama a la API para obtener los servicios asignados al técnico
      final servicios = await APIService.getServiciosPorAceptar(widget.idTecnico);
      print('Servicios obtenidos: $servicios');

      if (servicios != null && servicios.isNotEmpty) {
        setState(() {
          solicitudesPorAceptar = servicios;
        });
      } else {
        setState(() {
          errorMessage = 'No hay servicios pendientes por aceptar para este técnico.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar servicios: $e';
      });
      print('Error al cargar servicios: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Función para aceptar un servicio y cambiar su estado
  Future<void> _aceptarServicio(int idServicio) async {
    try {
      // Llama al método de la API para aceptar el servicio
      final success = await APIService.aceptarServicioAsignado(widget.idTecnico, idServicio);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Servicio aceptado con éxito')),
        );
        _fetchSolicitudes(); // Refresca la lista después de aceptar el servicio
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al aceptar el servicio')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de conexión al servidor')),
      );
      print('Error al aceptar servicio: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSolicitudes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitudes - ${widget.tecnicoNombre}'),
        backgroundColor: const Color(0xFF2D79F3),
      ),
      drawer: SideMenu(
        tecnicoNombre: widget.tecnicoNombre,
        tecnicoEspecialidad: widget.tecnicoEspecialidad,
        idTecnico: widget.idTecnico,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Servicios Por Aceptar (${widget.tecnicoEspecialidad})',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : solicitudesPorAceptar.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: solicitudesPorAceptar.length,
                          itemBuilder: (context, index) {
                            final solicitud = solicitudesPorAceptar[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text(solicitud['descripcion'] ?? 'Servicio sin descripción'),
                                subtitle: Text(
                                  'Asignado el: ${solicitud['fecha_asignacion']}',
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () async {
                                    await _aceptarServicio(solicitud['id_servicio']);
                                  },
                                  child: const Text('Aceptar'),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(errorMessage.isNotEmpty
                            ? errorMessage
                            : 'No hay servicios por aceptar.'),
                      ),
          ],
        ),
      ),
    );
  }
}
