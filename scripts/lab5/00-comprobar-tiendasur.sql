WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 220 PAGESIZE 100
COLUMN index_name FORMAT A30
COLUMN table_name FORMAT A25
ALTER SESSION SET CONTAINER=FREEPDB1;
SELECT (SELECT COUNT(*) FROM tiendasur.cliente) AS clientes,(SELECT COUNT(*) FROM tiendasur.pedido) AS pedidos FROM dual;
SELECT table_name,index_name,status,visibility FROM dba_indexes WHERE owner='TIENDASUR' ORDER BY table_name,index_name;
SELECT table_name FROM dba_tables WHERE owner='TIENDASUR' ORDER BY table_name;
SELECT COUNT(*) AS errores_paquete FROM dba_errors WHERE owner='LAB_TOOLS';
SELECT column_name FROM dba_tab_columns WHERE owner='TIENDASUR' AND table_name='PEDIDO' ORDER BY column_id;
EXIT
