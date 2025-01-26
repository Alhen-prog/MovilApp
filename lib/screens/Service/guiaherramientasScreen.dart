// ignore_for_file: file_names, avoid_print

import 'package:flutter/material.dart';

class GuiaHerramientasScreen extends StatelessWidget {
  const GuiaHerramientasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guía de Uso de Herramientas'),
        backgroundColor: const Color(0xFF2D79F3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Herramientas de Reparación',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildToolGuide(
              'Kit de Destornilladores',
              'Incluye varios tamaños de destornilladores magnéticos para desmontar laptops y PCs. '
              'Asegúrese de utilizar el destornillador adecuado para evitar daños en los tornillos.',
            ),
            _buildToolGuide(
              'Pasta Térmica',
              'Se utiliza para mejorar la conducción de calor entre el procesador y el disipador. '
              'Aplique una cantidad adecuada y distribuya uniformemente para un enfriamiento óptimo.',
            ),
            _buildToolGuide(
              'Aire Comprimido',
              'Ideal para limpiar el polvo acumulado en componentes como ventiladores y fuentes de alimentación. '
              'Utilice en áreas bien ventiladas y con precaución para no dañar componentes sensibles.',
            ),
            _buildToolGuide(
              'Unidad USB de Arranque',
              'Contiene herramientas de diagnóstico y sistemas operativos para instalar o formatear equipos. '
              'Asegúrese de actualizar regularmente las herramientas en la unidad USB.',
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildToolGuide(String toolName, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          toolName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(description),
        const Divider(height: 20, thickness: 1),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildVideoGuide(String url, String title) {
    return ListTile(
      leading: const Icon(Icons.play_circle_fill, color: Color(0xFF2D79F3)),
      title: Text(title),
      onTap: () {
        // Aquí puedes redirigir al usuario al enlace del video
        print('Video $title seleccionado');
      },
    );
  }
}
