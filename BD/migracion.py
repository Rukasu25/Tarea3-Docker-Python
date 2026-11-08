import mysql.connector
from pymongo import MongoClient
import datetime

#aqui se hace la conexión con MYSQL
mysql_conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",
    database ="saludusm")

mysql_cursor = mysql_conn.cursor(dictionary=True)

uri = "mongodb://mongo1:30001,mongo2:30002,mongo3:30003/?replicaSet=rs0"
mongo_client = MongoClient(uri, serverSelectionTimeoutMS=5000)
db_mongo = mongo_client["saludusm"]

def convertir_fechas(doc):
    #convierte objetos datetime de MySQL a formato ISO para JSON/MongoDB

    if isinstance(doc, dict):
        return {k: convertir_fechas(v) for k, v in doc.items()}
    elif isinstance(doc, list):
        return [convertir_fechas(item) for item in doc]
    elif isinstance(doc, datetime.datetime):
        return doc.isoformat()
    else:
        return doc

#aqui se migran catalogos
catalogos = ['prevision', 'especialidad', 'estado_cita', 'centro_medico']
for tabla in catalogos:
    #reconexion en caso de que XAMPP se caiga
    mysql_conn.reconnect(attempts=3, delay=2)

    mysql_cursor.execute(f"SELECT * FROM {tabla}")
    datos = mysql_cursor.fetchall()
    if datos:
        db_mongo[tabla].drop()
        datos_clear = [convertir_fechas(d) for d in datos]
        db_mongo[tabla].insert_many(datos_clear)
        print(f"Migrados {len(datos)} registros a '{tabla}'.")

#aqui se migran los pacientes y medicos
mysql_conn.reconnect(attempts=3, delay=2)
mysql_cursor.execute("""
    SELECT p.id_paciente, u.rut, u.nombre, u.apellido, u.email, u.telefono, u.sexo, p.id_prevision
    FROM paciente p
    JOIN usuario u ON p.email=u.email
""")
pacientes = mysql_cursor.fetchall()
if pacientes:
    db_mongo.paciente.drop()
    pacientes_limpios = [convertir_fechas(p) for p in pacientes]
    db_mongo.paciente.insert_many(pacientes_limpios)
    print(f"Migrados {len(pacientes)} pacientes.")
mysql_conn.reconnect(attempts=3, delay=2)
mysql_cursor.execute("""
    SELECT m.id_medico, u.rut, u.nombre, u.apellido, u.email, u.telefono, u.sexo
    FROM medico m
    JOIN usuario u ON m.email=u.email
""")
medicos = mysql_cursor.fetchall()

for m in medicos:
    mysql_cursor.execute(
        f"SELECT id_especialidad FROM medico_especialidad WHERE id_medico = {m ['id_medico']}"
    )
    m['id_especialidades'] = [e['id_especialidad'] for e in mysql_cursor.fetchall()]

if medicos:
    db_mongo.medico.drop()
    medicos_limpios = [convertir_fechas(m) for m in medicos]
    db_mongo.medico.insert_many(medicos_limpios)
    print(f"Migrados {len(medicos)} médicos.")


#aqui se migran citas, atenciones, diagnosticos y recetas anidadas

mysql_conn.reconnect(attempts=3, delay=2)
mysql_cursor.execute("SELECT * FROM cita")
citas = mysql_cursor.fetchall()
for c in citas:
    mysql_cursor.execute(
        f"SELECT id_atencion, motivo, observaciones FROM atencion WHERE id_cita = {c['id_cita']}"
    )
    atencion = mysql_cursor.fetchone()
    if atencion:
        #diagnostico ojojo
        mysql_cursor.execute(f"""
        SELECT d.codigo_cie10, d.descripcion)
        FROM diagnostico_atencion da
        JOIN diagnostico d ON da.id_diagnostico = d.id_diagnostico
        WHERE da.id_atencion = {atencion['id_atencion']}
        """)
        atencion['diagnosticos'] = mysql_cursor.fetchall()

        #recectas
        mysql_cursor.execute(f"""
        SELECT m.nombre as medicamente, r.dosis, r.dias_tratamiento
        FROM receta_linea r
        JOIN medicamento m ON r.id_medicamente = m.id_medicamento
        WHERE r.id_atencion = {atencion['id_atencion']}
        """)
        atencion['recetas'] = mysql_cursor.fetchall()
        c['atencion'] = atencion
    if citas:
        db_mongo.cita.drop()
        citas_limpias = [convertir_fechas(c) for c in citas]
        db_mongo.cita.insert_many(citas_limpias)
        print(f"Migradas {len(citas)} citas con atenciones anidadas")
    print("Migración completada!")
    mysql_cursor.close()
    mysql_conn.close()
