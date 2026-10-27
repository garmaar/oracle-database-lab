WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 220 PAGESIZE 100
ALTER SESSION SET CONTAINER=FREEPDB1;
SET SERVEROUTPUT ON
EXEC lab_tools.medir.consulta('Q9 últimos 20 reto',q'[SELECT * FROM tiendasur.pedido ORDER BY fecha_pedido DESC FETCH FIRST 20 ROWS ONLY]');
SELECT table_name,num_rows,blocks,avg_row_len FROM dba_tables WHERE owner='TIENDASUR' AND table_name='PEDIDO';
SELECT segment_name,bytes/1048576 AS mib FROM dba_segments WHERE owner='TIENDASUR' AND segment_name IN ('PEDIDO','IX_PED_FECHA') ORDER BY segment_name;
EXIT
