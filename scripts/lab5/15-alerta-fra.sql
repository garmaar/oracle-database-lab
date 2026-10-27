WHENEVER SQLERROR EXIT FAILURE
SET SQLFORMAT DEFAULT
SET LINESIZE 180 PAGESIZE 100
SELECT 'FRA por encima del 85%' AS alerta,
       ROUND(100*space_used/NULLIF(space_limit,0),2) AS porcentaje,
       space_used,space_limit
  FROM v$recovery_file_dest
 WHERE space_used>0.85*space_limit
 FETCH FIRST 1 ROW ONLY;
