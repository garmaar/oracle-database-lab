WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 220 PAGESIZE 100
ALTER SESSION SET CONTAINER=FREEPDB1;
SET SERVEROUTPUT ON
EXEC lab_tools.medir.consulta('Q11 sin candidato',q'[SELECT SUM(importe) FROM tiendasur.pedido WHERE fecha_pedido>=DATE '2025-01-01' AND fecha_pedido<DATE '2026-01-01']');
CREATE INDEX tiendasur.ix_ped_fec_importe_l5 ON tiendasur.pedido(fecha_pedido,importe) ONLINE;
EXEC lab_tools.medir.consulta('Q11 con candidato',q'[SELECT SUM(importe) FROM tiendasur.pedido WHERE fecha_pedido>=DATE '2025-01-01' AND fecha_pedido<DATE '2026-01-01']');
SELECT index_name,leaf_blocks,clustering_factor FROM dba_indexes WHERE owner='TIENDASUR' AND index_name IN ('IX_PED_FECHA','IX_PED_FEC_IMPORTE_L5');
SELECT bytes/1048576 AS mib_candidato FROM dba_segments WHERE owner='TIENDASUR' AND segment_name='IX_PED_FEC_IMPORTE_L5';
EXIT
