# Tarea3-MongoDB-SaludUSM

Nombre: Pablo Andres Rodriguez Gonzalez
ROL: 202430541-7
Nombre: Lukas Ignacio Labrin Salazar
ROL: 202473624-8

# Descripción
Esta tarea implementa el sistema de gestión clinica SaludUSM utlizando MongoDB bajo una arquitectura distribuida (Replica Set) sobre contenedores de Docker. Los datos fueron migrados desde una base de datos MySQL relacional a un modelo orientado a documentos utilizando Python y Jupiter Notebook
# Estructura
deploy-[rol1]-[rol2].yml: Archivo Docker Compose para desplegar el clúster.

pymongo-[rol1]-[rol2].ipynb: Jupyter Notebook con la migración, consultas y pruebas de replicación.

JSON/: Carpeta con los respaldos .json de las colecciones resultantes.

PDF/: Carpeta con el informe técnico y modelo documental.

BD/: Carpeta con el script de origen MySQL (saludusm.sql / script_BD.sql) y los scripts .py de migración y exportación aislados.

README.md: Este archivo de instrucciones (lo estas leyendo ahora mismo).
# Requisitos
1- Docker Desktop (Docker y Docker Compose) instalados y ejecutandose en segundo plano
2- Python 3 con las librerias importadas pymongo y mysql-connector-python
3- Servidor MySQL ejecutandose localmente (utilizando XAMPP) con la base de datos saludusm perteneciente a la Tarea 2
4- Archivo Hosts modificado: pensado para que la resolución DNS local funcione y permita la tolerancia a fallos del clúster, se debe agregar una linea de esta manera a su archivo hosts (C:\Windows\System32\drivers\etc\hosts en Windows, o /etc/hosts en Linux/Mac):
127.0.0.1 mongo1 mongo2 mongo3

(se recomienda abrir host con bloc de notas ejecutado como administrador para agregar la linea)

