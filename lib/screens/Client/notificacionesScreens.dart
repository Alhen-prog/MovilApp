// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:movilapp/router/api_service.dart';

class NotificacionesScreen extends StatefulWidget {
  final int idCliente;
  const NotificacionesScreen({super.key, required this.idCliente});

  @override
  _NotificacionesScreenState createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  List<Map<String, dynamic>>? notificaciones;

  @override
  void initState() {
    super.initState();
    _loadNotificaciones();
  }

  // Función para cargar notificaciones desde la API
  void _loadNotificaciones() async {
    final data = await APIService.getNotificaciones(widget.idCliente);
    setState(() {
      notificaciones = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: const Color(0xFF2D79F3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: notificaciones == null
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: notificaciones!.length,
                itemBuilder: (context, index) {
                  final notificacion = notificaciones![index];
                  return NotificationCard(
                    title: notificacion['titulo'],
                    description: notificacion['mensaje'],
                    date: notificacion['fecha_envio'].toString(),
                  );
                },
              ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;

  const NotificationCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              date,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
