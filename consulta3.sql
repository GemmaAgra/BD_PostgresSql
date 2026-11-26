/* Profesores, campus, modalidad y nº de alumnos */

SELECT pr.cod_profe,pr.nombre AS profesor, pr.vertical,c.nombre AS campus, m.nombre AS modalidad, 
COUNT(DISTINCT a.cod_alumno) AS total_alumnos
FROM profesor pr
INNER JOIN campus c ON pr.cod_campus = c.cod_campus
INNER JOIN modalidad m ON pr.cod_mod = m.cod_mod
LEFT JOIN promocion p  ON pr.cod_prom = p.cod_prom
LEFT JOIN alumno a   ON p.cod_prom = a.cod_promocion
GROUP BY
    pr.cod_profe,
    pr.nombre,
    pr.vertical,
    c.nombre,
    m.nombre
ORDER BY total_alumnos DESC;