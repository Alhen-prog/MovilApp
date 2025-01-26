import datetime
import bcrypt
from flask import Flask, request, jsonify
import pyodbc
from flask_cors import CORS
import logging
from router.controllers.cliente_controller import cliente_bp
from router.controllers.tecnico_controller import tecnico_bp  
from router.controllers.admin_controller import admin_bp  
from router.controllers.usuario_controller import usuario_bp  
from router.database.base_datos import get_db_connection  
from router.controllers.auth_controller import auth_bp 
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '.C:/Users/Alhen/Documents/Movil/movilapp/lib/router/')))


app = Flask(__name__)

CORS(app)

logging.basicConfig(level=logging.DEBUG)


app.register_blueprint(cliente_bp, url_prefix='/cliente')  
app.register_blueprint(tecnico_bp, url_prefix='/tecnico')  
app.register_blueprint(admin_bp, url_prefix='/admin')      
app.register_blueprint(usuario_bp, url_prefix='/usuario')  
app.register_blueprint(auth_bp, url_prefix='/auth')


@app.route('/test_connection', methods=['GET'])
def test_connection():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT 1")  
        cursor.fetchone()  
        conn.close()  
        return jsonify({'success': True, 'message': 'Conexión exitosa'}), 200
    except Exception as e:
        logging.error(f"Error al conectar a la base de datos: {e}", exc_info=True)
        return jsonify({'success': False, 'message': 'Error de conexión a la base de datos', 'error': str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000) 
