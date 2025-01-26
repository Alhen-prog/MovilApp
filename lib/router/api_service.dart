import 'dart:convert';
import 'package:http/http.dart' as http;

class APIService {
  static const String _baseUrl = 'http://192.168.137.26:5000';

  // Función para registrar un usuario
  static Future<bool> registerUser({
    required String nombre,
    required String apellido,
    required String telefono,
    required String direccion,
    required String correo,
    required String contrasena,
    required int tipoUsuario,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/register'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'nombre': nombre,
              'apellido': apellido,
              'telefono': telefono,
              'direccion': direccion,
              'correo': correo,
              'contrasena': contrasena,
              'tipo_usuario': tipoUsuario,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        // ignore: avoid_print
        print(
            'Error al registrar usuario: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al registrar usuario: $e');
    }
    return false;
  }

  // Función para iniciar sesión
  static Future<Map<String, dynamic>?> login(
      String correo, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'email': correo,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'role': data['role'],
            'idCliente': data['id_cliente'],
            'idTecnico': data['id_tecnico'],
          };
        } else {
          // ignore: avoid_print
          print('Error de autenticación: ${data['message']}');
        }
      } else {
        // ignore: avoid_print
        print(
            'Error de autenticación: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al intentar iniciar sesión: $e');
    }
    return null;
  }

  // Función para actualizar el perfil del usuario
  static Future<bool> updateProfile({
    required int idPersona,
    required String nombre,
    required String apellido,
    required String correo,
    required String telefono,
    required String direccion,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/usuario/update_profile'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'id_persona': idPersona,
              'nombre': nombre,
              'apellido': apellido,
              'correo': correo,
              'telefono': telefono,
              'direccion': direccion,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        // ignore: avoid_print
        print(
            'Error al actualizar perfil: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al actualizar perfil: $e');
    }
    return false;
  }

  // Función para obtener los detalles del cliente
  static Future<Map<String, dynamic>?> getClientDetails(int idCliente) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/cliente/get_cliente/$idCliente'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          // ignore: avoid_print
          print('Error: ${data['message']}');
        }
      } else {
        // ignore: avoid_print
        print('Error al obtener detalles del cliente: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener detalles del cliente: $e');
    }
    return null;
  }

  static Future<bool> addService({
    required int idCliente,
    required String descripcion,
    required String tipoServicio,
    required String tipoPago,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/cliente/add_service'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'descripcion': descripcion,
              'tipo_servicio': tipoServicio,
              'tipo_pago': tipoPago,
              'id_cliente': idCliente,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        // ignore: avoid_print
        print(
            'Error al agregar servicio: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al agregar servicio: $e');
    }
    return false;
  }

// Función para obtener servicios de hardware
  static Future<List<Map<String, dynamic>>?> getHardwareServices(
      int idCliente) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/cliente/servicios/hardware/$idCliente'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['services']);
      } else {
        // ignore: avoid_print
        print(
            'Error al obtener servicios de hardware: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener servicios de hardware: $e');
    }
    return null;
  }

// Función para obtener servicios de software
  static Future<List<Map<String, dynamic>>?> getSoftwareServices(
      int idCliente) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/cliente/servicios/software/$idCliente'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['services']);
      } else {
        // ignore: avoid_print
        print(
            'Error al obtener servicios de software: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener servicios de software: $e');
    }
    return null;
  }

  // Función para obtener tipos de pago
  static Future<List<String>?> getTiposPago() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/cliente/tipos_pago'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<String>.from(
              data['tipos_pago'].map((pago) => pago['nombre_pago']));
        } else {
          // ignore: avoid_print
          print('Error: ${data['message']}');
        }
      } else {
        // ignore: avoid_print
        print(
            'Error al obtener tipos de pago: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener tipos de pago: $e');
    }
    return null;
  }

  // Función para obtener notificaciones no leídas
  static Future<List<Map<String, dynamic>>?> getNotificaciones(
      int idCliente) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cliente/notificaciones/$idCliente'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['notificaciones']);
      } else {
        // ignore: avoid_print
        print(
            'Error al obtener notificaciones: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener notificaciones: $e');
    }
    return null;
  }

// Función para obtener las órdenes asignadas al técnico
  static Future<List<Map<String, dynamic>>?> getOrdenesTecnico(
      int idTecnico) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/tecnico/ordenes/tecnico/$idTecnico'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // ignore: avoid_print
          print('Datos de la respuesta: ${data['ordenes']}');
          return List<Map<String, dynamic>>.from(data['ordenes']);
        } else {
          // ignore: avoid_print
          print('Error: ${data['message']}');
        }
      } else {
        // ignore: avoid_print
        print(
            'Error al obtener órdenes del técnico: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener órdenes del técnico: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getTecnicoDetails(int idTecnico) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/tecnico/tecnico/details/$idTecnico'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['tecnico'];
        } else {
          // ignore: avoid_print
          print('Error: ${data['message']}');
        }
      } else {
        // ignore: avoid_print
        print('Error al obtener detalles del técnico: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener detalles del técnico: $e');
    }
    return null;
  }

  // Función para actualizar el estado del técnico
  static Future<bool> updateTecnicoEstado(
      int idTecnico, String nuevoEstado) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/tecnico/tecnico/estado'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'id_tecnico': idTecnico,
              'estado': nuevoEstado,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        // ignore: avoid_print
        print(
            'Error al actualizar estado del técnico: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al actualizar estado del técnico: $e');
    }
    return false;
  }

  // Función para actualizar el estado de una orden

  static Future<bool> updateOrdenEstado(int idOrden, String nuevoEstado) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/tecnico/ordenes/estado'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'id_orden': idOrden,
              'estado': nuevoEstado,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        // ignore: avoid_print
        print(
            'Error al actualizar estado de la orden: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al actualizar estado de la orden: $e');
    }
    return false;
  }

  static Future<List<Map<String, dynamic>>?> getServiciosPorTecnico(
      int idTecnico) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/tecnico/servicios/tecnico/$idTecnico'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['servicios']);
        } else {
          // ignore: avoid_print
          print('Error: ${data['message']}');
        }
      } else {
        // ignore: avoid_print
        print(
            'Error al obtener servicios: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener servicios: $e');
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>?> getReparacionesCompletadas(
      int idTecnico) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/tecnico/ordenes/tecnico/$idTecnico'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(
            data['ordenes']
                .where((orden) => orden['estado'] == 'Reparación Completa'),
          );
        } else {
          // ignore: avoid_print
          print('Error: ${data['message']}');
        }
      } else {
        // ignore: avoid_print
        print(
            'Error al obtener órdenes del técnico: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener órdenes del técnico: $e');
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>?> getAllUsers() async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/usuario/get_all_users'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['usuarios']);
        } else {
          // ignore: avoid_print
          print('Error: ${data['message']}');
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener usuarios: $e');
    }
    return null;
  }

  static Future<bool> deleteUser(int idPersona) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl/admin/delete_user/$idPersona'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al eliminar usuario: $e');
    }
    return false;
  }

  static Future<bool> updateCredenciales({
    required int idPersona,
    required String nombre,
    required String apellido,
    required String correo,
    required String telefono,
    required String direccion,
    String? contrasena,
    required int tipoUsuario,
  }) async {
    try {
      Map<String, dynamic> body = {
        'id_persona': idPersona,
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'telefono': telefono,
        'direccion': direccion,
        'tipo_usuario': tipoUsuario,
      };

      if (contrasena != null && contrasena.isNotEmpty) {
        body['contrasena'] = contrasena;
      }

      final response = await http
          .put(
            Uri.parse('$_baseUrl/admin/update_credenciales'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        // ignore: avoid_print
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
    }
    return false;
  }

  static Future<Map<String, dynamic>?> getAdminDetails(int idAdmin) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/admin/admin/details/$idAdmin'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['admin'];
        } else {
          // ignore: avoid_print
          print('Error: ${data['message']}');
        }
      } else {
        // ignore: avoid_print
        print(
            'Error al obtener detalles del administrador: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener detalles del administrador: $e');
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>?>
      getTodosLosServiciosDeTodosLosClientes() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/admin/servicios/todos_clientes'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['servicios']);
        } else {
          // ignore: avoid_print
          print('Error: ${data['message']}');
        }
      } else {
        // ignore: avoid_print
        print(
            'Error al obtener todos los servicios: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener todos los servicios: $e');
    }
    return null;
  }

// Función para obtener el resumen de ventas
  static Future<List<Map<String, dynamic>>?> getResumenVentas() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/admin/get_resumen_ventas'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['resumen_ventas']);
        } else {
          // ignore: avoid_print
          print('Error: ${data['message']}');
        }
      } else {
        // ignore: avoid_print
        print(
            'Error al obtener resumen de ventas: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener resumen de ventas: $e');
    }
    return null;
  }

// Función para asignar un técnico a un servicio
  static Future<bool> asignarTecnico(int idServicio, int idTecnico) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/admin/assign_technician'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'id_servicio': idServicio,
              'id_tecnico': idTecnico,
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('Error al asignar técnico: $e');
      return false;
    }
  }

  // Función para actualizar el estado de un servicio
  static Future<bool> actualizarEstadoServicio(
      int idServicio, int nuevoEstado) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/update_service_status'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'id_servicio': idServicio,
              'nuevo_estado_servicio': nuevoEstado,
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('Error al actualizar el estado del servicio: $e');
      return false;
    }
  }

  // Método para obtener todos los técnicos disponibles
  static Future<List<Map<String, dynamic>>> getTecnicosDisponibles() async {
    final url = Uri.parse('$_baseUrl/admin/tecnicos');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['tecnicos'] != null) {
          return List<Map<String, dynamic>>.from(data['tecnicos']);
        } else {
          throw Exception('No se encontraron técnicos disponibles');
        }
      } else {
        throw Exception('Error al cargar los técnicos');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener los técnicos: $e');
      throw Exception('Error al obtener los técnicos');
    }
  }

  static Future<List<Map<String, dynamic>>?> getServiciosNoAsignados() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/admin/servicios/no_asignados'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['servicios_no_asignados'] != null) {
          return List<Map<String, dynamic>>.from(
              data['servicios_no_asignados']);
        } else {
          return [];
        }
      } else {
        // ignore: avoid_print
        print(
            'Error al obtener servicios no asignados: ${response.statusCode}, ${response.body}');
        return [];
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener servicios no asignados: $e');
      return [];
    }
  }

  static Future<bool> sendNotificationToClient(
      String idCliente, String title, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/send_notification'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'id_cliente': idCliente,
          'titulo': title,
          'mensaje': message,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        // ignore: avoid_print
        print(
            'Error al enviar notificación: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al enviar notificación: $e');
    }
    return false;
  }

  static Future<List<Map<String, dynamic>>> obtenerServiciosPorTecnico(
      int idTecnico) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/tecnico/servicios/tecnico/$idTecnico'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['servicios']);
        } else {
          // ignore: avoid_print
          print('Error desde el servidor: ${data['message']}');
        }
      } else {
        // ignore: avoid_print
        print(
            'Error al obtener servicios: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener servicios del técnico: $e');
    }
    return [];
  }

  static Future<bool> aceptarServicio(int idTecnico, int idServicio) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$_baseUrl/tecnico/servicios/tecnico/aceptar/$idTecnico/$idServicio'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return true;
        } else {
          // ignore: avoid_print
          print(
              'Error desde el servidor al aceptar el servicio: ${data['message']}');
        }
      } else {
        // ignore: avoid_print
        print(
            'Error al aceptar el servicio: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al aceptar servicio: $e');
    }
    return false; // En caso de error
  }

// Función para obtener los servicios "Por Aceptar" asignados al técnico
  static Future<List<Map<String, dynamic>>?> getServiciosPorAceptar(
      int idTecnico) async {
    try {
      final response = await http
          .get(Uri.parse(
              '$_baseUrl/tecnico/servicios/pendientes/tecnico/$idTecnico'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['servicios_pendientes']);
        } else {
          // ignore: avoid_print
          print('Error: ${data['message']}');
        }
      } else {
        // ignore: avoid_print
        print(
            'Error al obtener servicios por aceptar: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener servicios por aceptar: $e');
    }
    return null;
  }

  static Future<bool> aceptarServicioAsignado(
      int idTecnico, int idServicio) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$_baseUrl/tecnico/servicios/tecnico/aceptar/$idTecnico/$idServicio'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // ignore: avoid_print
          print('Servicio aceptado correctamente: ${data['message']}');
          return true;
        } else {
          // ignore: avoid_print
          print('Error al aceptar el servicio: ${data['message']}');
          return false;
        }
      } else if (response.statusCode == 404) {
        // ignore: avoid_print
        print('Servicio no encontrado o no asignado al técnico.');
      } else if (response.statusCode == 400) {
        // ignore: avoid_print
        print('El servicio no está en estado "Por Aceptar".');
      } else {
        // ignore: avoid_print
        print(
            'Error inesperado al aceptar el servicio: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al aceptar servicio: $e');
    }
    return false;
  }

// Función para actualizar el estado de una orden
  static Future<bool> cambiarOrdenEstado(
      int idOrden, String nuevoEstado) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/tecnico/cambiar/ordenes/estado'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'id_orden': idOrden,
              'estado': nuevoEstado,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        // ignore: avoid_print
        print(
            'Error al actualizar estado de la orden: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al actualizar estado de la orden: $e');
    }
    return false;
  }

// Función para asignar un monto a un servicio
  static Future<bool> asignarMontoServicio(
      int idServicio, int idTecnico, double monto) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/tecnico/servicio/asignar_monto'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'id_servicio': idServicio,
              'id_tecnico': idTecnico,
              'monto': monto,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        // ignore: avoid_print
        print(
            'Error al asignar monto al servicio: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al asignar monto al servicio: $e');
    }
    return false;
  }

  // Función para crear un cliente
  static Future<bool> crearCliente({
    required String nombre,
    required String apellido,
    required String telefono,
    required String direccion,
    required String correo,
    required String contrasena,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/cliente/crearcliente'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'nombre': nombre,
              'apellido': apellido,
              'telefono': telefono,
              'direccion': direccion,
              'correo': correo,
              'contrasena': contrasena,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        // ignore: avoid_print
        print(
            'Error al crear cliente: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al crear cliente: $e');
    }
    return false;
  }
}
