# Respuestas · Lab 6 · E028

## Preguntas de comprobación

### Partes A–C · Rol operativo, parámetros y estados
1. Tenía 17 errores de ORA- en las últimas 24 horas. Estos se debían al ruido del contenedor, y a los errores provocados a propósito durante las pruebas del laboratorio, por lo que este número de por sí no es una preocupación. Debe haber una baseline para saber si alarmarse o no, para saber si está algo raro pasando o es simplemente errores conocidos y gestionados. (evidencia: 20261124T112232Z_01-turno.script.log)
2. La ventana de mantenimiento de un miércoles en mi base de datos dura 4 horas, empezando desde las 22:00 horas de la noche. Está en ENABLED = TRUE, y las tareas automáticas que corren en ella son auto optimizer stats collection, auto space advisor y sql tuning advisor. (evidencia: 20261124T104602Z_01-automatizacion.spool.log)
3. Como db_files es un parámetro estático, SCOPE = MEMORY nos daba ORA-02095. Al poner db_files = 250 con SCOPE=SPFILE, la vista V$SPPARAMETER ahora pasa a mostrar 250, mientras que la vista V$PARAMETER seguia en 200. Sin el RESET habria un cambio pendiente en el disco, por lo que el cambio en db_files se habría realizado en el próximo arranque de Oracle. (evidencia: 20261124T104906Z_02-parametros.script.log)
4. Porque RESET no quita el valor anterior, lo que hace es borrar la entrada de SPFILE y devolver el parámetro al valor por defecto de Oracle, por lo que para processes no funcionaría, debido a que este parámetro estaba fijado explícitamente, de la forma: *.processes=200. Un RESET borraría esta línea y en el siguiente arranque tomaría el valor por defecto en lugar del valor 200. (evidencia: 20261124T104906Z_02-parametros.script.log, 20261124T104907Z_02-init_desde_spfile.ora)
5. Después de DISCARD STATE y de reiniciar, C##OPS_RO intentaba entrar por freepdb1 y recibía que la database estaba not open. Cada PDB tiene su propio estado independiente, por lo que al no tener estado guardado, la PDB FREEPDB1 quedaba en MOUNTED. Aunque el listener conociera la PDB, al estar cerrada devolvía el error ORA-01109. (evidencia: 20261124T105007Z_02-estados-pdb.script.log)

### Partes D–E · Servicios, sesiones y diccionario
6. El SID es = 63, el SPID es 2466, el evento era PL/SQL lock timer. Todas las conexiones de la aplicación entran con el mismo USERNAME, APP_ACADEMIA, por lo que ese campo no tiene distinción de nada. Por otra parte, el MODULE, ACTION y el CLIENT_IDENTIFIER si te dicen que módulo está ejecutando cada consulta, la operación que hace (ACTION) y el usuario final para el que trabaja. (evidencia: 20261124T105212Z_03-sesiones.script.log)
7. Tras CANCEL SQL tenía 1 transacción abierta todavía, porque CANCEL SQL solo cancelaba la llamada en curso. Tras KILL SESSION IMMEDIATE, ya no quedaba ninguna sesión abierta ni ninguna transacción abierta. La fila 101 quedaba en estado activo, porque el UPDATE se deshace sin confirmar al terminar la sesión en Oracle. (evidencia: 20261124T105212Z_03-sesiones.script.log)
8. common_user_prefix tiene un valor de C## en mi imagen. Esto implica que cualquier usuario que se cree en el CDB tiene que llevar de forma obligatoria el prefijo C##, de otra forma nos saltaría un error ORA-65096 (evidencia: 20261124T105211Z_03-cuenta-app.script.log)
9. En ALL_TABLES, C##OPS_RO ve un 0 en las tablas del ADMIN_ACADEMIA, porque SELECT_CATALOG_ROLE no deja leer los datos de negocio aunque sí deje leer el diccionario. APP_ACADEMIA ve un 1 porque este tiene permiso sobre ACA_ESTUDIANTES. (evidencia: 20261124T105859Z_04-tres-miradas.script.log)

| Vista | C##OPS_RO en CDB$ROOT | C##OPS_RO en FREEPDB1 | APP_ACADEMIA en FREEPDB1 |
|---|---|---|---|
| ALL_TABLES (ADMIN_ACADEMIA) | 0 | 0 | 1 |
| DBA_USERS | 37 | 47 | ORA-00942 |
| CDB_USERS | CON_ID 1: 37 / CON_ID 3: 47 | CON_ID 3: 47 | ORA-00942 |
| V$DATAFILE | 17 | 10 | ORA-00942 |

10. Tenemos 5367 lecturas lógicas por cada recorrido, y un DB time de 0,79s. La relación entre DB time (0,79s) y DB CPU (0,63s) es que al ser muy similares, la mayoría del tiempo de la carga era trabajo de la CPU y muy pocas veces hubo esperas, porque probablemente los bloques estaban prácticamente en caché. (evidencia: 20261124T105912Z_04-deltas.script.log)

### Partes F–G · Espacio y acceso
11. La medida asignado = 10MB. Lo que me queda libre son 3,9MB. El maximo alcanzable eran 40MB, un 15,16% sobre el maximo. Para alertar usaría el porcentaje sobre el máximo alcanzable: 15,16%, porque el datafile tiene AUTOEXTEND hasta los 40MB, de manera que alertar sobre lo asignado nos estaría dando alarmas falsas, cuando realmente sigue pudiendo crecer hasta el techo real. (evidencia: 20261124T110106Z_05-almacenamiento.script.log)
12. El que insertó fue SYS, quien pagó la cuota fue el dueño del segmento, osea CARGA_HIST, que tenía cuota 0. Por esto saltó el error ORA-01950 al intentar crear el primer segmento. Ampliar el tablespace no habria resuelto el error ORA-01536 porque TBS_ACADEMIA_HIST seguia teniendo espacio libre y seguía teniendo margen para crecer hasta el maximo alcanzable. No habría servido de nada ampliar porque el bloqueo era un limite de permiso no era una falta de espacio físico. (evidencia: 20261124T110106Z_05-almacenamiento.script.log)
13. La carga reanudable estuvo suspendida durante 12 a 19 segundos, hasta que se amplió a 30MB. La evidencia que se dejó de ello en el alert log fue statement in resumable session 'carga-historico' was suspended due to ORA-01536. (evidencia: 20261124T110108Z_05-resumable.script.log)
14. Antes del DELETE teníamos 20000 filas, 2944 bloques y 23 MB. Después del DELETE del 90% nos quedamos con 2000 filas, 2944 bloques y 23MB, que no cambiaron. Tras el SHRINK nos quedamos con 2000 filas, 304 bloques y 2,4MB, aparte de una cuota usada de 2,4MB. El DELETE borraba filas pero dejaba los bloques vacíos o medio vacíos, asignados por debajo de la marca de agua alta (HWM). (evidencia: 20261124T110129Z_05-hwm-shrink.script.log)
15. Mis valores en el perfil DEFAULT eran: FAILED_LOGIN_ATTEMPTS = 10, INACTIVE_ACCOUNT_TIME = 365, PASSWORD_GRACE_TIME = 7, PASSWORD_LIFE_TIME = 180, PASSWORD_LOCK_TIME = 1, PASSWORD_VERIFY_FUNCTION = NULL. Los limites de PRF_PERSONAS para una persona de secretaría sería conveniente que fueran por ejemplo FAILED_LOGIN_ATTEMPTS = 3, para frenar posibles ataques a la fuerza con un numero mucho menor, por ejemplo 3 intentos máximos, y por ejemplo PASSWORD_LIFE_TIME = 90, para reducir el riesgo de que una cuenta sea abandonada o haya credenciales antiguas por puestos administrativos. (evidencia: 20261124T110229Z_06-gobierno-acceso.script.log)
16. Ana podía leer ACA_MATRICULAS porque tenía el rol de ROL_SECRETARIA_ACADEMIA, que hereda del rol ROL_LECTURA_ACADEMIA, que es un rol que tiene el privilegio de esquema, y por tanto, puede leer todas las tablas de ese esquema sin necesidad de concederselas manualmente. Al cambiar el nombre de un alumno le saltaba el error ORA-41900. (evidencia: 20261124T110230Z_06-probar-acceso.script.log)

### Partes H–I · Objetos, diagnóstico y guardia
17. El primer cambio de columna, añadir telefono no invalidó ningún objeto, porque Oracle gestiona las dependencias a nivel de columna, no de la tabla entera. El segundo cambio de columna, ampliar la email_institucional solo invalidaba el V_CONTACTO_LAB6, porque es el único objeto que tenía esa columna referenciado. Y el último cambio de columna, ampliar nombres, invalidaba V_ACTIVOS_LAB6, y F_TOTAL_ACTIVOS_LAB6, porque el primero usaba directamente nombres y el segundo dependía del primero. (evidencia: 20261124T110529Z_07-objetos.script.log)
18. Duplicar la SGA no mejoraría el DB time, porque el ESTD_DB_TIME_FACTOR sigue en 1 y las lecturas físicas que se estimaban tampoco bajaban. Por debajo de 384MB , 256MB y 128MB aparecen 3 sobreasignaciones. (evidencia: 20261124T110524Z_07-memoria.spool.log)
19. Necesitó 247 lecturas lógicas. La línea de la traza que lo dice es la línea FETCH, en el campo cr. (evidencia: 20261124T110534Z_07-adr-trazas.script.log)
20. INC-601: Clave: ANA_GARCIA esperando en row lock contention bloqueada por APP_ACADEMIA. Intervención: ALTER SYSTEM KILL SESSION '64,14523' IMMEDIATE;. Validación: 08-diagnostico nos devuelve 0 bloqueos y el alumno 101 en ACTIVO. (evidencia: 20261124T110708Z_08-diagnostico-1.script.log)
INC-602: Clave: FREEPDB1 está en SI pero la academia_app está en ARRANCADO = NO. Intervención: EXEC DBMS_SERVICE.START_SERVICE('academia_app');. Validación: volvemos a ver que academia_app ahora sí está en ARRANCADO = SI. (evidencia: 20261124T110905Z_08-diagnostico-2.script.log)
INC-603: Clave: APP_ACADEMIA tiene ACCOUNT_STATUS = LOCKED. Intervención: ALTER USER app_academia ACCOUNT UNLOCK;. Validación: tenemos ahora 0 cuentas bloqueadas y la APP_ACADEMIA entra por academia_app sin problema y lee 17600 estudiantes correctamente. (evidencia: 20261124T111252Z_08-diagnostico-3.script.log)


## Simulacro de examen 1Z0-182 (S1–S22)
- **S1:** B, Parte B 
- **S2:** C, parte C
- **S3:** B, parte C
- **S4:** B,C parte C
- **S5:** C, parte C
- **S6:** B, parte C
- **S7:** A, parte D
- **S8:** B, parte D
- **S9:** C, parte D
- **S10:** C, parte D
- **S11:** B, parte E
- **S12:** A,C, parte E
- **S13:** B, parte F
- **S14:** A,C, parte F
- **S15:** A,C, parte F
- **S16:** B, parte F
- **S17:** B. parte G
- **S18:** B, parte G
- **S19:** A,B, parte H
- **S20:** B, parte H
- **S21:** C, parte H
- **S22:** C, parte I
