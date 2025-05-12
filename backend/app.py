
import json
import os

from flask import Flask, request, jsonify

USUARIOS_FILE = "usuarios.json"


app = Flask(__name__)

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

    usuario = usuario.lower()

    # Leer gustos guardados
    if os.path.exists("gustos.json"):
        with open("gustos.json", 'r') as f:
            db = json.load(f)
    else:
        db = {}

    gustos = db.get(usuario)
    if not gustos:
        return jsonify({
            "usuario": usuario,
            "recomendaciones": list(comidas.keys())[:5],
            "nota": "No se encontraron gustos guardados, se muestran platos generales."
        })

    # Obtener las categorías favoritas del usuario
    categorias = set()
    for comida in gustos:
        info = comidas.get(comida.lower())
        if info:
            categorias.add(info["categoria"])

    # Recomendar otros platos de las mismas categorías
    recomendaciones = []
    for nombre, info in comidas.items():
        if info["categoria"] in categorias and nombre not in gustos:
            recomendaciones.append(nombre)

    return jsonify({
        "usuario": usuario,
        "gustos": gustos,
        "recomendaciones": recomendaciones or ["No hay nuevas recomendaciones en categorías similares."]
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

    
if __name__ == "__main__":
    app.run(debug=True)