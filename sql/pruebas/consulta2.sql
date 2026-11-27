/* Nota media de cada proyecto */

SELECT pr.cod_proy,pr.nombre AS proyecto, pr.vertical, COUNT(pa.cod_alumno) AS total_alumnos,ROUND(AVG(pa.nota), 2) AS nota_media
FROM proyecto pr
LEFT JOIN participacion pa ON pr.cod_proy = pa.cod_proy
GROUP BY
    pr.cod_proy,
    pr.nombre,
    pr.vertical
ORDER BY nota_media DESC NULLS LAST;
