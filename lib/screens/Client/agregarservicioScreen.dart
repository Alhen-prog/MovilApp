// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:movilapp/router/api_service.dart'; // Importa el archivo donde se encuentra la API

class AgregarServicioScreen extends StatefulWidget {
  final int idCliente;  // El idCliente es pasado correctamente desde HomeScreen

  const AgregarServicioScreen({super.key, required this.idCliente});

  @override
  _AgregarServicioScreenState createState() => _AgregarServicioScreenState();
}

class _AgregarServicioScreenState extends State<AgregarServicioScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _descripcion;
  int? _tipoServicio;  // Cambiado a int para manejar ID
  int? _tipoPago;      // Cambiado a int para manejar ID

  final List<Map<String, dynamic>> _tiposServicios = [
    {'id': 1, 'name': 'Hardware'},
    {'id': 2, 'name': 'Software'},
  ];

  final List<Map<String, dynamic>> _tiposPago = [
    {'id': 1, 'name': 'Yape'},
    {'id': 2, 'name': 'Plin'},
    {'id': 3, 'name': 'Efectivo'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Servicio'),
        backgroundColor: const Color.fromARGB(255, 62, 165, 225),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título sin mostrar el idCliente
              Text(
                'Agregar un nuevo servicio',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Campo para la descripción del servicio
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Descripción del Servicio',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
                onSaved: (value) {
                  _descripcion = value;
                },
              ),
              const SizedBox(height: 16),

              // Dropdown para seleccionar tipo de servicio
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Servicio',
                  border: OutlineInputBorder(),
                ),
                value: _tipoServicio,
                items: _tiposServicios.map((tipo) {
                  return DropdownMenuItem<int>(
                    value: tipo['id'],
                    child: Text(tipo['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _tipoServicio = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona un tipo de servicio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dropdown para seleccionar tipo de pago
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Pago',
                  border: OutlineInputBorder(),
                ),
                value: _tipoPago,
                items: _tiposPago.map((pago) {
                  return DropdownMenuItem<int>(
                    value: pago['id'],
                    child: Text(pago['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _tipoPago = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona un tipo de pago';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Botón para agregar el servicio
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();

                    // Llamar a la API para agregar el servicio
                    bool success = await APIService.addService(
                      idCliente: widget.idCliente,
                      descripcion: _descripcion!,
                      tipoServicio: _tipoServicio.toString(),
                      tipoPago: _tipoPago.toString(),
                    );

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Servicio agregado exitosamente')),
                      );
                      // Navegar de vuelta a la pantalla anterior con resultado true
                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error al agregar servicio')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: const Color(0xFF3EABE1),  // Color de fondo
                  foregroundColor: Colors.white,  // Color del texto
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text('Agregar Servicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
