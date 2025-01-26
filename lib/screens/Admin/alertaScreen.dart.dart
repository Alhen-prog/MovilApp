// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:movilapp/router/api_service.dart'; 

class AlertaScreen extends StatefulWidget {
  final List<Map<String, dynamic>> clients; 
  const AlertaScreen({super.key, required this.clients});

  @override
  _AlertaScreenState createState() => _AlertaScreenState();
}

class _AlertaScreenState extends State<AlertaScreen> {
  String? selectedCliente;  
  TextEditingController titleController = TextEditingController(); 
  TextEditingController messageController = TextEditingController(); 

  void _sendNotification() async {
    if (selectedCliente != null && titleController.text.isNotEmpty && messageController.text.isNotEmpty) {
      final response = await APIService.sendNotificationToClient(
        selectedCliente!, 
        titleController.text, 
        messageController.text, 
      );

      if (response) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Notificación enviada")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al enviar notificación")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Por favor complete todos los campos")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Notificación'),
        backgroundColor: const Color(0xFF2D79F3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccionar Cliente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              hint: const Text("Seleccione un cliente"),
              value: selectedCliente,
              onChanged: (newValue) {
                setState(() {
                  selectedCliente = newValue;
                });
              },
              items: widget.clients.map<DropdownMenuItem<String>>((client) {
                return DropdownMenuItem<String>(
                  value: client['id_persona'].toString(), 
                  child: Text("${client['nombre']} ${client['apellido']}"), 
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Título de la Notificación',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Ingrese el título de la notificación',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Mensaje de la Notificación',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Ingrese el mensaje',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendNotification, 
              child: const Text('Enviar Notificación'),
            ),
          ],
        ),
      ),
    );
  }
}
