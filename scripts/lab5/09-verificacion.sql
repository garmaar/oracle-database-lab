WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 220 PAGESIZE 100
COLUMN name FORMAT A80
SELECT name,status FROM v$controlfile;
SELECT name,value FROM v$spparameter WHERE name='control_files' AND isspecified='TRUE';
DECLARE
  total NUMBER;
BEGIN
  SELECT COUNT(*) INTO total FROM v$controlfile;
  IF total<>3 THEN RAISE_APPLICATION_ERROR(-20055,'Faltan las tres copias del control file'); END IF;
END;
/
SELECT name,open_mode FROM v$database;
SELECT name,open_mode FROM v$pdbs;
EXIT
