from flask import Blueprint, request, jsonify
import bcrypt
import logging
import datetime
from router.database.base_datos import get_db_connection

auth_bp = Blueprint('auth', __name__)

# Ruta de registro 
@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    nombre = data.get('nombre')
    apellido = data.get('apellido')
    correo = data.get('correo')
    telefono = data.get('telefono')
    direccion = data.get('direccion')
    contrasena = data.get('contrasena')
    tipo_usuario = data.get('tipo_usuario') 

    if not all([nombre, apellido, correo, telefono, direccion, contrasena, tipo_usuario]):
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
        """, (id_persona, contrasena_hash, tipo_usuario))
        conn.commit()

        if tipo_usuario == 1:
            # Cliente
            cursor.execute("INSERT INTO Cliente (id_persona) VALUES (?)", (id_persona,))
        elif tipo_usuario == 2:
            # Administrador
            cursor.execute("""
                INSERT INTO Administrador (id_persona, cargo, fecha_contratacion)
                VALUES (?, ?, ?)
            """, (id_persona, 'Cargo Predeterminado', datetime.datetime.now()))
        elif tipo_usuario == 3:
            # Técnico
            cursor.execute("""
                INSERT INTO Tecnico (id_persona, especialidad)
                VALUES (?, ?)
            """, (id_persona, 'Especialidad Predeterminada'))

        conn.commit()
        return jsonify({'success': True, 'message': 'Usuario registrado correctamente'}), 200
    except Exception as e:
        logging.error(f"Error al registrar usuario: {e}")
        return jsonify({'success': False, 'message': 'Error al registrar usuario', 'error': str(e)}), 500
    finally:
        conn.close()

# Ruta de login (inicio de sesión)
@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    correo = data.get('email')
    contrasena = data.get('password')

    if not correo or not contrasena:
        return jsonify({'success': False, 'message': 'Faltan credenciales'}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        query = """
            SELECT c.contrasena_hash, p.id_persona, tu.tipo
            FROM Credenciales c
            JOIN Persona p ON c.id_persona = p.id_persona
            JOIN TiposUsuario tu ON c.id_tipo_usuario = tu.id_tipo_usuario
            WHERE p.correo = ?;
        """
        cursor.execute(query, (correo,))
        user = cursor.fetchone()

        if user:
            stored_password_hash = user[0]
            id_persona = user[1]
            user_role = user[2]

            if bcrypt.checkpw(contrasena.encode('utf-8'), stored_password_hash.encode('utf-8')):
                response = {'success': True, 'message': 'Inicio de sesión exitoso', 'role': user_role}

                if user_role == 'Cliente':
                    cursor.execute("SELECT id_persona FROM Cliente WHERE id_persona = ?", (id_persona,))
                    cliente = cursor.fetchone()
                    response['id_cliente'] = cliente[0] if cliente else None
                elif user_role == 'Técnico':
                    cursor.execute("SELECT id_persona FROM Tecnico WHERE id_persona = ?", (id_persona,))
                    tecnico = cursor.fetchone()
                    response['id_tecnico'] = tecnico[0] if tecnico else None

                return jsonify(response), 200
            else:
                return jsonify({'success': False, 'message': 'Contraseña incorrecta'}), 401
        else:
            return jsonify({'success': False, 'message': 'Usuario no encontrado'}), 404
    except Exception as e:
        logging.error(f"Error en el login: {e}")
        return jsonify({'success': False, 'message': 'Error del servidor', 'error': str(e)}), 500
    finally:
        conn.close()
