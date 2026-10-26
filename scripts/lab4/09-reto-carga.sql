WHENEVER SQLERROR EXIT FAILURE
ALTER SESSION SET CONTAINER=FREEPDB1;
EXEC DBMS_APPLICATION_INFO.SET_MODULE('LAB4_CPU', 'consulta_cartesiana');
SET SERVEROUTPUT ON
DECLARE
  inicio NUMBER := DBMS_UTILITY.GET_TIME;
  total NUMBER;
BEGIN
  LOOP
    SELECT COUNT(*) INTO total FROM admin_academia.aca_matriculas primera,
      admin_academia.aca_matriculas segunda WHERE primera.matricula_id<3000;
    EXIT WHEN DBMS_UTILITY.GET_TIME-inicio>=2000;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('Filas del producto: ' || total);
END;
/
EXIT
