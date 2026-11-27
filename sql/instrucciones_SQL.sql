DROP TABLE IF EXISTS imparticion, pertenencia, participacion, profesor, alumno, promocion, proyecto, rol, modalidad, campus CASCADE;

CREATE TABLE IF NOT EXISTS campus (
    cod_campus INT NOT NULL,
    nombre VARCHAR(30) NOT NULL,
    CONSTRAINT pk_campus PRIMARY KEY (cod_campus)
);

CREATE TABLE IF NOT EXISTS modalidad (
    cod_modalidad INT NOT NULL,
    nombre VARCHAR(30) NOT NULL,
    CONSTRAINT pk_modalidad PRIMARY KEY (cod_modalidad)
);

CREATE TABLE IF NOT EXISTS rol (
    cod_rol INT NOT NULL,
    nombre VARCHAR(30) NOT NULL,
    CONSTRAINT pk_rol PRIMARY KEY (cod_rol)
);

CREATE TABLE IF NOT EXISTS proyecto (
    cod_proyecto INT NOT NULL,
    vertical VARCHAR(30) NOT NULL,
    nombre VARCHAR(30) NOT NULL,
    CONSTRAINT pk_proyecto PRIMARY KEY (cod_proyecto)
);

CREATE TABLE IF NOT EXISTS promocion (
    cod_promocion INT NOT NULL,
    fecha_comienzo DATE NOT NULL,
    cod_campus INT NOT NULL,
    CONSTRAINT pk_promocion PRIMARY KEY (cod_promocion),
    CONSTRAINT fk_promocion_campus FOREIGN KEY (cod_campus) REFERENCES campus (cod_campus)
);

CREATE TABLE IF NOT EXISTS alumno (
    cod_alumno INT NOT NULL,
    nombre VARCHAR(30) NOT NULL,
    email VARCHAR(30) NOT NULL,
    cod_promocion INT NOT NULL,
    CONSTRAINT pk_alumno PRIMARY KEY (cod_alumno),
    CONSTRAINT fk_alumno_promocion FOREIGN KEY (cod_promocion) REFERENCES promocion (cod_promocion)
);

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

CREATE TABLE IF NOT EXISTS participacion (
    nota REAL NOT NULL,
    cod_alumno INT NOT NULL,
    cod_proyecto INT NOT NULL,
    CONSTRAINT pk_participacion PRIMARY KEY (cod_alumno, cod_proyecto),
    CONSTRAINT fk_participacion_alumno FOREIGN KEY (cod_alumno) REFERENCES alumno (cod_alumno),
    CONSTRAINT fk_participacion_proyecto FOREIGN KEY (cod_proyecto) REFERENCES proyecto (cod_proyecto)
);

CREATE TABLE IF NOT EXISTS pertenencia (
    cod_profesor INT NOT NULL,
    cod_rol INT NOT NULL,
    CONSTRAINT pk_pertenencia PRIMARY KEY (cod_profesor, cod_rol),
    CONSTRAINT fk_pertenencia_profesor FOREIGN KEY (cod_profesor) REFERENCES profesor (cod_profesor),
    CONSTRAINT fk_pertenencia_rol FOREIGN KEY (cod_rol) REFERENCES rol (cod_rol)
);

CREATE TABLE IF NOT EXISTS imparticion (
    cod_profesor INT NOT NULL,
    cod_modalidad INT NOT NULL,
    CONSTRAINT pk_imparticion PRIMARY KEY (cod_profesor, cod_modalidad),
    CONSTRAINT fk_imparticion_profesor FOREIGN KEY (cod_profesor) REFERENCES profesor (cod_profesor),
    CONSTRAINT fk_imparticipacion_modalidad FOREIGN KEY (cod_modalidad) REFERENCES modalidad (cod_modalidad)
);
