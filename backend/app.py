
import json
import os

from flask import Flask, request, jsonify

USUARIOS_FILE = "usuarios.json"


app = Flask(__name__)

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



comidas = {
    "pizza": {"categoria": "italiana", "saludable": False},
    "ensalada": {"categoria": "saludable", "saludable": True},
    "sushi": {"categoria": "japonesa", "saludable": True},
    "tacos": {"categoria": "mexicana", "saludable": False},
    "ramen": {"categoria": "japonesa", "saludable": False},
    "ceviche": {"categoria": "peruana", "saludable": True},
    "hamburguesa": {"categoria": "americana", "saludable": False}
}



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

   
    query_gustos = """
    MATCH (u:Usuario {nombre: $nombre})-[:GUSTA]->(c:Comida)
    RETURN c.nombre
    """
    gustos = consultar_neo4j(query_gustos, {"nombre": usuario})
    
    if not gustos:
        query_sugeridos = """
        MATCH (c:Comida)
        RETURN c.nombre
        LIMIT 5
        """
        sugerencias = consultar_neo4j(query_sugeridos)
        return jsonify({
            "usuario": usuario,
            "recomendaciones": sugerencias,
            "nota": "No se encontraron gustos guardados, se muestran platos generales."
        })
        
        
    query_recomendaciones = """
    MATCH (u:Usuario {nombre: $nombre})-[:GUSTA]->(c1:Comida),
        (c2:Comida)
    WHERE c1.categoria = c2.categoria AND NOT (u)-[:GUSTA]->(c2)
    RETURN DISTINCT c2.nombre
    """
    
    recomendaciones = consultar_neo4j(query_recomendaciones, {"nombre": usuario})
    
    return jsonify({
        "usuario": usuario,
        "gustos": gustos,
        "recomendaciones": recomendaciones or ["No hay nuevas recomendaciones por categoría"]
        
        
    })
        
   

@app.route('/saludables')
def comidas_saludables():
    saludables = [nombre for nombre, info in comidas.items() if info["saludable"]]
    return jsonify({
        "comidas_saludables": saludables
    })

@app.route('/categoria/<nombre>')
def comidas_por_categoria(nombre):
    nombre = nombre.lower()
    por_categoria = [nombre_comida for nombre_comida, info in comidas.items()
                     if info["categoria"].lower() == nombre]

    if not por_categoria:
        return jsonify({"mensaje": f"No se encontraron comidas en la categoría '{nombre}'"}), 404

    return jsonify({
        "categoria": nombre,
        "comidas": por_categoria
    })


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