# Tarea3-MongoDB-SaludUSM

Nombre: Pablo Andres Rodriguez Gonzalez
ROL: 202430541-7
Nombre: Lukas Ignacio Labrin Salazar
ROL: 202473624-8

# Descripción
Esta tarea implementa el sistema de gestión clinica SaludUSM utlizando MongoDB bajo una arquitectura distribuida (Replica Set) sobre contenedores de Docker. Los datos fueron migrados desde una base de datos MySQL relacional a un modelo orientado a documentos utilizando Python y Jupiter Notebook
# Estructura
deploy-rol1-rol2.yml: Archivo Docker Compose para desplegar el clúster de 3 nodos.

pymongo-rol1-rol2.ipynb: Jupyter Notebook con la migración, consultas y pruebas de replicación.

JSON/: Carpeta con los respaldos .json de las colecciones resultantes.

PDF/: Carpeta con el informe técnico y el modelo documental.

BD/: Carpeta con el script de origen MySQL (saludusm.sql o script_BD.sql) y los scripts .py de migración y exportación aislados.

README.md: Este archivo de instrucciones.
# Requisitos
1- Docker Desktop (Docker y Docker Compose) instalados y ejecutandose en segundo plano
2- Python 3 con las librerias importadas pymongo y mysql-connector-python
3- Servidor MySQL ejecutandose localmente (utilizando XAMPP) con la base de datos saludusm perteneciente a la Tarea 2
4- Archivo Hosts modificado: pensado para que la resolución DNS local funcione y permita la tolerancia a fallos del clúster, se debe agregar una linea de esta manera a su archivo hosts (C:\Windows\System32\drivers\etc\hosts en Windows, o /etc/hosts en Linux/Mac):
127.0.0.1 mongo1 mongo2 mongo3

(se recomienda abrir host con bloc de notas ejecutado como administrador para agregar la linea)

Instrucciones de ejecución
Paso 1: Desplegar el clúster de MongoDB
Abrir una terminal en la carpeta del proyecto.

Ejecutar:

text
docker-compose -f deploy-rol1-rol2.yml up -d

Verificar que los 3 contenedores estén corriendo:

text
docker ps
Deben aparecer mongo1, mongo2 y mongo3 con estado Up.

Inicializar el Replica Set. Ejecutar:

text
docker exec -it mongo1 mongosh --eval "rs.initiate({_id: 'rs0', members: [{_id: 0, host: '192.168.1.8:30001'}, {_id: 1, host: '192.168.1.8:30002'}, {_id: 2, host: '192.168.1.8:30003'}]})"
Nota: Reemplazar 192.168.1.8 por la dirección IP local de la máquina donde se ejecuta Docker. Obtenerla con ipconfig en Windows (adaptador Ethernet) o ifconfig en Linux/Mac.

Verificar que el Replica Set esté activo:

text
docker exec -it mongo1 mongosh --eval "rs.status()"
Debe mostrar un nodo PRIMARY y dos SECONDARY.

Paso 2: Configurar la conexión en el notebook
Abrir pymongo-rol1-rol2.ipynb en Jupyter Notebook.

En la primera celda, ajustar las credenciales de MySQL si es necesario (host, user, password, database).

Ajustar la IP en la URI de MongoDB si la IP local cambió:

python
uri = "mongodb://192.168.1.8:30001,192.168.1.8:30002,192.168.1.8:30003/?replicaSet=rs0"
Ejecutar la celda. Debe mostrar el primario y los nodos del Replica Set.

Paso 3: Ejecutar el notebook en orden
El notebook está dividido en las siguientes secciones, que deben ejecutarse secuencialmente:

Inicialización de datos: Limpia las bases de datos e inserta catálogos, pacientes, médicos y citas de prueba en MongoDB y MySQL.

Migración desde MySQL (opcional): Si se desea migrar datos desde MySQL a MongoDB, ejecutar la celda de migración. Los datos ya están sincronizados por la celda de inicialización, pero esta sección demuestra el proceso de migración.

Consultas (a-e): Cada consulta tiene una celda para MongoDB y otra para SQL. Ejecutar ambas para comparar resultados.

Replicación y alta disponibilidad:

Ejecutar la celda de estado y consistencia.

Detener el contenedor primario con docker stop mongo1.

Esperar 15 segundos y ejecutar la celda de alta disponibilidad.

Levantar el contenedor con docker start mongo1.

Esperar 20 segundos y ejecutar la celda de verificación de reintegración.

Exportación a JSON: Exporta todas las colecciones a la carpeta JSON/.

Paso 4: Verificar los archivos generados
La carpeta JSON/ debe contener un archivo .json por cada colección (cita.json, centro_medico.json, especialidad.json, estado_cita.json, medico.json, paciente.json, prevision.json).

El notebook debe estar ejecutado y mostrar las salidas de todas las consultas y pruebas de replicación.
