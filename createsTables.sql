CREATE TABLE ALUMNO (
    cod_alumno INT,
    Nombre VARCHAR(100),
    Email VARCHAR(150),
    cod_Promoción INT
);

CREATE TABLE PROMOCION (
    cod_prom INT,
    Fecha_comienzo DATE,
    cod_campus INT
);

CREATE TABLE PROYECTO (
    cod_proy INT,
    nombre VARCHAR(100),
    vertical VARCHAR(100)
);

CREATE TABLE PERTENENCIA (
    cod_rol INT,
    cod_profe INT
);

CREATE TABLE PARTICIPACION (
    cod_alumno INT,
    cod_proy INT,
    nota DECIMAL(4,2)
);

CREATE TABLE CAMPUS (
    cod_campus INT,
    nombre VARCHAR(100)
);

CREATE TABLE ROL (
    cod_rol INT,
    nombre VARCHAR(100)
);

CREATE TABLE MODALIDAD (
    cod_mod INT,
    nombre VARCHAR(100)
);

CREATE TABLE PROFESOR (
    cod_profe INT,
    nombre VARCHAR(100),
    vertical VARCHAR(100),
    cod_prom INT,
    cod_campus INT,
    cod_mod INT
);

CREATE TABLE IMPARTICION (
    cod_profe INT,
    cod_mod INT
);