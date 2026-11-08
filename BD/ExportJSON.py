import json
import os
from pymongo import MongoClient

uri = "mongodb://mongo1:30001,mongo2:30002,mongo3:30003/?replicaSet=rs0"
mongo_client = MongoClient(uri)
db_mongo = mongo_client["salud_usm"]

carpeta_json = 'JSON'
os.makedirs(carpeta_json, exist_ok=True)

colecciones = db_mongo.list_collection_names()
for col in colecciones:
    datos = list(db_mongo[col].find({}, {'_id': 0}))
    ruta = os.path.join(carpeta_json, f"{col}.json")
    with open(ruta, 'w', encoding='utf-8') as f:
        json.dump(datos, f, ensure_ascii=False, indent=4, default=str)
    print(f"Exportado correctamente: {col}.json ({len(datos)} documentos)")
print("Exportación completa de todas las colecciones a carpeta JSON.")
