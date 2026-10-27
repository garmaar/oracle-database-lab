# Guardia · Pérdida de un datafile de aplicación

Responsable: Pablo García Martínez. Ámbito: Oracle Free, CDB FREE / FREEPDB1. No aplicar este procedimiento a SYSTEM ni al undo de la raíz.

**Síntoma:** consulta fallida y ORA-01116/ORA-01110/ORA-27041 que identifican el archivo. Si aparece ORA-63999, Oracle puede estar cerrando la PDB por el fallo de medio. Registrar hora del fallo y avisar al responsable DBA y a la aplicación; no borrar redo ni reiniciar toda la CDB por defecto.

**Antes de reparar:** identificar `n` y la ruta real desde `V$DATAFILE`/alert log; comprobar ARCHIVELOG, copia utilizable y disponibilidad del redo posterior. En este laboratorio TBS_ACADEMIA corresponde al archivo absoluto 24; volver a consultarlo, no asumirlo en otro entorno.

```sql
SELECT name,open_mode,log_mode FROM v$database;
SELECT name,open_mode FROM v$pdbs;
SELECT file#,name,status FROM v$datafile WHERE name LIKE '%academia%';
```

En RMAN, conectado a la raíz con `rman target /`, ejecutar `LIST BACKUP OF DATAFILE n;`. Si faltan copia o redo necesarios, detener la reparación improvisada y escalar al responsable de recuperación. No usar OPEN RESETLOGS para ocultar el problema.

**Camino A — FREEPDB1 sigue READ WRITE:** como SYSDBA, poner únicamente el archivo fuera de línea:

```sql
ALTER SESSION SET CONTAINER=FREEPDB1;
ALTER DATABASE DATAFILE n OFFLINE;
```

Desde RMAN conectado a la raíz:

```text
RESTORE DATAFILE n;
RECOVER DATAFILE n;
```

Después, como SYSDBA en FREEPDB1: `ALTER DATABASE DATAFILE n ONLINE;`.

**Camino B — FREEPDB1 está cerrándose o MOUNTED:** esperar a que termine de cerrarse; confirmar MOUNTED desde la raíz. Ejecutar los mismos RESTORE/RECOVER en RMAN. Poner el archivo ONLINE desde la PDB y, desde la raíz, ejecutar `ALTER PLUGGABLE DATABASE FREEPDB1 OPEN;`. Si aparece ORA-01089 durante la transición, esperar y comprobar el estado antes de continuar. El resto de la CDB permanece abierto.

**Verificación y cierre:** comprobar FREEPDB1 READ WRITE, ausencia de errores de cabecera del archivo y ausencia de recuperación pendiente. Leer una fila cuyo COMMIT sea posterior al backup; no basta con contar filas. En el simulacro, la fila 104 debe conservar EGRESADO antes de devolverla a ACTIVO; comprobar además 20.000 estudiantes, 60.000 matrículas y el banco TiendaSur. Revisar errores nuevos del alert log, avisar a la aplicación y registrar inicio/fin y los datos conservados.

RTO observado se mide desde el fallo y, por separado, desde el inicio de reparación. RPO 0 solo se afirma si se demuestra que el cambio confirmado después de la copia sobrevivió. No repetir la pérdida del archivo para validar el arreglo.
