from flask import Blueprint, request, jsonify
from router.database.base_datos import get_db_connection
import logging

usuario_bp = Blueprint('usuario', __name__)

@usuario_bp.route('/update_profile', methods=['PUT'])
def update_profile():
    data = request.get_json()
    id_persona = data.get('id_persona')
    nombre = data.get('nombre')
    apellido = data.get('apellido')
    correo = data.get('correo')
    telefono = data.get('telefono')
    direccion = data.get('direccion')

    if not id_persona or not nombre or not apellido or not correo:
        return jsonify({'success': False, 'message': 'Faltan campos obligatorios'}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT id_persona FROM Persona WHERE correo = ? AND id_persona != ?", (correo, id_persona))
        if cursor.fetchone():
            return jsonify({'success': False, 'message': 'El correo ya está en uso por otro usuario'}), 409

        cursor.execute("""
            UPDATE Persona
            SET nombre = ?, apellido = ?, correo = ?, telefono = ?, direccion = ?
            WHERE id_persona = ?
        """, (nombre, apellido, correo, telefono, direccion, id_persona))

        conn.commit()
        return jsonify({'success': True, 'message': 'Perfil actualizado correctamente'}), 200

    except Exception as e:
        logging.error("Error updating profile: %s", e, exc_info=True)
        return jsonify({'success': False, 'message': 'Error en el servidor', 'error': str(e)}), 500
    finally:
        conn.close()


# Ruta para obtener todos los usuarios
@usuario_bp.route('/get_all_users', methods=['GET'])
def get_all_users():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        query = """
            SELECT p.id_persona, p.nombre, p.apellido, p.correo, p.telefono, p.direccion, tu.tipo AS tipo_usuario
            FROM Persona p
            JOIN Credenciales c ON p.id_persona = c.id_persona
            JOIN TiposUsuario tu ON c.id_tipo_usuario = tu.id_tipo_usuario
        """
        cursor.execute(query)
        usuarios = cursor.fetchall()

        results = [
            {
                'id_persona': row[0],
                'nombre': row[1],
                'apellido': row[2],
                'correo': row[3],
                'telefono': row[4],
                'direccion': row[5],
                'tipo_usuario': row[6]
            }
            for row in usuarios
        ]
        return jsonify({'success': True, 'usuarios': results}), 200

    except Exception as e:
        logging.error("Error fetching all users: %s", e, exc_info=True)
        return jsonify({'success': False, 'message': 'Error en el servidor', 'error': str(e)}), 500
    finally:
        conn.close()

