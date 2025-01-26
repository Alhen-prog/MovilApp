import 'package:flutter/material.dart';
import 'package:movilapp/router/api_service.dart';

class HardwareScreen extends StatefulWidget {
  final int idCliente;
  const HardwareScreen({super.key, required this.idCliente});

  @override
  _HardwareScreenState createState() => _HardwareScreenState();
}

class _HardwareScreenState extends State<HardwareScreen> {
  List<Map<String, dynamic>> _hardwareServices = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchHardwareServices();
  }

  // Función para obtener los servicios de hardware desde la API
  void _fetchHardwareServices() async {
    try {
      final hardwareServices = await APIService.getHardwareServices(widget.idCliente);
      if (hardwareServices != null) {
        setState(() {
          _hardwareServices = hardwareServices;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print('Error al obtener servicios de hardware: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios de Hardware'),
        backgroundColor: const Color(0xFF2D79F3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasError
                ? const Center(child: Text('Error al cargar los servicios de hardware'))
                : _buildHardwareList(),
      ),
    );
  }

  // Función para construir la lista de servicios de hardware
  Widget _buildHardwareList() {
    if (_hardwareServices.isEmpty) {
      return const Center(child: Text('No hay servicios de hardware disponibles.'));
    }

    return ListView.builder(
      itemCount: _hardwareServices.length,
      itemBuilder: (context, index) {
        final service = _hardwareServices[index];
        final descripcion = service['descripcion'] ?? 'Descripción no disponible';
        final monto = service['monto'] != null ? 'S/ ${service['monto']?.toString()}' : 'No disponible';
        final estado = service['estado_equipo'] ?? 'Estado desconocido';

        return _buildServiceCard(
          context,
          icon: Icons.build,
          title: descripcion,
          subtitle: 'Monto: $monto\nEstado: $estado',
          statusColor: _getStatusColor(estado),
        );
      },
    );
  }

  // Función para obtener el color según el estado
  Color _getStatusColor(String estado) {
    switch (estado) {
      case 'En Espera':
        return Colors.yellow;
      case 'En Reparación':
        return Colors.orange;
      case 'Reparado':
        return Colors.green;
      case 'Entregado':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Función para construir las tarjetas de servicios
  Widget _buildServiceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color statusColor,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          radius: 30,
          child: Icon(icon, size: 30, color: statusColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        trailing: Icon(Icons.circle, color: statusColor),
      ),
    );
  }
}
