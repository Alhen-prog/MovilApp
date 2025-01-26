import pyodbc
import bcrypt

def get_db_connection():
    conn = pyodbc.connect(
        'DRIVER={SQL Server};SERVER=DESKTOP-L1FODQ5\\SQLEXPRESS;DATABASE=servicio;Trusted_Connection=yes;'
    )
    return conn

def hash_passwords():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id_credencial, contrasena_hash FROM Credenciales")
    rows = cursor.fetchall()

    for row in rows:
        id_credencial = row[0]
        contrasena = row[1]  
    
        salt = bcrypt.gensalt()
        contrasena_hash = bcrypt.hashpw(contrasena.encode('utf-8'), salt).decode('utf-8')
        cursor.execute("""
            UPDATE Credenciales
            SET contrasena_hash = ?
            WHERE id_credencial = ?
        """, (contrasena_hash, id_credencial))
    
    conn.commit()
    conn.close()
    print("Contraseñas hasheadas correctamente.")

if __name__ == "__main__":
    hash_passwords()
