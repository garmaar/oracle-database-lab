SET LINESIZE 200 PAGESIZE 100
WHENEVER SQLERROR EXIT FAILURE
ALTER SESSION SET CONTAINER=FREEPDB1;
SELECT force_matching_signature,COUNT(DISTINCT sql_id) AS textos_distintos,
       COUNT(*) AS cursores,SUM(executions) AS ejecuciones,
       MIN(SUBSTR(sql_text,1,110)) AS ejemplo
  FROM v$sql
 WHERE force_matching_signature<>0
 GROUP BY force_matching_signature
HAVING COUNT(DISTINCT sql_id)>50
 ORDER BY textos_distintos DESC;
EXIT
