from flask import Blueprint, request, jsonify
from router.database.base_datos import get_db_connection  
import logging

tecnico_bp = Blueprint('tecnico', __name__)

@tecnico_bp.route('/servicios/tecnico/<int:id_tecnico>', methods=['GET'])
def get_servicios_tecnico(id_tecnico):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        query = """
            SELECT 
                o.id_orden, 
                s.descripcion, 
                COALESCE(m.monto, 0) AS monto, 
                o.fecha_orden, 
                e.estado AS estado_equipo,
                s.id_servicio
            FROM Ordenes o
            JOIN Servicio s ON o.id_servicio = s.id_servicio
            JOIN Estado_Equipo e ON o.id_estado_equipo = e.id_estado_equipo
            JOIN Asignacion_Tecnico at ON at.id_servicio = s.id_servicio
            LEFT JOIN Monto m ON s.id_servicio = m.id_servicio AND m.id_tecnico = at.id_tecnico
            WHERE at.id_tecnico = ?;
        """
        cursor.execute(query, (id_tecnico,))
        ordenes = cursor.fetchall()
        results = [{
            'id_orden': row[0],
            'descripcion': row[1],
            'monto': float(row[2]),
            'fecha_orden': row[3].strftime("%Y-%m-%d %H:%M:%S"),
            'estado_equipo': row[4],
            'id_servicio': row[5]
        } for row in ordenes]
        return jsonify({'success': True, 'servicios': results}), 200
    except Exception as e:
        logging.error("Error fetching servicios por tecnico: %s", e, exc_info=True)
        return jsonify({'success': False, 'message': 'Error en el servidor', 'error': str(e)}), 500
    finally:
        conn.close()


@tecnico_bp.route('/tecnico/estado', methods=['PUT'])
def update_tecnico_estado():
    data = request.get_json()
    id_tecnico = data.get('id_tecnico')
    nuevo_estado = data.get('estado')

    if not id_tecnico or not nuevo_estado:
        return jsonify({'success': False, 'message': 'Faltan campos obligatorios'}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            UPDATE Tecnico
            SET estado = ?
            WHERE id_persona = ?
        """, (nuevo_estado, id_tecnico))
        conn.commit()
        return jsonify({'success': True, 'message': 'Estado del técnico actualizado correctamente'}), 200
    except Exception as e:
        logging.error("Error updating technician status: %s", e)
        return jsonify({'success': False, 'message': 'Error en el servidor', 'error': str(e)}), 500
    finally:
        conn.close()


@tecnico_bp.route('/tecnico/details/<int:id_tecnico>', methods=['GET'])
def get_tecnico_details(id_tecnico):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        query = """
            SELECT p.nombre, p.apellido, p.correo, p.telefono, p.direccion, t.especialidad
            FROM Persona p
            JOIN Tecnico t ON p.id_persona = t.id_persona
            WHERE t.id_persona = ?;
        """
        cursor.execute(query, (id_tecnico,))
        tecnico = cursor.fetchone()
        
        if tecnico:
            return jsonify({
                'success': True,
                'tecnico': {
                    'nombre': tecnico[0],
                    'apellido': tecnico[1],
                    'correo': tecnico[2],
                    'telefono': tecnico[3],
                    'direccion': tecnico[4],
                    'especialidad': tecnico[5]
                }
            }), 200
        else:
            return jsonify({'success': False, 'message': 'Técnico no encontrado'}), 404
    except Exception as e:
        logging.error("Error fetching technician details: %s", e)
        return jsonify({'success': False, 'message': 'Error en el servidor', 'error': str(e)}), 500
    finally:
        conn.close()


@tecnico_bp.route('/api/servicios/tecnico/<int:id_tecnico>', methods=['GET'])
def obtener_servicios_por_tecnico(id_tecnico):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        query = """
        SELECT 
            s.id_servicio,
            s.descripcion,
            COALESCE(m.monto, 0) AS monto,
            e.estado AS estado_equipo,
            at.estado_asignacion,
            at.fecha_asignacion,
            o.id_orden
        FROM 
            Servicio s
        JOIN 
            Asignacion_Tecnico at ON s.id_servicio = at.id_servicio
        JOIN 
            Ordenes o ON s.id_servicio = o.id_servicio
        JOIN 
            Estado_Equipo e ON o.id_estado_equipo = e.id_estado_equipo
        LEFT JOIN 
            Monto m ON s.id_servicio = m.id_servicio AND at.id_tecnico = m.id_tecnico
        WHERE 
            at.id_tecnico = ?
        ORDER BY 
            at.fecha_asignacion DESC;
        """
        cursor.execute(query, (id_tecnico,))
        servicios = cursor.fetchall()
        result = [
            {
                "id_servicio": row[0],
                "descripcion": row[1],
                "monto": float(row[2]),
                "estado_equipo": row[3],
                "estado_asignacion": row[4],
                "fecha_asignacion": row[5].strftime("%Y-%m-%d %H:%M:%S") if row[5] else None,
                "id_orden": row[6]
            }
            for row in servicios
        ]
        return jsonify({"success": True, "servicios": result}), 200
    except Exception as e:
        logging.error("Error al obtener servicios del técnico: %s", e)
        return jsonify({"success": False, "message": str(e)}), 500
    finally:
        conn.close()


@tecnico_bp.route('/servicios/pendientes/tecnico/<int:id_tecnico>', methods=['GET'])
def get_servicios_por_aceptar(id_tecnico):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        query = """
            SELECT 
                s.id_servicio,
                s.descripcion,
                at.estado_asignacion,
                at.fecha_asignacion
            FROM Asignacion_Tecnico at
            JOIN Servicio s ON at.id_servicio = s.id_servicio
            WHERE at.id_tecnico = ? AND at.estado_asignacion = 'Por Aceptar';
        """
        cursor.execute(query, (id_tecnico,))
        servicios = cursor.fetchall()
        servicios_pendientes = [
            {
                'id_servicio': row[0],
                'descripcion': row[1],
                'estado_asignacion': row[2],
                'fecha_asignacion': row[3].strftime("%Y-%m-%d %H:%M:%S"),
            }
            for row in servicios
        ]
        return jsonify({'success': True, 'servicios_pendientes': servicios_pendientes}), 200
    except Exception as e:
        logging.error("Error al obtener servicios pendientes: %s", e)
        return jsonify({'success': False, 'message': 'Error en el servidor', 'error': str(e)}), 500
    finally:
        conn.close()


@tecnico_bp.route('/servicios/tecnico/aceptar/<int:id_tecnico>/<int:id_servicio>', methods=['POST'])
def aceptar_servicio(id_tecnico, id_servicio):
    try:
        logging.debug(f"Intentando aceptar servicio: Tecnico ID={id_tecnico}, Servicio ID={id_servicio}")
        conn = get_db_connection()
        cursor = conn.cursor()

        query_check = """
            SELECT estado_asignacion
            FROM Asignacion_Tecnico
            WHERE id_tecnico = ? AND id_servicio = ?;
        """
        cursor.execute(query_check, (id_tecnico, id_servicio))
        row = cursor.fetchone()

        if not row:
            logging.warning(f"Servicio ID={id_servicio} no encontrado o no asignado al técnico ID={id_tecnico}.")
            return jsonify({'success': False, 'message': 'Servicio no encontrado o no asignado al técnico.'}), 404

        if row[0] != 'Por Aceptar':
            logging.warning(f"Servicio ID={id_servicio} no está en estado 'Por Aceptar'.")
            return jsonify({'success': False, 'message': 'El servicio no está en estado "Por Aceptar".'}), 400

        query_update = """
            UPDATE Asignacion_Tecnico
            SET estado_asignacion = 'Aceptado', id_estado_tecnico = 2
            WHERE id_tecnico = ? AND id_servicio = ?;
        """
        cursor.execute(query_update, (id_tecnico, id_servicio))
        conn.commit()
        logging.info(f"Servicio ID={id_servicio} aceptado por técnico ID={id_tecnico}.")

        return jsonify({'success': True, 'message': 'Servicio aceptado correctamente.'}), 200
    except Exception as e:
        logging.error("Error al aceptar servicio: %s", e, exc_info=True)
        return jsonify({'success': False, 'message': 'Error en el servidor', 'error': str(e)}), 500
    finally:
        conn.close()


@tecnico_bp.route('/cambiar/ordenes/estado', methods=['PUT'])
def cambiar_orden_estado():
    data = request.get_json()
    id_orden = data.get('id_orden')
    nuevo_estado = data.get('estado')

    if not id_orden or not nuevo_estado:
        return jsonify({'success': False, 'message': 'Faltan campos obligatorios'}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT id_estado_equipo FROM Estado_Equipo WHERE estado = ?", (nuevo_estado,))
        estado_equipo = cursor.fetchone()
        if not estado_equipo:
            return jsonify({'success': False, 'message': 'Estado inválido'}), 400
        id_estado_equipo = estado_equipo[0]

        cursor.execute("""
            UPDATE Ordenes
            SET id_estado_equipo = ?
            WHERE id_orden = ?
        """, (id_estado_equipo, id_orden))
        conn.commit()

        return jsonify({'success': True, 'message': 'Estado de la orden actualizado correctamente'}), 200

    except Exception as e:
        logging.error("Error updating order status: %s", e, exc_info=True)
        return jsonify({'success': False, 'message': 'Error en el servidor', 'error': str(e)}), 500
    finally:
        conn.close()


@tecnico_bp.route('/servicio/asignar_monto', methods=['POST'])
def asignar_monto():
    
    data = request.get_json()
    id_servicio = data.get('id_servicio')
    id_tecnico = data.get('id_tecnico')
    monto = data.get('monto')

    if not id_servicio or not id_tecnico or monto is None:
        return jsonify({'success': False, 'message': 'Faltan campos obligatorios'}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT id_monto FROM Monto WHERE id_servicio = ? AND id_tecnico = ?
        """, (id_servicio, id_tecnico))
        existing_monto = cursor.fetchone()

        if existing_monto:
            cursor.execute("""
                UPDATE Monto
                SET monto = ?, fecha_asignacion = GETDATE()
                WHERE id_monto = ?
            """, (monto, existing_monto[0]))
        else:
            cursor.execute("""
                INSERT INTO Monto (id_servicio, id_tecnico, monto)
                VALUES (?, ?, ?)
            """, (id_servicio, id_tecnico, monto))

        conn.commit()
        return jsonify({'success': True, 'message': 'Monto asignado correctamente'}), 200

    except Exception as e:
        logging.error("Error assigning amount to service: %s", e)
        return jsonify({'success': False, 'message': 'Error en el servidor', 'error': str(e)}), 500
    finally:
        conn.close()
