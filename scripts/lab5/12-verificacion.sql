WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 220 PAGESIZE 100
ALTER SESSION SET CONTAINER=FREEPDB1;
SELECT estudiante_id,estado FROM admin_academia.aca_estudiantes WHERE estudiante_id IN (101,102,103,104) ORDER BY estudiante_id;
SELECT COUNT(*) AS pedidos FROM tiendasur.pedido;
SELECT COUNT(*) AS clientes FROM tiendasur.cliente;
SELECT COUNT(*) AS matriculas FROM admin_academia.aca_matriculas;
SELECT NVL(SUM(ssolderrcnt),0) AS snapshot_too_old,NVL(SUM(nospaceerrcnt),0) AS falta_undo FROM v$undostat WHERE begin_time>SYSDATE-1;
DECLARE
  estado_actual VARCHAR2(20);
BEGIN
  SELECT estado INTO estado_actual FROM admin_academia.aca_estudiantes WHERE estudiante_id=101;
  IF estado_actual<>'ACTIVO' THEN RAISE_APPLICATION_ERROR(-20061,'Fila 101 no restaurada'); END IF;
END;
/
EXIT
