// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:movilapp/router/api_service.dart'; // Importa tu API Service

class ServicioScreen extends StatefulWidget {
  const ServicioScreen({super.key});

  @override
  _ServicioScreenState createState() => _ServicioScreenState();
}

class _ServicioScreenState extends State<ServicioScreen> {
  List<Map<String, dynamic>> servicios = [];
  List<Map<String, dynamic>> tecnicos =
      []; // Lista para los técnicos disponibles
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarServiciosNoAsignados(); // Cargar servicios no asignados
    _cargarTecnicos(); // Cargar los técnicos disponibles
  }

  // Función para cargar los servicios no asignados desde la API
  Future<void> _cargarServiciosNoAsignados() async {
    try {
      setState(() {
        isLoading = true; // Mostrar el cargando antes de la solicitud
      });
      final serviciosData = await APIService
          .getServiciosNoAsignados(); // Obtener servicios sin asignar
      if (mounted) {
        // Verificar si el widget está montado antes de llamar a setState
        setState(() {
          servicios = serviciosData ??
              []; // Asegúrate de que sea una lista vacía si es null
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar los servicios: $e');
      if (mounted) {
        // Verificar si el widget está montado antes de llamar a setState
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Función para cargar los técnicos disponibles
  Future<void> _cargarTecnicos() async {
    try {
      final tecnicosData = await APIService.getTecnicosDisponibles();
      if (mounted) {
        // Verificar si el widget está montado antes de llamar a setState
        setState(() {
          tecnicos =
              tecnicosData; // Asignar directamente sin la comprobación null
        });
      }
    } catch (e) {
      print('Error al cargar técnicos: $e');
    }
  }

  // Función para asignar un técnico a un servicio
  Future<void> _asignarTecnico(int idServicio, int selectedTecnicoId) async {
    if (selectedTecnicoId == -1) {
      // Verificar que no sea el valor predeterminado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un técnico')),
      );
      return;
    }

    try {
      // Llamamos a la API sin pasar el token
      final success =
          await APIService.asignarTecnico(idServicio, selectedTecnicoId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Técnico asignado exitosamente')),
        );
        _cargarServiciosNoAsignados(); // Refrescar la lista de servicios
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al asignar el técnico')),
        );
      }
    } catch (e) {
      print('Error al asignar técnico: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al asignar el técnico')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Gestión de Servicios No Asignados',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1B2A49),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Servicios No Asignados a Técnicos:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2A49),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: servicios.length,
                      itemBuilder: (context, index) {
                        final servicio = servicios[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.build,
                                  size: 40,
                                  color: const Color(0xFF1B2A49),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        servicio['descripcion'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B2A49),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Monto: ${servicio['monto']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Dropdown para seleccionar el técnico
                                    DropdownButton<int>(
                                      hint: const Text('Seleccionar Técnico'),
                                      value: servicio['selectedTecnicoId'] == -1
                                          ? null
                                          : servicio['selectedTecnicoId'],
                                      items: tecnicos.map((tecnico) {
                                        return DropdownMenuItem<int>(
                                          value: tecnico['id_tecnico'],
                                          child: Text(tecnico['nombre']),
                                        );
                                      }).toList(),
                                      onChanged: (int? tecnicoId) {
                                        setState(() {
                                          servicio['selectedTecnicoId'] =
                                              tecnicoId ?? -1;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () => _asignarTecnico(
                                          servicio['id_servicio'],
                                          servicio['selectedTecnicoId']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF1B2A49),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Asignar Técnico'),
                                    ),
                                  ],
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
