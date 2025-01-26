// ignore_for_file: file_names, avoid_print, control_flow_in_finally, use_build_context_synchronously, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:movilapp/router/api_service.dart';
import 'side_menu.dart';

class EquipoScreen extends StatefulWidget {
  final String tecnicoNombre;
  final String tecnicoEspecialidad;
  final int idTecnico;

  const EquipoScreen({
    super.key,
    required this.tecnicoNombre,
    required this.tecnicoEspecialidad,
    required this.idTecnico,
  });

  @override
  State<EquipoScreen> createState() => _EquipoScreenState();
}

class _EquipoScreenState extends State<EquipoScreen> {
  List<Map<String, dynamic>> equiposEnEspera = [];
  List<Map<String, dynamic>> equiposEnReparacion = [];
  List<Map<String, dynamic>> equiposReparados = [];
  List<Map<String, dynamic>> equiposEntregados = [];
  bool isLoading = true;
  String errorMessage = '';

  /// Función para obtener los equipos asignados al técnico y clasificarlos por estado
  Future<void> _fetchEquipos() async {
    if (!mounted) return; // Verifica si el widget aún está montado
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Llama a la función de API para obtener los servicios del técnico
      final servicios = await APIService.getServiciosPorTecnico(widget.idTecnico);
      print('Servicios obtenidos: $servicios');

      if (!mounted) return; // Verifica nuevamente después de la llamada asíncrona

      if (servicios != null && servicios.isNotEmpty) {
        setState(() {
          equiposEnEspera =
              servicios.where((s) => s['estado_equipo'] == 'En Espera').toList();
          equiposEnReparacion =
              servicios.where((s) => s['estado_equipo'] == 'En Reparación').toList();
          equiposReparados =
              servicios.where((s) => s['estado_equipo'] == 'Reparado').toList();
          equiposEntregados =
              servicios.where((s) => s['estado_equipo'] == 'Entregado').toList();
        });
      } else {
        setState(() {
          errorMessage = 'No hay servicios asignados actualmente.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error al cargar equipos: $e';
      });
      print('Error al cargar equipos: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Función para cambiar el estado de una orden
  Future<void> _cambiarEstadoOrden(int idOrden, String nuevoEstado) async {
    try {
      bool success = await APIService.cambiarOrdenEstado(idOrden, nuevoEstado);
      if (!mounted) return; // Verifica antes de usar el contexto
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado de la orden $idOrden actualizado a $nuevoEstado')),
        );
        _fetchEquipos(); // Recargar la lista después de actualizar el estado
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el estado de la orden $idOrden')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el estado de la orden: $e')),
      );
      print('Error al actualizar estado de la orden: $e');
    }
  }

  /// Función para mostrar un diálogo y asignar un monto a un servicio
  void _mostrarDialogoAsignarMonto(int idServicio, [double? existingMonto]) {
    double monto = existingMonto ?? 0.0;
    final parentContext = context;

    // Controlador de texto para el campo de monto
    TextEditingController montoController = TextEditingController(
      text: monto > 0 ? monto.toString() : '',
    );

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Asignar Monto'),
          content: TextField(
            controller: montoController,  // Asignamos el controlador
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Monto'),
            onChanged: (value) {
              monto = double.tryParse(value) ?? 0.0;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                if (monto <= 0) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text('Por favor, ingresa un monto válido')),
                  );
                  return;
                }
                bool success = await APIService.asignarMontoServicio(
                    idServicio, widget.idTecnico, monto);
                if (!mounted) return;
                if (success) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text('Monto asignado correctamente')),
                  );
                  _fetchEquipos();
                } else {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text('Error al asignar monto')),
                  );
                }
              },
              child: const Text('Asignar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchEquipos();
  }

  /// Widget para construir una sección de equipos basada en su estado
  Widget _buildEquiposSection(
    String titulo,
    List<Map<String, dynamic>> equipos,
    IconData icono,
    Color colorIcono,
    String? siguienteEstado, {
    bool asignarMonto = false,
  }) {
    if (equipos.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...equipos.map((equipo) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Icon(icono, color: colorIcono),
              title: Text(equipo['descripcion'] ?? 'Equipo sin descripción'),
              subtitle: Text('Monto: S/${equipo['monto'] ?? 'No asignado'}'),
              trailing: siguienteEstado != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (asignarMonto)
                          IconButton(
                            icon: const Icon(Icons.attach_money, color: Colors.green),
                            onPressed: () {
                              double? existingMonto;
                              if (equipo['monto'] != null && equipo['monto'] is num) {
                                existingMonto = (equipo['monto'] as num).toDouble();
                              }
                              _mostrarDialogoAsignarMonto(equipo['id_servicio'], existingMonto);
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Colors.blue),
                          onPressed: () {
                            _cambiarEstadoOrden(equipo['id_orden'], siguienteEstado);
                          },
                        ),
                      ],
                    )
                  : null,
            ),
          );
        }).toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Equipos - ${widget.tecnicoNombre}'),
        backgroundColor: const Color(0xFF2D79F3),
      ),
      drawer: SideMenu(
        tecnicoNombre: widget.tecnicoNombre,
        tecnicoEspecialidad: widget.tecnicoEspecialidad,
        idTecnico: widget.idTecnico,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : equiposEnEspera.isEmpty &&
                    equiposEnReparacion.isEmpty &&
                    equiposReparados.isEmpty &&
                    equiposEntregados.isEmpty
                ? Center(
                    child: Text(
                      errorMessage.isNotEmpty
                          ? errorMessage
                          : 'No hay equipos asignados actualmente.',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchEquipos,
                    child: ListView(
                      children: [
                        _buildEquiposSection(
                          'En Espera',
                          equiposEnEspera,
                          Icons.hourglass_empty,
                          Colors.yellow,
                          'En Reparación',
                        ),
                        _buildEquiposSection(
                          'En Reparación',
                          equiposEnReparacion,
                          Icons.build,
                          Colors.orange,
                          'Reparado',
                          asignarMonto: true,  // Habilitar asignar monto aquí
                        ),
                        _buildEquiposSection(
                          'Reparado',
                          equiposReparados,
                          Icons.check_circle_outline,
                          Colors.green,
                          'Entregado',
                        ),
                        _buildEquiposSection(
                          'Entregado',
                          equiposEntregados,
                          Icons.done_all,
                          Colors.blue,
                          null,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
