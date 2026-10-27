WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 220 PAGESIZE 100
SELECT name,open_mode,log_mode,current_scn FROM v$database;
SELECT name,open_mode FROM v$pdbs;
SELECT COUNT(*) AS cabeceras_con_error FROM v$datafile_header WHERE error IS NOT NULL;
ALTER SESSION SET CONTAINER=FREEPDB1;
SELECT estado,COUNT(*) AS estudiantes FROM admin_academia.aca_estudiantes GROUP BY estado ORDER BY estado;
SELECT COUNT(*) AS usuarios_prueba FROM dba_users WHERE username='LAB5_PRUEBAS';
SELECT COUNT(*) AS segmentos_prueba FROM dba_segments WHERE owner='LAB5_PRUEBAS';
SELECT COUNT(*) AS indices_invalidos FROM dba_indexes WHERE owner='TIENDASUR' AND status NOT IN ('VALID','N/A');
EXIT
