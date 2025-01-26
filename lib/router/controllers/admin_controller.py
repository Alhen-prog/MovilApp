from flask import Blueprint, request, jsonify
from router.database.base_datos import get_db_connection  
import logging
import bcrypt

# Crear el Blueprint para el controlador de admin
admin_bp = Blueprint('admin', __name__)

# Ruta para obtener los detalles de un administrador
@admin_bp.route('/admin/details/<int:id_admin>', methods=['GET'])
def get_admin_details(id_admin):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        query = """
            SELECT p.nombre, p.apellido, p.correo, p.telefono, p.direccion
            FROM Persona p
            JOIN Administrador a ON p.id_persona = a.id_persona
            WHERE a.id_persona = ?
        """
        cursor.execute(query, (id_admin,))
        admin = cursor.fetchone()

        if admin:
            return jsonify({
                'success': True,
                'admin': {
                    'nombre': admin[0],
                    'apellido': admin[1],
                    'correo': admin[2],
                    'telefono': admin[3],
                    'direccion': admin[4]
                }
            }), 200
        else:
            return jsonify({'success': False, 'message': 'Administrador no encontrado'}), 404
    except Exception as e:
        logging.error("Error fetching admin details: %s", e)
        return jsonify({'success': False, 'message': 'Error en el servidor', 'error': str(e)}), 500
    finally:
        conn.close()

# Ruta para actualizar credenciales de un usuario
@admin_bp.route('/update_credenciales', methods=['PUT'])
def update_credenciales_route():
    data = request.get_json()
    print("Datos recibidos:", data)

    id_persona = data.get('id_persona')
    contrasena = data.get('contrasena')  
    tipo_usuario = data.get('tipo_usuario')
    nombre = data.get('nombre')
    apellido = data.get('apellido')
    correo = data.get('correo')
    telefono = data.get('telefono')
    direccion = data.get('direccion')
    
    if not all([id_persona, tipo_usuario, nombre, apellido, correo, telefono, direccion]):
        return jsonify({'success': False, 'message': 'Faltan campos obligatorios'}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        print("Actualizando credenciales y perfil para id_persona:", id_persona)

        if contrasena and contrasena.strip() != '':
            if len(contrasena) < 6:
                return jsonify({'success': False, 'message': 'La contraseña debe tener al menos 6 caracteres'}), 400
            salt = bcrypt.gensalt()
            contrasena_hash = bcrypt.hashpw(contrasena.encode('utf-8'), salt).decode('utf-8')
            cursor.execute("""
                UPDATE Credenciales
                SET contrasena_hash = ?, id_tipo_usuario = ?
                WHERE id_persona = ?
            """, (contrasena_hash, tipo_usuario, id_persona))
        else:
            cursor.execute("""
                UPDATE Credenciales
                SET id_tipo_usuario = ?
                WHERE id_persona = ?
            """, (tipo_usuario, id_persona))

        cursor.execute("""
            UPDATE Persona
            SET nombre = ?, apellido = ?, correo = ?, telefono = ?, direccion = ?
            WHERE id_persona = ?
        """, (nombre, apellido, correo, telefono, direccion, id_persona))

        conn.commit()
        return jsonify({'success': True, 'message': 'Credenciales y perfil actualizados correctamente'}), 200

    except Exception as e:
        logging.error("Error updating credentials and profile: %s", e)
        return jsonify({'success': False, 'message': 'Error en el servidor', 'error': str(e)}), 500
    finally:
        conn.close()

@admin_bp.route('/delete_user/<int:id_persona>', methods=['DELETE'])
def delete_user_route(id_persona):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Eliminar registros dependientes en la tabla 'Servicio'
        cursor.execute("DELETE FROM Servicio WHERE id_cliente = ?", (id_persona,))

        # Eliminar registros dependientes en la tabla 'Ordenes'
        cursor.execute("DELETE FROM Ordenes WHERE id_cliente = ?", (id_persona,))

        # Ahora se puede eliminar la persona sin problemas
        cursor.execute("DELETE FROM Persona WHERE id_persona = ?", (id_persona,))

        conn.commit()
        return jsonify({'success': True, 'message': 'Usuario eliminado correctamente'}), 200
    except Exception as e:
        logging.error("Error deleting user: %s", e)
        return jsonify({'success': False, 'message': 'Error en el servidor', 'error': str(e)}), 500
    finally:
        conn.close()


# Ruta para obtener todos los servicios de todos los clientes
@admin_bp.route('/servicios/todos_clientes', methods=['GET'])
def get_todos_los_servicios_de_todos_los_clientes():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        query = """
            SELECT s.descripcion, s.monto, ts.nombre_tipo AS tipo
            FROM Servicio s
            JOIN Tipo_Servicio ts ON s.id_tipo_servicio = ts.id_tipo_servicio
        """
        cursor.execute(query)
        servicios = cursor.fetchall()

        results = [{'descripcion': row[0], 'monto': row[1], 'tipo': row[2]} for row in servicios]

        return jsonify({'success': True, 'servicios': results}), 200
    except Exception as e:
        logging.error("Error fetching all services: %s", e)
        return jsonify({'success': False, 'message': 'Error al obtener los servicios', 'error': str(e)}), 500
    finally:
        conn.close()

# Ruta para obtener el resumen de ventas
@admin_bp.route('/get_resumen_ventas', methods=['GET'])
def get_resumen_ventas():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        query = "SELECT * FROM Resumen_Ventas"
        cursor.execute(query)
        resumen_ventas = cursor.fetchall()

        results = [{'periodo': row[0], 'total': float(row[1])} for row in resumen_ventas]

        return jsonify({'success': True, 'resumen_ventas': results}), 200
    except Exception as e:
        logging.error("Error fetching resumen de ventas: %s", e)
        return jsonify({'success': False, 'message': 'Error al obtener resumen de ventas', 'error': str(e)}), 500
    finally:
        conn.close()

# Ruta para asignar un técnico a un servicio
@admin_bp.route('/assign_technician', methods=['POST'])
def assign_technician():
    data = request.get_json()
    id_servicio = data.get('id_servicio')
    id_tecnico = data.get('id_tecnico')

    try:
        if not id_servicio or not id_tecnico:
            return jsonify({'success': False, 'message': 'Faltan datos en la solicitud'}), 400

        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO Asignacion_Tecnico (id_tecnico, id_servicio, id_estado_tecnico)
            VALUES (?, ?, 1)  -- Se asume que "1" es el estado "Disponible"
        """, (id_tecnico, id_servicio))

        conn.commit()
        return jsonify({'success': True, 'message': 'Técnico asignado al servicio exitosamente'}), 200
    except Exception as e:
        logging.error(f"Error al asignar técnico: {e}")
        return jsonify({'success': False, 'message': f"Error: {str(e)}"}), 500
    finally:
        conn.close()

# Ruta para obtener técnicos disponibles
@admin_bp.route('/tecnicos', methods=['GET'])
def get_tecnicos():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        query = """
            SELECT DISTINCT 
                p.id_persona, 
                p.nombre, 
                p.apellido, 
                p.correo, 
                t.especialidad
            FROM 
                Persona p
            JOIN 
                Tecnico t ON p.id_persona = t.id_persona
            JOIN 
                Asignacion_Tecnico at ON t.id_persona = at.id_tecnico
            JOIN 
                Estado_Tecnico et ON at.id_estado_tecnico = et.id_estado_tecnico
            WHERE 
                et.estado_tecnico = 'Disponible';
        """
        cursor.execute(query)
        tecnicos = cursor.fetchall()

        if not tecnicos:
            return jsonify({'success': False, 'message': 'No hay técnicos disponibles'}), 404

        results = [{'id_tecnico': row[0], 'nombre': row[1], 'apellido': row[2], 'correo': row[3], 'especialidad': row[4]} for row in tecnicos]

        return jsonify({'success': True, 'tecnicos': results}), 200

    except Exception as e:
        logging.error(f"Error al obtener técnicos: {e}")
        return jsonify({'success': False, 'message': 'Error al obtener técnicos', 'error': str(e)}), 500
    finally:
        conn.close()

# Ruta para obtener servicios no asignados
@admin_bp.route('/servicios/no_asignados', methods=['GET'])
def get_servicios_no_asignados():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        query = """
            SELECT 
                s.id_servicio, 
                s.descripcion, 
                ts.nombre_tipo AS tipo_servicio, 
                tp.nombre_pago AS tipo_pago,
                s.fecha_reg AS fecha_registro
            FROM 
                Servicio s
            JOIN 
                Tipo_Servicio ts ON s.id_tipo_servicio = ts.id_tipo_servicio
            JOIN 
                Tipo_Pago tp ON s.id_tipo_pago = tp.id_tipo_pago
            LEFT JOIN 
                Asignacion_Tecnico at ON s.id_servicio = at.id_servicio
            WHERE 
                at.id_servicio IS NULL;
        """
        cursor.execute(query)
        servicios_no_asignados = cursor.fetchall()

        if not servicios_no_asignados:
            return jsonify({'success': True, 'servicios_no_asignados': []}), 200

        results = [{'id_servicio': row[0], 'descripcion': row[1], 'tipo_servicio': row[2], 'tipo_pago': row[3], 'fecha_registro': row[4].strftime("%Y-%m-%d %H:%M:%S")} for row in servicios_no_asignados]

        return jsonify({'success': True, 'servicios_no_asignados': results}), 200

    except Exception as e:
        logging.error("Error fetching unassigned services: %s", e)
        return jsonify({'success': False, 'message': 'Error al obtener los servicios no asignados', 'error': str(e)}), 500
    finally:
        conn.close()

# Ruta para enviar notificaciones
@admin_bp.route('/send_notification', methods=['POST'])
def send_notification_route():
    data = request.get_json()
    id_cliente = data.get('id_cliente')
    id_tecnico = data.get('id_tecnico')
    id_administrador = data.get('id_administrador')
    titulo = data.get('titulo')
    mensaje = data.get('mensaje')

    if not ((id_cliente or id_tecnico) and titulo and mensaje):
        return jsonify({'success': False, 'message': 'Faltan campos obligatorios'}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO Notificaciones (id_cliente, id_administrador, id_tecnico, titulo, mensaje)
            VALUES (?, ?, ?, ?, ?);
        """, (id_cliente, id_administrador, id_tecnico, titulo, mensaje))

        conn.commit()
        return jsonify({'success': True, 'message': 'Notificación enviada correctamente'}), 200

    except Exception as e:
        logging.error("Error sending notification: %s", e)
        return jsonify({'success': False, 'message': 'Error en el servidor', 'error': str(e)}), 500
    finally:
        conn.close()
