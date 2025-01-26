import pyodbc
import logging

def get_db_connection():
    try:
        conn = pyodbc.connect(
             'DRIVER={SQL Server};SERVER=DESKTOP-L1FODQ5\SQLEXPRESS;DATABASE=servicio;Trusted_Connection=yes;'
        )
        return conn
    except pyodbc.Error as e:
        logging.error("Error connecting to database: %s", e)
        raise
