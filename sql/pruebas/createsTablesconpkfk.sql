
-- =============================================
-- TABLA CAMPUS
-- =============================================

CREATE TABLE CAMPUS (
    cod_campus INT PRIMARY KEY,
    nombre VARCHAR(100)
);


-- =============================================
-- TABLA PROMOCION
-- =============================================

CREATE TABLE PROMOCION (
    cod_prom INT PRIMARY KEY,
    fecha_comienzo DATE,
    cod_campus INT,

    FOREIGN KEY (cod_campus)
        REFERENCES CAMPUS(cod_campus)
);


-- =============================================
-- TABLA ALUMNO
-- =============================================

CREATE TABLE ALUMNO (
    cod_alumno INT PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(150),
    cod_prom INT,

    FOREIGN KEY (cod_prom)
        REFERENCES PROMOCION(cod_prom)
);


-- =============================================
-- TABLA PROYECTO
-- =============================================

CREATE TABLE PROYECTO (
    cod_proy INT PRIMARY KEY,
    nombre VARCHAR(100),
    vertical VARCHAR(100)
);


-- =============================================
-- TABLA ROL
-- =============================================

CREATE TABLE ROL (
    cod_rol INT PRIMARY KEY,
    nombre VARCHAR(100)
);


-- =============================================
-- TABLA MODALIDAD
-- =============================================

CREATE TABLE MODALIDAD (
    cod_mod INT PRIMARY KEY,
    nombre VARCHAR(100)
);


-- =============================================
-- TABLA PROFESOR
-- =============================================

CREATE TABLE PROFESOR (
    cod_profe INT PRIMARY KEY,
    nombre VARCHAR(100),
    vertical VARCHAR(100),
    cod_prom INT,
    cod_campus INT,

    FOREIGN KEY (cod_prom)
        REFERENCES PROMOCION(cod_prom),

    FOREIGN KEY (cod_campus)
        REFERENCES CAMPUS(cod_campus)
);


-- =============================================
-- TABLA PERTENENCIA
-- Relaciona PROFESOR con ROL
-- =============================================

CREATE TABLE PERTENENCIA (
    cod_rol INT,
    cod_profe INT,

    PRIMARY KEY (cod_rol, cod_profe),

    FOREIGN KEY (cod_rol)
        REFERENCES ROL(cod_rol),

    FOREIGN KEY (cod_profe)
        REFERENCES PROFESOR(cod_profe)
);


-- =============================================
-- TABLA PARTICIPACION
-- Relaciona ALUMNO con PROYECTO
-- =============================================

CREATE TABLE PARTICIPACION (
    cod_alumno INT,
    cod_proy INT,
    resultado VARCHAR(20),

    PRIMARY KEY (cod_alumno, cod_proy),

    FOREIGN KEY (cod_alumno)
        REFERENCES ALUMNO(cod_alumno),

    FOREIGN KEY (cod_proy)
        REFERENCES PROYECTO(cod_proy)
);


-- =============================================
-- TABLA IMPARTICION
-- Relaciona PROFESOR con MODALIDAD
-- =============================================

CREATE TABLE IMPARTICION (
    cod_profe INT,
    cod_mod INT,

    PRIMARY KEY (cod_profe, cod_mod),

    FOREIGN KEY (cod_profe)
        REFERENCES PROFESOR(cod_profe),

    FOREIGN KEY (cod_mod)
        REFERENCES MODALIDAD(cod_mod)
);
