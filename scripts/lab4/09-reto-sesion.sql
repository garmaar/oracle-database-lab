SET SQLFORMAT DEFAULT
SET LINESIZE 200 PAGESIZE 100
WHENEVER SQLERROR EXIT FAILURE
SELECT ses.sid,ses.serial#,ses.username,ses.status,ses.module,pro.spid,
       ROUND(pro.pga_used_mem/1048576,2) AS pga_usada_mb,
       ROUND(pro.pga_alloc_mem/1048576,2) AS pga_asignada_mb,
       ses.sql_id,ses.event
  FROM v$session ses JOIN v$process pro ON pro.addr=ses.paddr
 WHERE ses.module='LAB4_CPU';
SELECT sql_text FROM v$sql WHERE sql_id IN (SELECT sql_id FROM v$session WHERE module='LAB4_CPU');
EXIT
