// ignore_for_file: file_names

import 'package:flutter/material.dart';

class BeneficioScreen extends StatelessWidget {
  final List<Map<String, String>> beneficios = [
    {
      'titulo': 'Garantía Extendida',
      'descripcion': 'Disfruta de una garantía extendida de hasta 1 año en todos los servicios realizados.',
      'icon': 'verified' // Nombre de ícono de Material Icons
    },
    {
      'titulo': 'Soporte Prioritario',
      'descripcion': 'Recibe soporte prioritario en cada solicitud de servicio, con tiempos de respuesta reducidos.',
      'icon': 'support_agent'
    },
    {
      'titulo': 'Descuentos Especiales',
      'descripcion': 'Accede a descuentos especiales en reparaciones de software y hardware.',
      'icon': 'local_offer'
    },
    {
      'titulo': 'Revisión Gratuita',
      'descripcion': 'Solicita una revisión gratuita de tu equipo antes de tomar una decisión de reparación.',
      'icon': 'engineering'
    },
  ];

  BeneficioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beneficios del Servicio'),
        backgroundColor: const Color(0xFF0F47F0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: beneficios.length,
          itemBuilder: (context, index) {
            final beneficio = beneficios[index];
            return _buildBenefitCard(
              title: beneficio['titulo']!,
              description: beneficio['descripcion']!,
              icon: beneficio['icon']!,
            );
          },
        ),
      ),
    );
  }

  Widget _buildBenefitCard({required String title, required String description, required String icon}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              _getIcon(icon),
              size: 40,
              color: const Color(0xFF0F47F0),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'verified':
        return Icons.verified;
      case 'support_agent':
        return Icons.support_agent;
      case 'local_offer':
        return Icons.local_offer;
      case 'engineering':
        return Icons.engineering;
      default:
        return Icons.star; // Ícono predeterminado en caso de error
    }
  }
}
