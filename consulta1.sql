/* Alumnos con su promoción y campus */
SELECT a.cod_alumno, a.nombre AS alumno, a.email, p.fecha_comienzo, c.nombre AS campus
FROM alumno a
INNER JOIN promocion p ON a.cod_promocion = p.cod_prom
INNER JOIN campus c   ON p.cod_campus = c.cod_campus
ORDER BY a.nombre;