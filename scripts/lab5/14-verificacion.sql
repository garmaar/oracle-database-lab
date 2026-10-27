WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 220 PAGESIZE 100
COLUMN name FORMAT A90
SELECT name,open_mode,log_mode FROM v$database;
SELECT name,open_mode FROM v$pdbs;
SELECT file#,error,online_status FROM v$recover_file;
SELECT file#,name,error,recover FROM v$datafile_header WHERE name LIKE '%academia%';
SELECT status,input_type,output_bytes,elapsed_seconds FROM v$rman_backup_job_details ORDER BY start_time DESC FETCH FIRST 5 ROWS ONLY;
SELECT COUNT(*) AS controlfiles FROM v$controlfile;
SELECT group#,members,status FROM v$log ORDER BY group#;
SELECT name,space_limit,space_used FROM v$recovery_file_dest;
ALTER SESSION SET CONTAINER=FREEPDB1;
SELECT estudiante_id,estado FROM admin_academia.aca_estudiantes WHERE estudiante_id IN (101,102,103,104) ORDER BY estudiante_id;
SELECT (SELECT COUNT(*) FROM admin_academia.aca_matriculas) AS matriculas,(SELECT COUNT(*) FROM tiendasur.cliente) AS clientes,(SELECT COUNT(*) FROM tiendasur.pedido) AS pedidos FROM dual;
SELECT COUNT(*) AS apellidos_danados FROM tiendasur.cliente WHERE INSTR(apellidos,UNISTR('\FFFD'))>0;
SELECT owner,index_name,status FROM dba_indexes WHERE owner IN ('TIENDASUR','ADMIN_ACADEMIA') AND status NOT IN ('VALID','N/A');
DECLARE
  total NUMBER;
BEGIN
  SELECT COUNT(*) INTO total FROM admin_academia.aca_estudiantes WHERE estudiante_id IN (101,102,103,104) AND estado='ACTIVO';
  IF total<>4 THEN RAISE_APPLICATION_ERROR(-20063,'Filas de control no restauradas'); END IF;
  SELECT COUNT(*) INTO total FROM admin_academia.aca_matriculas;
  IF total<>60000 THEN RAISE_APPLICATION_ERROR(-20064,'Matrículas no recuperadas'); END IF;
END;
/
EXIT
