WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 180 PAGESIZE 100
SELECT 'ANTES' AS momento,estimated_mttr,actual_redo_blks FROM v$instance_recovery;
ALTER SESSION SET CONTAINER=FREEPDB1;
UPDATE admin_academia.aca_estudiantes SET estado=estado;
COMMIT;
ALTER SESSION SET CONTAINER=CDB$ROOT;
SELECT 'DESPUES SIN CHECKPOINT' AS momento,estimated_mttr,actual_redo_blks FROM v$instance_recovery;
EXIT
