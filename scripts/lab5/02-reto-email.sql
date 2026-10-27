WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 200 PAGESIZE 100
ALTER SESSION SET CONTAINER=FREEPDB1;
SET SERVEROUTPUT ON
ANALYZE INDEX tiendasur.ix_ped_cliente VALIDATE STRUCTURE;
DECLARE
  factor NUMBER;
  capacidad NUMBER:=FLOOR(7996/30);
  hojas NUMBER;
BEGIN
  SELECT FLOOR(br_blk_len/(br_rows_len/br_rows)) INTO factor FROM index_stats;
  hojas:=CEIL(100000/(capacidad*0.9));
  DBMS_OUTPUT.PUT_LINE('Predicción UX_CLI_EMAIL: fo máximo='||factor||', capacidad hoja='||capacidad||', hojas estimadas='||hojas||', altura='||(1+CEIL(LN(hojas)/LN(factor))));
END;
/
ANALYZE INDEX tiendasur.ux_cli_email VALIDATE STRUCTURE;
SELECT name,height,lf_rows,lf_blks,br_blks,pct_used FROM index_stats;
EXIT
