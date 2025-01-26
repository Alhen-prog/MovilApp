import 'dart:io';
import 'package:flutter/material.dart';
import 'package:movilapp/router/api_service.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;

import 'package:file_picker/file_picker.dart';

class InformeScreen extends StatefulWidget {
  const InformeScreen({super.key});

  @override
  _InformeScreenState createState() => _InformeScreenState();
}

class _InformeScreenState extends State<InformeScreen> {
  List<Map<String, dynamic>>? resumenVentas;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cargarResumenVentas();
  }

  Future<void> _cargarResumenVentas() async {
    try {
      final data = await APIService.getResumenVentas();
      if (data != null && data.isNotEmpty) {
        setState(() {
          resumenVentas = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'No se encontraron registros.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Hubo un problema al cargar los datos.';
        isLoading = false;
      });
    }
  }

  Future<void> _downloadPDF(String periodo, String pdfUrl) async {
    // Verificar permisos para el almacenamiento
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;

      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Para descargar el PDF, se requiere acceso a almacenamiento. Por favor, habilite el permiso."),
          ),
        );

        bool permissionGranted =
            await Permission.manageExternalStorage.request().isGranted;
        if (!permissionGranted) {
          // Si el permiso no se concede, no continuar con la descarga
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "Permiso de almacenamiento denegado. No se puede descargar el archivo.")),
          );
          return;
        }
      }
    }

    try {
      final response = await http.get(Uri.parse(pdfUrl));

      if (response.statusCode == 200) {
        await _guardarPDF(response.bodyBytes, periodo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al descargar el archivo.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al descargar el archivo.")),
      );
    }
  }

  Future<void> _exportToPDF(String periodo, double total) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Resumen de Ventas',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Periodo: $periodo'),
              pw.Text('Total: S/$total'),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();
    await _guardarPDF(pdfBytes, periodo);
  }

  Future<void> _guardarPDF(List<int> pdfBytes, String periodo) async {
    try {
      String? directory = await FilePicker.platform.getDirectoryPath();

      final filePath =
          '$directory/resumen_ventas_${periodo}_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';

      final file = File(filePath);

      if (!(await Directory(directory!).exists())) {
        await Directory(directory).create(recursive: true);
      }

      await file.writeAsBytes(pdfBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archivo PDF guardado en: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar el archivo PDF: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Informes'),
        backgroundColor: const Color.fromARGB(255, 58, 97, 174),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage)) // Mostrar mensaje de error
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen de Ventas:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: resumenVentas?.length ?? 0,
                          itemBuilder: (context, index) {
                            final venta = resumenVentas![index];
                            return Card(
                              child: ListTile(
                                title: Text('Periodo: ${venta['periodo']}'),
                                subtitle: Text('Total: S/${venta['total']}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.download),
                                  onPressed: () {
                                    _exportToPDF(
                                        venta['periodo'], venta['total']);
                                  },
                                  color: Colors.blue,
                                  tooltip: 'Descargar PDF',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
