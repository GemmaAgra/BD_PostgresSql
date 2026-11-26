

-- =============================================
-- CREACION DE LA BASE DE DATOS
-- =============================================

-- Ejecutar esta sentencia por separado si todavía
-- no hemos creado la base de datos.
-- CREATE DATABASE bootcamp;


-- =============================================
-- 1. TABLA CAMPUS
-- =============================================

CREATE TABLE CAMPUS (
    cod_campus INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);


-- =============================================
-- 2. TABLA ROL
-- =============================================

CREATE TABLE ROL (
    cod_rol INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);


-- =============================================
-- 3. TABLA MODALIDAD
-- =============================================

CREATE TABLE MODALIDAD (
    cod_mod INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);


-- =============================================
-- 4. TABLA PROMOCION
-- =============================================

CREATE TABLE PROMOCION (
    cod_prom INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    fecha_comienzo DATE NOT NULL,
    cod_campus INT NOT NULL,

    CONSTRAINT fk_promocion_campus
        FOREIGN KEY (cod_campus)
        REFERENCES CAMPUS(cod_campus),

    CONSTRAINT uq_promocion
        UNIQUE (nombre, fecha_comienzo, cod_campus)
);


-- =============================================
-- 5. TABLA ALUMNO
-- =============================================

CREATE TABLE ALUMNO (
    cod_alumno INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    cod_promocion INT NOT NULL,

    CONSTRAINT fk_alumno_promocion
        FOREIGN KEY (cod_promocion)
        REFERENCES PROMOCION(cod_prom)
);


-- =============================================
-- 6. TABLA PROYECTO
-- =============================================

CREATE TABLE PROYECTO (
    cod_proy INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);


-- =============================================
-- 7. TABLA PROFESOR
-- =============================================

CREATE TABLE PROFESOR (
    cod_profe INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    vertical VARCHAR(100) NOT NULL,
    cod_prom INT NOT NULL,
    cod_campus INT NOT NULL,
    cod_mod INT NOT NULL,

    CONSTRAINT fk_profesor_promocion
        FOREIGN KEY (cod_prom)
        REFERENCES PROMOCION(cod_prom),

    CONSTRAINT fk_profesor_campus
        FOREIGN KEY (cod_campus)
        REFERENCES CAMPUS(cod_campus),

    CONSTRAINT fk_profesor_modalidad
        FOREIGN KEY (cod_mod)
        REFERENCES MODALIDAD(cod_mod)
);


-- =============================================
-- 8. TABLA PERTENENCIA
-- =============================================

CREATE TABLE PERTENENCIA (
    cod_rol INT,
    cod_profe INT,

    PRIMARY KEY (cod_rol, cod_profe),

    CONSTRAINT fk_pertenencia_rol
        FOREIGN KEY (cod_rol)
        REFERENCES ROL(cod_rol),

    CONSTRAINT fk_pertenencia_profesor
        FOREIGN KEY (cod_profe)
        REFERENCES PROFESOR(cod_profe)
);


-- =============================================
-- 9. TABLA PARTICIPACION
-- =============================================

CREATE TABLE PARTICIPACION (
    cod_alumno INT,
    cod_proy INT,
    resultado VARCHAR(20) NOT NULL,

    PRIMARY KEY (cod_alumno, cod_proy),

    CONSTRAINT fk_participacion_alumno
        FOREIGN KEY (cod_alumno)
        REFERENCES ALUMNO(cod_alumno),

    CONSTRAINT fk_participacion_proyecto
        FOREIGN KEY (cod_proy)
        REFERENCES PROYECTO(cod_proy),

    CONSTRAINT chk_resultado
        CHECK (resultado IN ('Apto', 'No Apto'))
);
