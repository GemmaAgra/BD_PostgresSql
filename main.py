# Para la creación de los DataFrames
import pandas as pd
# Para interación con la Base de Datos
import psycopg2

#########################################################################################################
#                                                 DATAFRAMES
#########################################################################################################

df_campus = pd.DataFrame({
    'cod_campus': [1, 2],
    'nombre': ['Madrid', 'Valencia'],
})

df_modalidad = pd.DataFrame({
    'cod_modalidad': [1, 2],
    'nombre': ['Presencial', 'Online'],
})

df_rol = pd.DataFrame({
    'cod_rol': [1, 2],
    'nombre': ['TA', 'LI'],
})

# Diccionario que relaciona cada código con su nombre
# zip: Empareja elemento a elemento ambas columnas en orden
diccionario_campus = dict(zip(df_campus['nombre'], df_campus['cod_campus']))
diccionario_modalidad = dict(zip(df_modalidad['nombre'], df_modalidad['cod_modalidad']))
diccionario_rol = dict(zip(df_rol['nombre'], df_rol['cod_rol']))

# CLASES Y CLAUSTRO

clases_config = [
    ("data/clase_1.csv", 'DS'),
    ("data/clase_2.csv", 'DS'),
    ("data/clase_3.csv", 'FS'),
    ("data/clase_4.csv", 'FS'),
]

dfs_clases = []
proyectos_vertical = {}

for archivo, vertical in clases_config:
    df_clase = pd.read_csv(archivo, sep=';')
    if 'Promoción' in df_clase.columns and 'Promocion' not in df_clase.columns:
        df_clase = df_clase.rename(columns={'Promoción':'Promocion'})
    cols_proy = [c for c in df_clase.columns if c.startswith('Proyecto_')]
    for col_p in cols_proy:
        proyectos_vertical[col_p] = vertical
    dfs_clases.append(df_clase)


df_all_alumnos = pd.concat(dfs_clases, ignore_index=True)
df_claustro = pd.read_csv('data/claustro.csv', sep=';')

# PROMOCION

proms = (
    df_all_alumnos[['Promocion', "Fecha_comienzo", 'Campus']]
    .drop_duplicates()
    .reset_index(drop=True)
)
proms['cod_promocion'] = range(1, len(proms)+1)
proms["fecha_comienzo"] = pd.to_datetime(
    proms["Fecha_comienzo"], format="%d/%m/%Y"
).dt.date
proms['cod_campus'] = proms['Campus'].map(diccionario_campus)

df_promocion = proms[['cod_promocion', "fecha_comienzo", 'cod_campus']]

diccionario_promo_campus = {
    (row['Promocion'], row['Campus']): row['cod_promocion']
    for _, row in proms.iterrows()
}
diccionario_promo_nombre = proms.groupby("Promocion")["cod_promocion"].first().to_dict()

# ALUMNO

alumnos_info = (
    df_all_alumnos[['Nombre', 'Email', 'Promocion', 'Campus']].drop_duplicates().reset_index(drop=True)
)
alumnos_info['cod_alumno'] = range(1, len(alumnos_info)+1)
alumnos_info['cod_promocion'] = [
    diccionario_promo_campus.get(
        (r['Promocion'], r['Campus']), diccionario_promo_nombre.get(r['Promocion'])
    )
    for _, r in alumnos_info.iterrows()
]

df_alumno = alumnos_info[['cod_alumno', 'Nombre', 'Email', 'cod_promocion']].rename(
    columns={
        'Nombre':'nombre',
        'Email': 'email'
    }
)

# PROYECTO

lista_proyectos = list(proyectos_vertical.keys())
df_proyecto = pd.DataFrame({
    'cod_proyecto': range(1, len(lista_proyectos)+1),
    'vertical': [proyectos_vertical[p] for p in lista_proyectos],
    'nombre': lista_proyectos,
})

# PARTICIPACION

diccionario_nota = {'Apto': 1.0, 'No Apto': 0.0}

# melt(): tranforma de columnas a registros
# subset: elimina las filas nulas
df_long = df_all_alumnos.melt(
    id_vars=['Nombre', 'Email'],
    value_vars=lista_proyectos,
    var_name='nombre_proyecto',
    value_name='calificacion'
).dropna(subset=['calificacion'])

df_long['nota'] = df_long['calificacion'].map(diccionario_nota).astype(float)

df_participacion = (
    df_long.merge(
        df_alumno[['cod_alumno', 'nombre', 'email']],
        left_on = ["Nombre", 'Email'],
        right_on = ["nombre", 'email'],
        how='inner',
    ).merge(
        df_proyecto[['cod_proyecto', 'nombre']],
        left_on = 'nombre_proyecto',
        right_on = 'nombre',
        how = 'inner'
    )[['nota', 'cod_alumno', 'cod_proyecto']].reset_index(drop=True)
)

# PROFESOR

profesores_info = (
    df_claustro[['Nombre', 'Vertical', 'Promocion', 'Campus', 'Modalidad']].drop_duplicates().reset_index(drop=True)
)
profesores_info['cod_profesor'] = range(1, len(profesores_info)+1)
profesores_info['cod_promocion'] = [
    diccionario_promo_campus.get((r['Promocion'], r['Campus']), diccionario_promo_nombre.get(r['Promocion']))
    for _, r in profesores_info.iterrows()
]
profesores_info['cod_campus'] = profesores_info['Campus'].map(diccionario_campus)
profesores_info['cod_modalidad'] = profesores_info['Modalidad'].map(diccionario_modalidad)

df_profesor = profesores_info[[
    'cod_profesor',
    'Nombre',
    'Vertical',
    'cod_promocion',
    'cod_campus',
    'cod_modalidad',
]].rename(columns={'Nombre':'nombre', 'Vertical':'vertical'})

# PERTENENCIA

df_pertenencia = (
    df_claustro[['Nombre', 'Rol']]
    .drop_duplicates()
    .merge(profesores_info[['cod_profesor', 'Nombre']], on='Nombre', how='inner')
    .assign(cod_rol=lambda d: d['Rol'].map(diccionario_rol))[['cod_profesor', 'cod_rol']]
    .drop_duplicates()
    .reset_index(drop=True)
)

# IMPARTICION
# lambda parametros:return : Función anónima para operaciones rápidas y sencillas sin tener que crear una función.
df_imparticion = (
    df_claustro[['Nombre', 'Modalidad']]
    .drop_duplicates()
    .merge(profesores_info[['cod_profesor', 'Nombre']], on='Nombre', how='inner')
    .assign(cod_modalidad=lambda d: d['Modalidad'].map(diccionario_modalidad))[['cod_profesor', 'cod_modalidad']]
    .drop_duplicates()
    .reset_index(drop=True)
)


#########################################################################################################
#                                                 BASES DE DATOS
#########################################################################################################

# isoformat: transforma la fecha en texto entre ''
def crear_insercion(df:pd.DataFrame, nombre_tabla:str) -> list[str]:
    cols = ", ".join(df.columns)
    sentencias = []
    for _, fila in df.iterrows():
        valores = []
        for val in fila:
            if pd.isna(val):
                valores.append('NULL')
            elif isinstance(val, str):
                val_escapado = val.replace("'", "''")
                valores.append(f"'{val_escapado}'")
            else:
                # Sirve para int, float, datetime.date
                valores.append(f"'{val}'" if hasattr(val, "isoformat") else f"{val}")
        sentencias.append(
            f"INSERT INTO {nombre_tabla} ({cols}) VALUES ({', '.join(valores)});"
        )
    return sentencias

tablas_ordenadas = [
    ('campus', df_campus),
    ('modalidad', df_modalidad),
    ('rol', df_rol),
    ('proyecto', df_proyecto),
    ('promocion', df_promocion),
    ('alumno', df_alumno),
    ('profesor', df_profesor),
    ('participacion', df_participacion),
    ('pertenencia', df_pertenencia),
    ('imparticion ', df_imparticion),
]

todas_las_creaciones_tablas = [
    """
    DROP TABLE IF EXISTS imparticion, pertenencia, participacion, profesor, alumno, promocion, proyecto, rol, modalidad, campus CASCADE;
    """,
    """
    CREATE TABLE IF NOT EXISTS campus (
        cod_campus INT NOT NULL,
        nombre VARCHAR(30) NOT NULL,
        CONSTRAINT pk_campus PRIMARY KEY (cod_campus)
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS modalidad (
        cod_modalidad INT NOT NULL,
        nombre VARCHAR(30) NOT NULL,
        CONSTRAINT pk_modalidad PRIMARY KEY (cod_modalidad)
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS rol (
        cod_rol INT NOT NULL,
        nombre VARCHAR(30) NOT NULL,
        CONSTRAINT pk_rol PRIMARY KEY (cod_rol)
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS proyecto (
        cod_proyecto INT NOT NULL,
        vertical VARCHAR(30) NOT NULL,
        nombre VARCHAR(30) NOT NULL,
        CONSTRAINT pk_proyecto PRIMARY KEY (cod_proyecto)
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS promocion (
        cod_promocion INT NOT NULL,
        fecha_comienzo DATE NOT NULL,
        cod_campus INT NOT NULL,
        CONSTRAINT pk_promocion PRIMARY KEY (cod_promocion),
        CONSTRAINT fk_promocion_campus FOREIGN KEY (cod_campus) REFERENCES campus (cod_campus)
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS alumno (
        cod_alumno INT NOT NULL,
        nombre VARCHAR(30) NOT NULL,
        email VARCHAR(30) NOT NULL,
        cod_promocion INT NOT NULL,
        CONSTRAINT pk_alumno PRIMARY KEY (cod_alumno),
        CONSTRAINT fk_alumno_promocion FOREIGN KEY (cod_promocion) REFERENCES promocion (cod_promocion)
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS profesor (
        cod_profesor INT NOT NULL,
        nombre VARCHAR(30) NOT NULL,
        vertical VARCHAR(30) NOT NULL,
        cod_promocion INT NOT NULL,        
        cod_campus INT NOT NULL,
        cod_modalidad INT NOT NULL,
        CONSTRAINT pk_profesor PRIMARY KEY (cod_profesor),
        CONSTRAINT fk_profesor_promocion FOREIGN KEY (cod_promocion) REFERENCES promocion (cod_promocion),
        CONSTRAINT fk_profesor_campus FOREIGN KEY (cod_campus) REFERENCES campus (cod_campus),
        CONSTRAINT fk_profesor_modalidad FOREIGN KEY (cod_modalidad) REFERENCES modalidad (cod_modalidad)
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS participacion (
        nota REAL NOT NULL,
        cod_alumno INT NOT NULL,
        cod_proyecto INT NOT NULL,
        CONSTRAINT pk_participacion PRIMARY KEY (cod_alumno, cod_proyecto),
        CONSTRAINT fk_participacion_alumno FOREIGN KEY (cod_alumno) REFERENCES alumno (cod_alumno),
        CONSTRAINT fk_participacion_proyecto FOREIGN KEY (cod_proyecto) REFERENCES proyecto (cod_proyecto)
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS pertenencia (
        cod_profesor INT NOT NULL,
        cod_rol INT NOT NULL,
        CONSTRAINT pk_pertenencia PRIMARY KEY (cod_profesor, cod_rol),
        CONSTRAINT fk_pertenencia_profesor FOREIGN KEY (cod_profesor) REFERENCES profesor (cod_profesor),
        CONSTRAINT fk_pertenencia_rol FOREIGN KEY (cod_rol) REFERENCES rol (cod_rol)
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS imparticion (
        cod_profesor INT NOT NULL,
        cod_modalidad INT NOT NULL,
        CONSTRAINT pk_imparticion PRIMARY KEY (cod_profesor, cod_modalidad),
        CONSTRAINT fk_imparticion_profesor FOREIGN KEY (cod_profesor) REFERENCES profesor (cod_profesor),
        CONSTRAINT fk_imparticipacion_modalidad FOREIGN KEY (cod_modalidad) REFERENCES modalidad (cod_modalidad)
    );
    """,
]

todas_las_inserciones = []
for nombre_tabla, df_tabla in tablas_ordenadas:
    todas_las_inserciones.extend(crear_insercion(df_tabla, nombre_tabla))

# CONEXIÓN A POSTGRESQL

conn = psycopg2.connect(
    dbname = 'proyecto_bbdd_r1x9',
    user = 'grupo',
    password = '1GAZsrhN5Qcbr5UgAYXtz1pcMWLDIiJo',
    host = 'dpg-dc446s6c6qcc73cf3f7g-a.oregon-postgres.render.com',
    port = 5432,
)

try:
    with conn:
        with conn.cursor() as cur:
            for creacion_tabla in todas_las_creaciones_tablas:
                cur.execute(creacion_tabla)
            for insercion in todas_las_inserciones:
                cur.execute(insercion)
    print(f"Tablas creadas y {len(todas_las_inserciones)} sentencias INSERT ejecutadas correctamente.")
finally:
    conn.close()