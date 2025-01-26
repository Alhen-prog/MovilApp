from flask import Blueprint, request, jsonify
from router.database.base_datos import get_db_connection  
import bcrypt
import logging

cliente_bp = Blueprint('cliente', __name__)

# Ruta para obtener los detalles de un cliente
@cliente_bp.route('/get_cliente/<int:id_cliente>', methods=['GET'])
def get_cliente(id_cliente):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        query = """
            SELECT p.nombre, p.apellido, p.correo, p.telefono, p.direccion
            FROM Persona p
            JOIN Cliente c ON p.id_persona = c.id_persona
            WHERE c.id_persona = ?;
        """
        cursor.execute(query, (id_cliente,))
        cliente = cursor.fetchone()
        
        if cliente:
            return jsonify({
                'success': True,
                'data': {
                    'nombre': cliente[0],
                    'apellido': cliente[1],
                    'correo': cliente[2],
                    'telefono': cliente[3],
                    'direccion': cliente[4],
                }
            }), 200
        else:
            return jsonify({'success': False, 'message': 'Cliente no encontrado'}), 404
    except Exception as e:
        logging.error("Error fetching client details: %s", e)
        return jsonify({'success': False, 'message': 'Error en el servidor', 'error': str(e)}), 500
    finally:
        conn.close()

# Ruta para agregar un servicio
@cliente_bp.route('/add_service', methods=['POST'])
def add_service():
    data = request.get_json()

    descripcion = data.get('descripcion')
    tipo_servicio = data.get('tipo_servicio')  
    tipo_pago = data.get('tipo_pago')  
    id_cliente = data.get('id_cliente')  

    if not descripcion or not tipo_servicio or not tipo_pago or not id_cliente:
        return jsonify({'success': False, 'message': 'Faltan campos obligatorios'}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO Servicio (id_cliente, id_tipo_servicio, descripcion, id_tipo_pago)
            VALUES (?, ?, ?, ?);
        """, (id_cliente, tipo_servicio, descripcion, tipo_pago))

        conn.commit()

        return jsonify({'success': True, 'message': 'Servicio agregado correctamente'}), 200

    except Exception as e:
        logging.error("Error en el endpoint add_service: %s", e)
        return jsonify({'success': False, 'message': 'Error en el servidor', 'error': str(e)}), 500

    finally:
        conn.close()

# Ruta para obtener los servicios de hardware de un cliente
@cliente_bp.route('/servicios/hardware/<int:id_cliente>', methods=['GET'])
def get_hardware_services(id_cliente):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        query = """
            SELECT s.descripcion, m.monto, e.estado AS estado_equipo
            FROM Ordenes o
            JOIN Servicio s ON o.id_servicio = s.id_servicio
            JOIN Tipo_Servicio ts ON s.id_tipo_servicio = ts.id_tipo_servicio
            LEFT JOIN Monto m ON s.id_servicio = m.id_servicio
            JOIN Estado_Equipo e ON o.id_estado_equipo = e.id_estado_equipo
            WHERE o.id_cliente = ? 
              AND ts.nombre_tipo = 'Hardware';
        """
        cursor.execute(query, (id_cliente,))
        services = cursor.fetchall()
        results = [
            {
                'descripcion': row[0],
                'monto': row[1] if row[1] is not None else 'No asignado',
                'estado_equipo': row[2]
            }
            for row in services
        ]
        return jsonify({'success': True, 'services': results}), 200
    except Exception as e:
        logging.error("Error fetching hardware services: %s", e)
        return jsonify({'success': False, 'message': 'Error al obtener servicios de hardware', 'error': str(e)}), 500
    finally:
        conn.close()

# Ruta para obtener los servicios de software de un cliente
@cliente_bp.route('/servicios/software/<int:id_cliente>', methods=['GET'])
def get_software_services(id_cliente):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        query = """
            SELECT s.descripcion, m.monto, e.estado AS estado_equipo
            FROM Ordenes o
            JOIN Servicio s ON o.id_servicio = s.id_servicio
            JOIN Tipo_Servicio ts ON s.id_tipo_servicio = ts.id_tipo_servicio
            LEFT JOIN Monto m ON s.id_servicio = m.id_servicio
            JOIN Estado_Equipo e ON o.id_estado_equipo = e.id_estado_equipo
            WHERE o.id_cliente = ? 
              AND ts.nombre_tipo = 'Software';
        """
        cursor.execute(query, (id_cliente,))
        services = cursor.fetchall()
        results = [
            {
                'descripcion': row[0],
                'monto': row[1] if row[1] is not None else 'No asignado',
                'estado_equipo': row[2]
            }
            for row in services
        ]
        return jsonify({'success': True, 'services': results}), 200
    except Exception as e:
        logging.error("Error fetching software services: %s", e)
        return jsonify({'success': False, 'message': 'Error al obtener servicios de software', 'error': str(e)}), 500
    finally:
        conn.close()

# Ruta para obtener las notificaciones de un cliente
@cliente_bp.route('/notificaciones/<int:id_cliente>', methods=['GET'])
def get_notificaciones(id_cliente):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        query = """
            SELECT titulo, mensaje, fecha_envio
            FROM Notificaciones
            WHERE id_cliente = ? AND leida = 0
        """
        cursor.execute(query, (id_cliente,))
        notificaciones = cursor.fetchall()
        results = [{'titulo': row[0], 'mensaje': row[1], 'fecha_envio': row[2].strftime("%Y-%m-%d %H:%M:%S")} for row in notificaciones]
        return jsonify({'success': True, 'notificaciones': results}), 200
    except Exception as e:
        logging.error("Error fetching notifications: %s", e)
        return jsonify({'success': False, 'message': 'Error al obtener notificaciones', 'error': str(e)}), 500
    finally:
        conn.close()

# Ruta para obtener los tipos de pago disponibles
@cliente_bp.route('/tipos_pago', methods=['GET'])
def get_tipos_pago():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT nombre_pago FROM Tipo_Pago")
        tipos_pago = cursor.fetchall()
        
        results = [{'nombre_pago': row[0]} for row in tipos_pago]
        return jsonify({'success': True, 'tipos_pago': results}), 200
    except Exception as e:
        logging.error("Error fetching payment types: %s", e)
        return jsonify({'success': False, 'message': 'Error en el servidor', 'error': str(e)}), 500
    finally:
        conn.close()

# Ruta para crear un cliente
@cliente_bp.route('/crearcliente', methods=['POST'])
def crear_cliente():
    data = request.get_json()
    nombre = data.get('nombre')
    apellido = data.get('apellido')
    correo = data.get('correo')
    telefono = data.get('telefono')
    direccion = data.get('direccion')
    contrasena = data.get('contrasena')  
    if not all([nombre, apellido, correo, telefono, direccion, contrasena]):
        return jsonify({'success': False, 'message': 'Faltan campos obligatorios'}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        salt = bcrypt.gensalt()
        contrasena_hash = bcrypt.hashpw(contrasena.encode('utf-8'), salt).decode('utf-8')

        cursor.execute("""
            INSERT INTO Persona (nombre, apellido, correo, telefono, direccion)
            VALUES (?, ?, ?, ?, ?)
        """, (nombre, apellido, correo, telefono, direccion))
        conn.commit()

        cursor.execute("SELECT @@IDENTITY AS id_persona")
        id_persona = cursor.fetchone()[0]

        cursor.execute("""
            INSERT INTO Credenciales (id_persona, contrasena_hash, id_tipo_usuario)
            VALUES (?, ?, ?)
        """, (id_persona, contrasena_hash, 1))  
        conn.commit()

        cursor.execute("INSERT INTO Cliente (id_persona) VALUES (?)", (id_persona,))
        conn.commit()

        return jsonify({'success': True, 'message': 'Cliente registrado correctamente'}), 200
    except Exception as e:
        logging.error("Error al crear cliente: %s", e)
        return jsonify({'success': False, 'message': 'Error al registrar cliente', 'error': str(e)}), 500
    finally:
        conn.close()
