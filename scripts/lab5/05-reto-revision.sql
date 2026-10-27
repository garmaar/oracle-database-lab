WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 220 PAGESIZE 100
ALTER SESSION SET CONTAINER=FREEPDB1;
SET SERVEROUTPUT ON
EXEC lab_tools.medir.consulta('reto original',q'[SELECT * FROM tiendasur.cliente WHERE SUBSTR(telefono,1,3)='600' OR UPPER(apellidos)='GIL']');
CREATE INDEX tiendasur.ix_l5_telefono ON tiendasur.cliente(telefono);
CREATE INDEX tiendasur.ix_l5_apellidos_upper ON tiendasur.cliente(UPPER(apellidos));
EXEC lab_tools.medir.consulta('reto rango y UNION',q'[SELECT * FROM tiendasur.cliente WHERE telefono>='600' AND telefono<'601' UNION SELECT * FROM tiendasur.cliente WHERE UPPER(apellidos)='GIL']');
WITH original AS (SELECT id_cliente FROM tiendasur.cliente WHERE SUBSTR(telefono,1,3)='600' OR UPPER(apellidos)='GIL'),
     propuesta AS (SELECT id_cliente FROM tiendasur.cliente WHERE telefono>='600' AND telefono<'601' UNION SELECT id_cliente FROM tiendasur.cliente WHERE UPPER(apellidos)='GIL')
SELECT 'original menos propuesta' AS comprobacion,COUNT(*) AS diferencias FROM (SELECT * FROM original MINUS SELECT * FROM propuesta)
UNION ALL SELECT 'propuesta menos original',COUNT(*) FROM (SELECT * FROM propuesta MINUS SELECT * FROM original);
DROP INDEX tiendasur.ix_l5_telefono;
DROP INDEX tiendasur.ix_l5_apellidos_upper;
EXIT
