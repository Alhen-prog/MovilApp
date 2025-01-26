// ignore_for_file: file_names, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:movilapp/router/api_service.dart';
import 'softwareScreen.dart';
import 'hardwareScreen.dart';
import 'confiscreens.dart';
import 'notificacionesScreens.dart';
import 'agregarServicioScreen.dart';  // Asegúrate de importar esta pantalla

class HomeScreen extends StatefulWidget {
  final int idCliente;
  const HomeScreen({super.key, required this.idCliente});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  List<Map<String, dynamic>>? instalaciones;
  List<Map<String, dynamic>>? reparaciones;
  Map<String, dynamic>? clienteDetalles;

  @override
  void initState() {
    super.initState();
    if (widget.idCliente > 0) {
      _loadData();
      _loadClientDetails(); // Cargar detalles del cliente
    } else {
      print('Error: ID del cliente inválido');
    }
  }

  void _loadData() async {
    final instalacionesData = await APIService.getSoftwareServices(widget.idCliente);
    final reparacionesData = await APIService.getHardwareServices(widget.idCliente);

    setState(() {
      instalaciones = instalacionesData;
      reparaciones = reparacionesData;
    });
  }

  void _loadClientDetails() async {
    final details = await APIService.getClientDetails(widget.idCliente);
    setState(() {
      clienteDetalles = details;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Flexible(
              flex: 1,
              child: Image.asset(
                'lib/assets/img/computer.png',
                height: 75,
              ),
            ),
            const SizedBox(width: 15),
            const Flexible(
              flex: 3,
              child: Text(
                'Computer House',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 62, 165, 225),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificacionesScreen(idCliente: widget.idCliente),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: clienteDetalles != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfigScreen(
                          clientName: clienteDetalles!['nombre'],
                          clientId: widget.idCliente,
                          clientSurname: clienteDetalles!['apellido'],
                          clientEmail: clienteDetalles!['correo'],
                          clientPhone: clienteDetalles!['telefono'],
                          clientAddress: clienteDetalles!['direccion'],
                        ),
                      ),
                    );
                  }
                : null, // Esperar a que se carguen los detalles del cliente
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: <Widget>[
          HomeContent(idCliente: widget.idCliente),  // Pasamos el idCliente aquí
          SoftwareScreen(idCliente: widget.idCliente),
          HardwareScreen(idCliente: widget.idCliente),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(252, 8, 116, 238),
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home),
              color: _selectedIndex == 0 ? Colors.yellow : Colors.white,
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: const Icon(Icons.install_desktop),
              color: _selectedIndex == 1 ? Colors.yellow : Colors.white,
              onPressed: () => _onItemTapped(1),
            ),
            IconButton(
              icon: const Icon(Icons.construction),
              color: _selectedIndex == 2 ? Colors.yellow : Colors.white,
              onPressed: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final int idCliente;  // Recibimos el idCliente aquí
  const HomeContent({super.key, required this.idCliente});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildInfoCard(
                context,
                title: 'Atención al Cliente',
                description: 'Contáctanos para cualquier consulta sobre tu servicio técnico.',
                icon: Icons.phone,
                color: Colors.green,
                action: () {
                  // Acción para contactar al soporte
                },
              ),
              _buildInfoCard(
                context,
                title: 'Seguimiento de Servicios',
                description: 'Revisa el estado actual de tu equipo en servicio.',
                icon: Icons.track_changes,
                color: Colors.blue,
                action: () {
                  // Acción para ver seguimiento de servicios
                },
              ),
              _buildInfoCard(
                context,
                title: 'Agregar Servicio',
                description: 'Añadir un nuevo servicio o reparación.',
                icon: Icons.add_box,
                color: Colors.orange,
                action: () async {
                  // Pasamos el idCliente directamente a la pantalla de AgregarServicioScreen
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AgregarServicioScreen(idCliente: idCliente),
                    ),
                  );

                  // Si se agregó un servicio exitosamente, recargar los datos
                  if (result == true) {
                    // Llama a la función en HomeScreen para recargar los datos
                    final homeState = context.findAncestorStateOfType<HomeScreenState>();
                    homeState?._loadData();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback action,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: action,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(icon, size: 40, color: color),
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
      ),
    );
  }
}
