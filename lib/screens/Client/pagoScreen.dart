// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:movilapp/router/api_service.dart'; // Asegúrate de importar tu servicio de API

class PagoScreen extends StatelessWidget {
  const PagoScreen({super.key});

  // Conectar con la base de datos para obtener los tipos de pago
  Future<List<String>?> obtenerTiposDePago() async {
    return await APIService.getTiposPago(); // Llama a la función del servicio de API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formas de Pago'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<List<String>?>(
        future: obtenerTiposDePago(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar tipos de pago'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay tipos de pago disponibles'));
          } else {
            final tiposDePago = snapshot.data!;
            return ListView.builder(
              itemCount: tiposDePago.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(
                      Icons.payment,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(
                      tiposDePago[index],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Seleccionaste ${tiposDePago[index]}')),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
