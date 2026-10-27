WHENEVER SQLERROR EXIT FAILURE
SET SQLFORMAT DEFAULT
SET LINESIZE 220 PAGESIZE 100
COLUMN name FORMAT A100
COLUMN mensaje FORMAT A90
SELECT file#,con_id,name,error,recover FROM v$datafile_header WHERE error IS NOT NULL OR recover='YES';
SELECT file#,con_id,name FROM v$datafile WHERE file# IN (24,34);
SELECT COUNT(*) AS miembros_invalidos FROM v$logfile WHERE status IN ('INVALID','STALE');
SELECT name,open_mode FROM v$pdbs;
SELECT REGEXP_SUBSTR(message_text,'ORA-[0-9]+') AS codigo,COUNT(*) AS entradas
  FROM v$diag_alert_ext WHERE originating_timestamp>SYSTIMESTAMP-INTERVAL '1' DAY AND message_text LIKE '%ORA-%'
 GROUP BY REGEXP_SUBSTR(message_text,'ORA-[0-9]+') ORDER BY entradas DESC;
SELECT '16h, carga inicial' AS ventana,COUNT(*) AS cambios FROM v$log_history
 WHERE first_time>=DATE '2026-10-27'+16/24 AND first_time<DATE '2026-10-27'+17/24;
EXIT
