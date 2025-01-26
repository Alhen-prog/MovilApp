import 'package:flutter/material.dart';
import 'package:movilapp/router/api_service.dart';

class SoftwareScreen extends StatefulWidget {
  final int idCliente;
  const SoftwareScreen({super.key, required this.idCliente});

  @override
  _SoftwareScreenState createState() => _SoftwareScreenState();
}

class _SoftwareScreenState extends State<SoftwareScreen> {
  List<Map<String, dynamic>> _softwareServices = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchSoftwareServices();
  }

  // Función para obtener los servicios de software desde la API
  void _fetchSoftwareServices() async {
    try {
      final softwareServices = await APIService.getSoftwareServices(widget.idCliente);
      if (!mounted) return;

      if (softwareServices != null) {
        setState(() {
          _softwareServices = softwareServices;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print('Error al obtener servicios de software: $e');
    }
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

  // Función para construir la lista de servicios de software
  Widget _buildSoftwareList() {
    if (_softwareServices.isEmpty) {
      return const Center(child: Text('No hay servicios de software disponibles.'));
    }

    return ListView.builder(
      itemCount: _softwareServices.length,
      itemBuilder: (context, index) {
        final service = _softwareServices[index];
        final descripcion = service['descripcion'] ?? 'Descripción no disponible';
        final monto = service['monto'] != null ? 'S/ ${service['monto']?.toString()}' : 'No disponible';
        final estado = service['estado_equipo'] ?? 'Estado desconocido';

        return _buildServiceCard(
          icon: Icons.computer,
          title: descripcion,
          subtitle: 'Monto: $monto\nEstado: $estado',
          statusColor: _getStatusColor(estado),
        );
      },
    );
  }

  // Función para construir las tarjetas de servicios
  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color statusColor,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shadowColor: Colors.grey.withOpacity(0.1),
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
            color: Color(0xFF111827),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        trailing: Icon(Icons.circle, color: statusColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios de Software'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Error al cargar servicios de software',
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchSoftwareServices,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildSoftwareList(),
                ),
    );
  }
}