WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 220 PAGESIZE 100
COLUMN member FORMAT A90
SELECT group#,members,status,archived FROM v$log ORDER BY group#;
SELECT group#,member,status FROM v$logfile ORDER BY group#,member;
SELECT TO_CHAR(first_time,'YYYY-MM-DD HH24') AS hora,COUNT(*) AS cambios FROM v$log_history WHERE first_time>=TRUNC(SYSDATE) GROUP BY TO_CHAR(first_time,'YYYY-MM-DD HH24') ORDER BY hora;
DECLARE
  total NUMBER;
BEGIN
  SELECT COUNT(*) INTO total FROM v$log;
  IF total<>3 THEN RAISE_APPLICATION_ERROR(-20056,'Número de grupos distinto de tres'); END IF;
  SELECT COUNT(*) INTO total FROM v$log WHERE members<>2;
  IF total<>0 THEN RAISE_APPLICATION_ERROR(-20057,'Grupos sin dos miembros'); END IF;
  SELECT COUNT(*) INTO total FROM v$logfile WHERE status IN ('INVALID','STALE');
  IF total<>0 THEN RAISE_APPLICATION_ERROR(-20058,'Miembros redo sin inicializar'); END IF;
END;
/
SELECT name,open_mode,log_mode FROM v$database;
EXIT
