WHENEVER SQLERROR EXIT FAILURE
SET FEEDBACK ON LINESIZE 200 PAGESIZE 100
ALTER SESSION SET CONTAINER=FREEPDB1;
SELECT COUNT(*) AS apellidos_con_reemplazo_antes FROM tiendasur.cliente WHERE INSTR(apellidos,UNISTR('\FFFD'))>0;
UPDATE tiendasur.cliente
   SET apellidos=CASE WHEN MOD(ORA_HASH(id_cliente,4294967295,2),100)<2
                      THEN CASE MOD(id_cliente,2) WHEN 0 THEN 'González' ELSE 'Gonzalo' END
                      ELSE CASE MOD(ORA_HASH(id_cliente,4294967295,3),12)
                             WHEN 0 THEN 'Martínez' WHEN 1 THEN 'López' WHEN 2 THEN 'Sánchez' WHEN 3 THEN 'Pérez'
                             WHEN 4 THEN 'García' WHEN 5 THEN 'Ruiz' WHEN 6 THEN 'Moreno' WHEN 7 THEN 'Navarro'
                             WHEN 8 THEN 'Fernández' WHEN 9 THEN 'Romero' WHEN 10 THEN 'Torres' ELSE 'Castillo' END END
                 ||' '||CASE MOD(ORA_HASH(id_cliente,4294967295,4),16)
                          WHEN 0 THEN 'Gil' WHEN 1 THEN 'Ortiz' WHEN 2 THEN 'Rubio' WHEN 3 THEN 'Marín' WHEN 4 THEN 'Sanz' WHEN 5 THEN 'Iglesias'
                          WHEN 6 THEN 'Núñez' WHEN 7 THEN 'Medina' WHEN 8 THEN 'Garrido' WHEN 9 THEN 'Cortés' WHEN 10 THEN 'Castro'
                          WHEN 11 THEN 'Lozano' WHEN 12 THEN 'Vidal' WHEN 13 THEN 'Ramos' ELSE 'Méndez' END
 WHERE INSTR(apellidos,UNISTR('\FFFD'))>0;
COMMIT;
EXEC DBMS_STATS.GATHER_TABLE_STATS('TIENDASUR','CLIENTE',cascade=>TRUE);
SELECT COUNT(*) AS apellidos_con_reemplazo_despues FROM tiendasur.cliente WHERE INSTR(apellidos,UNISTR('\FFFD'))>0;
SELECT id_cliente,apellidos,DUMP(apellidos,1016) AS bytes FROM tiendasur.cliente WHERE id_cliente=1;
SELECT COUNT(*) AS clientes FROM tiendasur.cliente;
EXIT
