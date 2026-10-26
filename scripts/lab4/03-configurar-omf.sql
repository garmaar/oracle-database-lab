WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 200 PAGESIZE 100 FEEDBACK ON
COLUMN file_name FORMAT A130
ALTER SESSION SET CONTAINER=FREEPDB1;
ALTER SYSTEM SET db_create_file_dest='/opt/oracle/oradata/FREE/FREEPDB1' SCOPE=BOTH;
SELECT name,value FROM v$parameter WHERE name='db_create_file_dest';
CREATE TABLESPACE lab4_omf_probe;
SELECT tablespace_name,file_name FROM dba_data_files WHERE tablespace_name='LAB4_OMF_PROBE';
DROP TABLESPACE lab4_omf_probe INCLUDING CONTENTS AND DATAFILES;
SELECT COUNT(*) AS restos_omf_probe FROM dba_tablespaces WHERE tablespace_name='LAB4_OMF_PROBE';
EXIT
