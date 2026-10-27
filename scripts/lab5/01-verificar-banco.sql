WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 200 PAGESIZE 100
COLUMN username FORMAT A15
COLUMN object_name FORMAT A25
ALTER SESSION SET CONTAINER=FREEPDB1;
SELECT (SELECT COUNT(*) FROM tiendasur.cliente) AS clientes,
       (SELECT COUNT(*) FROM tiendasur.pedido) AS pedidos FROM dual;
SELECT username,authentication_type FROM dba_users WHERE username IN ('TIENDASUR','LAB_TOOLS') ORDER BY username;
SELECT object_name,object_type,status FROM dba_objects WHERE owner='LAB_TOOLS' AND object_name='MEDIR';
SELECT COUNT(*) AS huerfanos FROM tiendasur.pedido pedido WHERE NOT EXISTS (SELECT 1 FROM tiendasur.cliente cliente WHERE cliente.id_cliente=pedido.id_cliente);
SELECT COUNT(*) AS bloques_con_filas,MIN(filas) AS minimo,ROUND(AVG(filas),2) AS media,MAX(filas) AS maximo
  FROM (SELECT DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID,'BIGFILE') AS bloque,COUNT(*) AS filas FROM tiendasur.pedido GROUP BY DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID,'BIGFILE'));
SELECT num_rows,blocks,ROUND(num_rows/blocks,2) AS filas_por_bloque_hwm FROM dba_tables WHERE owner='TIENDASUR' AND table_name='PEDIDO';
DECLARE
  total NUMBER;
BEGIN
  SELECT COUNT(*) INTO total FROM tiendasur.cliente;
  IF total<>100000 THEN RAISE_APPLICATION_ERROR(-20051,'Recuento clientes incorrecto'); END IF;
  SELECT COUNT(*) INTO total FROM tiendasur.pedido;
  IF total<>1000000 THEN RAISE_APPLICATION_ERROR(-20052,'Recuento pedidos incorrecto'); END IF;
  SELECT COUNT(*) INTO total FROM dba_objects WHERE owner='LAB_TOOLS' AND object_name='MEDIR' AND object_type='PACKAGE BODY' AND status='VALID';
  IF total<>1 THEN RAISE_APPLICATION_ERROR(-20053,'MEDIR no válido'); END IF;
END;
/
EXIT
