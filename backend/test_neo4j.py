from neo4j import GraphDatabase

uri = "neo4j+s://99eec5fe.databases.neo4j.io"
user = "neo4j"
password = "hO3FImHhBvnpmLSjTkcNZtrYOART97quDo856bVViMA"

try:
    driver = GraphDatabase.driver(uri, auth=(user, password))
    with driver.session() as session:
        result = session.run("RETURN 1")
        print("Conexión exitosa:", result.single()[0])
except Exception as e:
    print("Error conectando a Neo4j:", e)
