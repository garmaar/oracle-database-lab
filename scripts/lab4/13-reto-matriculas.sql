WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 200 PAGESIZE 100
ALTER SESSION SET CONTAINER=FREEPDB1;
SET SERVEROUTPUT ON
DECLARE
  longitud NUMBER;
  filas NUMBER;
  factor NUMBER;
BEGIN
  SELECT COUNT(*),AVG(VSIZE(matricula_id)+VSIZE(estudiante_id)+VSIZE(asignatura_id)+VSIZE(periodo)+VSIZE(fecha_matricula)+3+5)
    INTO filas,longitud FROM admin_academia.aca_matriculas;
  factor:=FLOOR((8192-96)*0.9/longitud);
  DBMS_OUTPUT.PUT_LINE('Predicción previa a DBA_TABLES: filas='||filas||' R estimado='||ROUND(longitud,2)||' bfr='||factor||' b='||CEIL(filas/factor));
END;
/
SELECT table_name,num_rows,avg_row_len,pct_free,blocks,
       CEIL(num_rows/FLOOR((8192-96)*(1-pct_free/100)/avg_row_len)) AS bloques_u3,
       ROUND(blocks*8192/1048576/150*1000,3) AS recorrido_hdd_ms
  FROM dba_tables WHERE owner='ADMIN_ACADEMIA' AND table_name='ACA_MATRICULAS';
EXIT
