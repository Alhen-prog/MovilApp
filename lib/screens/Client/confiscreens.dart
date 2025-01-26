// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Importa url_launcher para enlaces externos
import 'editScreen.dart'; // Importa EditScreen correctamente
import 'beneficioScreen.dart'; // Importa BeneficioScreen correctamente
import 'pagoScreen.dart'; // Importa PagoScreen correctamente
import '../login_screens.dart'; // Asegúrate de importar tu pantalla de inicio de sesión

// Cambia ConfigScreen a un StatefulWidget
class ConfigScreen extends StatefulWidget {
  final String clientName;
  final int clientId; // Agrega el ID del cliente
  final String clientSurname;
  final String clientEmail;
  final String clientPhone;
  final String clientAddress;

  const ConfigScreen({
    super.key,
    required this.clientName,
    required this.clientId, // Recibe el ID del cliente
    required this.clientSurname,
    required this.clientEmail,
    required this.clientPhone,
    required this.clientAddress,
  });

  @override
  ConfigScreenState createState() => ConfigScreenState();
}

class ConfigScreenState extends State<ConfigScreen> {
  // Función para abrir WhatsApp
  Future<void> _openWhatsApp() async {
    const String whatsappUrl = 'https://wa.me/51947214396?text=Hola%20necesito%20asistencia%20técnica';
    final Uri url = Uri.parse(whatsappUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    }
  }

  // Función para abrir Google Maps con la ubicación de la tienda
  Future<void> _openStoreLocation() async {
    const String storeLocationUrl = 'https://www.google.com/maps/place/COMPUTER+HOUSE/@-9.0760678,-78.5947674,17z/data=!3m1!4b1!4m6!3m5!1s0x91ab8114d07781c1:0x50c3d574d0b44287!8m2!3d-9.0760678!4d-78.5921871!16s%2Fg%2F1q69vnwv_?entry=ttu&g_ep=EgoyMDI0MTEwNS4wIKXMDSoASAFQAw%3D%3D';
    final Uri url = Uri.parse(storeLocationUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la ubicación de la tienda')),
        );
      }
    }
  }

  // Función para mostrar el diálogo de confirmación al cerrar sesión
  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancelar
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirmar
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Más opciones'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: Text(
                      widget.clientName[0], // Primera letra del nombre del cliente
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hola,',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        widget.clientName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildOptionItem(
                      context,
                      icon: Icons.person,
                      text: 'Mi perfil',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditScreen(
                              idPersona: widget.clientId,
                              currentName: widget.clientName,
                              currentSurname: widget.clientSurname,
                              currentEmail: widget.clientEmail,
                              currentPhone: widget.clientPhone,
                              currentAddress: widget.clientAddress,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildOptionItem(
                      context,
                      icon: Icons.discount,
                      text: 'Mis Beneficios',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BeneficioScreen(),
                          ),
                        );
                      },
                    ),
                    _buildOptionItem(
                      context,
                      icon: Icons.settings,
                      text: 'Conversar con el técnico',
                      onPressed: _openWhatsApp,
                    ),
                    _buildOptionItem(
                      context,
                      icon: Icons.credit_card,
                      text: 'Tipos de Pago',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PagoScreen(),
                          ),
                        );
                      },
                    ),
                    _buildOptionItem(
                      context,
                      icon: Icons.location_on,
                      text: 'Ubicar la tienda',
                      onPressed: _openStoreLocation,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(252, 8, 116, 238),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _showLogoutConfirmation(context),
                  child: const Text(
                    'Cerrar sesión',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0F47F0)),
        title: Text(text, style: const TextStyle(fontSize: 16, color: Color(0xFF333333))),
        onTap: onPressed,
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
