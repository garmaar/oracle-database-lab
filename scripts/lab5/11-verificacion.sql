WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 220 PAGESIZE 100
COLUMN name FORMAT A80
SELECT name,open_mode,log_mode FROM v$database;
SELECT name,value FROM v$parameter WHERE name IN ('db_recovery_file_dest','db_recovery_file_dest_size');
SELECT name,value,isspecified FROM v$spparameter WHERE name IN ('db_recovery_file_dest','db_recovery_file_dest_size');
SELECT name,space_limit,space_used,number_of_files FROM v$recovery_file_dest;
SELECT COUNT(*) AS archivados_en_fra FROM v$archived_log WHERE is_recovery_dest_file='YES' AND deleted='NO';
DECLARE
  valor VARCHAR2(100);
BEGIN
  SELECT value INTO valor FROM v$parameter WHERE name='db_recovery_file_dest_size';
  IF valor<>'4294967296' THEN RAISE_APPLICATION_ERROR(-20060,'FRA no restaurada a 4 GiB'); END IF;
END;
/
EXIT
