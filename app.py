
import json
import os

from flask import Flask, request, jsonify
from flask_cors import CORS
USUARIOS_FILE = "usuarios.json"



app = Flask(__name__)
CORS(app)


from neo4j import GraphDatabase

NEO4J_URI = "neo4j+s://99eec5fe.databases.neo4j.io"  
NEO4J_USER = "neo4j"
NEO4J_PASSWORD = "hO3FImHhBvnpmLSjTkcNZtrYOART97quDo856bVViMA"

driver = GraphDatabase.driver(
    NEO4J_URI,
    auth=(NEO4J_USER, NEO4J_PASSWORD),
    
)
try:
    with driver.session() as session:
        session.run("RETURN 1")
    print("✅ Conectado a Neo4j correctamente.")
except Exception as e:
    print("❌ Error de conexión a Neo4j:", e)


@app.route('/')
def home():
    return "Bienvendido al sistema de recomendacion de comidas :) "

@app.route('/registro', methods=['POST'])
def registro():
    datos = request.get_json()
    usuario = datos.get("usuario")
    password = datos.get("password")
    rol = datos.get("rol", "usuario")  # por defecto es usuario

    if not usuario or not password:
        return jsonify({"error": "usuario y password son requeridos"}), 400

    # Leer usuarios existentes
    if os.path.exists(USUARIOS_FILE):
        with open(USUARIOS_FILE, "r") as f:
            usuarios = json.load(f)
    else:
        usuarios = {}

    if usuario in usuarios:
        return jsonify({"error": "El usuario ya existe"}), 409

    # Guardar nuevo usuario (sin encriptar, ya que es proyecto de clase)
    usuarios[usuario] = {
        "password": password,
        "rol": rol
    }

    with open(USUARIOS_FILE, "w") as f:
        json.dump(usuarios, f, indent=4)

    return jsonify({"mensaje": f"Usuario {usuario} registrado correctamente."})


@app.route('/login', methods=['POST'])
def login():
    datos = request.get_json()
    usuario = datos.get("usuario")
    password = datos.get("password")

    if not usuario or not password:
        return jsonify({"error": "usuario y password son requeridos"}), 400

    if os.path.exists(USUARIOS_FILE):
        with open(USUARIOS_FILE, "r") as f:
            usuarios = json.load(f)
    else:
        return jsonify({"error": "No hay usuarios registrados"}), 404

    user_data = usuarios.get(usuario)

    if not user_data or user_data["password"] != password:
        return jsonify({"error": "Usuario o contraseña incorrectos"}), 401

    return jsonify({"mensaje": "Login exitoso", "rol": user_data["rol"]})


@app.route('/perfil')
def perfil():
    usuario = request.args.get("usuario")

    if not usuario:
        return jsonify({"error": "Se requiere el nombre de usuario"}), 400

    if os.path.exists(USUARIOS_FILE):
        with open(USUARIOS_FILE, "r") as f:
            usuarios = json.load(f)
    else:
        return jsonify({"error": "No hay usuarios registrados"}), 404

    user_data = usuarios.get(usuario)

    if not user_data:
        return jsonify({"error": "Usuario no encontrado"}), 404

    return jsonify({"usuario": usuario, "rol": user_data["rol"]})



@app.route('/recomendar')
def recomendar():
    usuario = request.args.get('usuario')
    if not usuario:
        return jsonify({"error": "Falta el parámetro 'usuario'"}), 400

    # Consulta 1: Platos que le gustan al usuario
    query_gustos = """
    MATCH (u:Usuario {nombre: $nombre})-[:GUSTA]->(p:Plato)
    RETURN p.nombre
    """
    gustos = consultar_neo4j(query_gustos, {"nombre": usuario})

    # Si no hay gustos registrados, sugerencias generales
    print("Gustos encontrados para", usuario, ":", gustos)

    if not gustos:
        query_sugerencias = """
        MATCH (p:Plato)
        RETURN p.nombre
        LIMIT 5
        """
        sugerencias = consultar_neo4j(query_sugerencias)
        return jsonify({
            "usuario": usuario,
            "recomendaciones": sugerencias,
            "nota": "No se encontraron gustos guardados, se muestran platos generales."
        })

    # Consulta 2: Recomendar otros platos del mismo tipo
    query_recomendaciones = """
    MATCH (u:Usuario {nombre: $nombre})-[:GUSTA]->(p1:Plato),
        (p2:Plato)
    WHERE p1.tipo = p2.tipo AND NOT (u)-[:GUSTA]->(p2)
    RETURN DISTINCT p2.nombre
    """
    recomendaciones = consultar_neo4j(query_recomendaciones, {"nombre": usuario})

    # ✅ Aquí va tu print
    print("Recomendaciones finales para", usuario, ":", recomendaciones)

    # Respuesta final
    return jsonify({
        "usuario": usuario,
        "gustos": gustos,
        "recomendaciones": recomendaciones or ["No hay nuevas recomendaciones por categoría"],
        "nota": "Recomendaciones generadas por categoría de gustos." if recomendaciones else "No hay recomendaciones adicionales."
    })
            
    

@app.route('/saludables')
def comidas_saludables():
    query = """
    MATCH (p:Plato)
    WHERE p.saludable = "true"
    RETURN p.nombre
    """
    try:
        resultados = consultar_neo4j(query)
        return jsonify({
            "comidas_saludables": resultados
        })
    except Exception as e:
        return jsonify({
            "error": "No se pudo conectar a Neo4j",
            "detalle": str(e)
        }), 500


@app.route('/categoria/<nombre>')
def comidas_por_categoria(nombre):
    query = """
    MATCH (p:Plato)
    WHERE toLower(p.tipo) = toLower($tipo)
    RETURN p.nombre
    """
    try:
        resultados = consultar_neo4j(query, {"tipo": nombre})
        if resultados:
            return jsonify({
                "categoria": nombre,
                "comidas": resultados
            })
        else:
            return jsonify({
                "mensaje": f"No se encontraron comidas en la categoría '{nombre}'"
            }), 404
    except Exception as e:
        return jsonify({
            "error": "No se pudo conectar a Neo4j",
            "detalle": str(e)
        }), 500
        
@app.route('/ingredientes/<plato>')
def ingredientes_de_plato(plato):
    query = """
    MATCH (p:Plato {nombre: $nombre})-[:TIENE]->(i:Ingrediente)
    RETURN i.nombre
    """
    try:
        resultados = consultar_neo4j(query, {"nombre": plato})
        if resultados:
            return jsonify({
                "plato": plato,
                "ingredientes": resultados
            })
        else:
            return jsonify({
                "mensaje": f"No se encontraron ingredientes para el plato '{plato}'"
            }), 404
    except Exception as e:
        return jsonify({
            "error": "No se pudo conectar a Neo4j",
            "detalle": str(e)
        }), 500





@app.route('/gustos', methods=['GET'])
def obtener_gustos():
    usuario = request.args.get('usuario')

    if os.path.exists("gustos.json"):
        with open("gustos.json", 'r') as f:
            db = json.load(f)
    else:
        db = {}

    if usuario:
        gustos = db.get(usuario)
        if gustos:
            return jsonify({usuario: gustos})
        else:
            return jsonify({"mensaje": f"No se encontraron gustos para {usuario}"}), 404
    else:
        return jsonify(db)

def consultar_neo4j(query, params=None):
    with driver.session() as session:
        result = session.run(query, params or {})
        return [record.values()[0] for record in result]
    
if __name__ == "__main__":
    app.run(debug=True)