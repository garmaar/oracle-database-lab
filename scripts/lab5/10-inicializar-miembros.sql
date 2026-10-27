WHENEVER SQLERROR EXIT FAILURE
SET SERVEROUTPUT ON LINESIZE 200 PAGESIZE 100
DECLARE
  pendientes NUMBER;
BEGIN
  FOR intento IN 1..9 LOOP
    SELECT COUNT(*) INTO pendientes FROM v$logfile WHERE status IN ('INVALID','STALE');
    EXIT WHEN pendientes=0;
    DBMS_OUTPUT.PUT_LINE('Inicialización '||intento||': '||pendientes||' miembros pendientes');
    EXECUTE IMMEDIATE 'ALTER SYSTEM CHECKPOINT';
    EXECUTE IMMEDIATE 'ALTER SYSTEM SWITCH LOGFILE';
    DBMS_SESSION.SLEEP(1);
  END LOOP;
  SELECT COUNT(*) INTO pendientes FROM v$logfile WHERE status IN ('INVALID','STALE');
  IF pendientes<>0 THEN RAISE_APPLICATION_ERROR(-20059,'Persisten miembros redo sin inicializar'); END IF;
END;
/
EXIT
