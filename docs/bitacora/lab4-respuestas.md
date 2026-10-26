# Laboratorio 4 · Oracle DBA Workflow I v3

Autor: Pablo García Martínez. Ejecución: 26 de octubre de 2026, WSL y Oracle AI Database Free 23.26.3.0.0. Las horas de Oracle y los nombres de evidencia están en UTC. La documentación corresponde a los resultados propios, incluidos los que difieren del ejemplo del enunciado.

## Preguntas de comprobación

### A · Respaldo y diagnóstico

1. **Consistencia.** La evidencia [00] muestra `Database closed`, `Database dismounted` y `ORACLE instance shut down` antes del tar. SHUTDOWN IMMEDIATE termina transacciones, hace checkpoint y cierra limpiamente. Una copia arbitraria con la base abierta puede mezclar instantes de distintos archivos; ARCHIVELOG por sí solo no convierte ese tar en una copia válida. Haría falta un procedimiento de backup en línea soportado y los archivos de recuperación necesarios.

2. **Manifiesto y SHA-256.** El manifiesto identifica imagen, volumen, fecha, commit `03321af` y tipo de copia. SHA256SUMS comprueba que los archivos no han cambiado respecto a sus huellas, no que una restauración haya sido probada. `restaurar-estado.sh` comprueba Docker y todas las sumas antes de parar la base; pide confirmación con el nombre del volumen salvo `--si`. La evidencia [00] contiene las cuatro comprobaciones OK y la lectura correcta del comprimido.

3. **RPO y RTO.** RPO es la pérdida de datos tolerable: con esta única copia fría, el punto recuperable demostrado es el del backup del 26 de octubre; restaurarla descartaría los cambios posteriores. No se ha definido una periodicidad que permita expresar un RPO objetivo en minutos. RTO es el tiempo máximo tolerable para recuperar el servicio. Los **182 segundos** de [00] son duración del procedimiento de copia, no un RTO medido. No se ha ejecutado un simulacro de restauración ni se inventa su duración.

### C–D · Correcciones del entorno heredado

4. **Rutas heredadas.** V000 usó nombres relativos y Oracle los resolvió bajo `$ORACLE_HOME/dbs`. En esta imagen esa carpeta es un enlace a `/opt/oracle/oradata/dbconfig/FREE/dbs`: los cinco archivos ya persistían dentro del volumen, aunque fuera de la carpeta estándar. El diagnóstico [01] y el inventario real [11-real] lo demuestran. `DB_CREATE_FILE_DEST` permite usar OMF al omitir DATAFILE; no corrige automáticamente una ruta relativa escrita explícitamente. El reto [03-omf] configura el destino de la PDB y lo demuestra con una sonda.

5. **RENAME no copia.** Cambia la referencia registrada por Oracle; hay que realizar también la copia física. [03-move] demuestra OFFLINE NORMAL, `cp -p`, RENAME DATAFILE, ONLINE y eliminación del original después de que Oracle valide la nueva ubicación.

6. **Migraciones hacia delante.** V000/V001 describen lo ya ejecutado y permanecen idénticas a `03321af`. V003 aplica `NO AUTHENTICATION` a los cinco propietarios. Borrar el texto no revoca una credencial conservada en clones o en el historial. [04-claves] demuestra ORA-01017 al intentar conectarse con cada contraseña histórica; no reproduce sus valores.

7. **Persistencia.** [03-persist] registra el borrado del contenedor, conservación del volumen y recreación con otra identidad Docker. Antes y después hay cinco tablespaces ONLINE, 14 tablas de negocio y cero estudiantes, porque V002 todavía no se había aplicado. C##OPS_RO también persiste. Se prueba después de la reubicación para que ninguna dependencia quede en la capa desechable. La prueba solo se realizó una vez.

### E–F · Instancia, arranque y parámetros

8. **Instancia frente a base.** De la instancia: nombre FREE, host `8f2fc0e763a0` y arranque `2026-10-26 17:02:48` en [05]. De la base: DBID `1509902213`, creación `2026-07-05` y modo ARCHIVELOG. La práctica posterior reinicia la instancia a las 17:04; eso no crea otra base. [06] y [15].

9. **Etapas.** NOMOUNT lee SPFILE/PFILE y crea memoria y procesos; V$PARAMETER responde y V$DATABASE produce ORA-01507. MOUNT abre control files: V$DATAFILE ya conoce 16 archivos, pero DBA_TABLES produce ORA-01219 porque el diccionario no está abierto. OPEN abre los datafiles y redo. En [06], FREEPDB1 se abre sola por SAVE STATE.

10. **Memoria y SPFILE.** V$PARAMETER describe el valor efectivo; V$SPPARAMETER, lo persistido. [07] muestra `db_files=200` efectivo y `300` en SPFILE después de SCOPE=SPFILE. RESET quita esa especificación; la verificación posterior conserva 200 y `ISSPECIFIED=FALSE`.

11. **PROCESSES.** Aunque esta versión informa `ISSYS_MODIFIABLE=IMMEDIATE`, el cambio probado en memoria falla con ORA-02097/ORA-02095. El límite requiere inicialización al arrancar. La ejecución real [07] prevalece sobre deducir capacidad de cambio únicamente de esa columna.

### G–H · Memoria y procesos

12. **Modelo.** `memory_target=0`, `memory_size=0` y `sga_target=1536M` identifican ASMM para la SGA. `pga_aggregate_target=512M` y WORKAREA_SIZE_POLICY=AUTO gestionan la PGA automáticamente. [08-memoria] y [08-check].

13. **Caché.** [08-cache] mide 357 lecturas lógicas y 262 físicas en frío, frente a 247 lógicas y cero físicas en caliente, para los mismos 17.600 estudiantes ACTIVO. El cociente didáctico `1-físicas/lógicas` pasa de aproximadamente 26,6 % a 100 %. Las diferencias incluyen trabajo de la sesión y del diccionario: no son un recuento exclusivo de bloques de la tabla. V$BH muestra 245 buffers, que tampoco equivalen necesariamente a 245 bloques distintos persistidos.

14. **Parse.** [08-parse] registra 1.004 análisis totales, 1.000 duros y 930 ms de CPU con literales; con bind, un análisis total/duro y 0 ms de CPU de análisis medidos con esa resolución. V$SQL conserva 1.000 cursores y 38.845 KiB frente a un cursor y 39 KiB, ambos con 1.000 ejecuciones. El tiempo total fue 1.040 frente a 10 ms. El reto por FORCE_MATCHING_SIGNATURE encuentra la familia de 1.000 textos.

15. **PID.** LGWR tiene SPID **857** en [09]; `/proc/857/cmdline` contiene `db_lgwr_FREE`, mientras Docker muestra PID **6880** en el host. Son espacios de nombres PID diferentes, no dos procesos LGWR distintos. [09-check].

### I · Contenedores

16. **16 frente a 9 datafiles.** [10-usuarios] muestra 4 de CDB$ROOT, 3 de PDB$SEED y 9 de FREEPDB1 al consultar como SYS desde la raíz. Dentro de FREEPDB1, V$DATAFILE devuelve únicamente los nueve de CON_ID 3. El ámbito depende de contenedor, vista y permisos.

17. **ORA-00942.** LAB4_ANALISTA solo tiene CREATE SESSION y no ve DBA_TABLES, V$SESSION ni las tablas de Academia. Oracle no presenta al usuario esos objetos como accesibles; de ahí ORA-00942. Al intentar cambiar a la raíz sí aparece ORA-01031. [10-usuarios].

18. **Auditor común.** Ambos usuarios comunes tienen privilegios de catálogo, pero C##LAB4_AUDITOR no tiene CONTAINER_DATA ampliado: desde la raíz ve sus datos y los de CON_ID 0. La diferencia se corrige con `ALTER USER c##lab4_auditor SET CONTAINER_DATA=ALL CONTAINER=CURRENT;`. Es explicación, no una concesión que se haya conservado. [10-usuarios].

19. **Privilegio de esquema.** READ ANY TABLE ON SCHEMA ADMIN_ACADEMIA cubre tablas actuales y futuras de ese esquema sin conceder lectura global de la PDB. Reduce mantenimiento, pero también permitirá leer tablas sensibles añadidas después en el mismo esquema. [10-usuarios] muestra lectura de los 20.000 estudiantes, denegación sobre Clínica y ORA-41900 al intentar UPDATE.

20. **Prefijo común.** COMMON_USER_PREFIX vale `C##`. [10-pdb] produce ORA-65096 al intentar crear LAB4_LOCAL en la raíz y ORA-65094 al crear C##LAB4_COMUN desde FREEPDB1. El usuario local válido creado dentro de la PDB se elimina después.

### J · Archivos

21. **Clasificación.** [11] inventaría 16 datafiles, 3 tempfiles, 2 control files y 3 miembros de redo como archivos de la base. SPFILE, password file, archived logs y ADR son relacionados. El password file autentica conexiones administrativas externas; no contiene datos de negocio ni sustituye al diccionario. Su ruta aparente está en dbs y la real en `oradata/dbconfig/FREE/dbs/orapwFREE`; está dentro del volumen. No se versiona su contenido. [11-real].

22. **Tamaño físico.** Academia mide **104.865.792 bytes**, frente a **104.857.600 bytes** utilizables de sus 100 MiB: diferencia de 8.192 bytes, un bloque adicional de cabecera física del archivo. No son 100 MB decimales. [11-linux].

23. **Dominios de fallo.** Hay dos control files, no uno, pero ambos comparten volumen. Cada grupo de redo tiene un único miembro y todos comparten ese volumen. La pérdida del almacenamiento es un fallo común para las copias de control; el redo tampoco tiene un miembro alternativo por grupo. Esta base está en ARCHIVELOG, a diferencia del supuesto NOARCHIVELOG de algunas preguntas. [11-alert].

24. **ADR efímero.** Al recrear el contenedor se pierden los diagnósticos escritos en su capa. La base puede seguir íntegra porque sus archivos persistían, pero faltará historia para investigar incidentes. La imagen puede traer mensajes antiguos: no hay que tratarlos como errores nuevos. [11-linux].

### K · Bloque y fila

25. **ROWID propio.** `AAAR2mAAAAAAAMLAAF` se separa como `AAAR2m / AAA / AAAAML / AAF`. DBMS_ROWID confirma objeto **73126**, archivo absoluto **24**, bloque BIGFILE **779**, ranura **5**. En BIGFILE se debe interpretar la parte extendida de dirección con `'BIGFILE'`; no confundir el campo aparente de archivo con el absoluto. DBA_DATA_FILES devuelve RELATIVE_FNO=1024 y el archivo academia01.dbf. [12] y [12-check].

26. **Directorio y espacio libre.** En mi bloque 779, `nrow=90`; fsbo es el comienzo del espacio libre tras la cabecera/directorio y fseo su límite hacia las filas. `fsbo=0xc6=198`, `fseo=0x427=1063`, `avsp=0x361=865`: **1063−198=865**. [12].

27. **ITL.** La primera entrada tiene Flag `--U-`, Lck=90 y referencia a una transacción ya confirmada. El commit no obliga a visitar y limpiar inmediatamente todos los bloques modificados. La información de transacción puede completarse al volver a acceder al bloque; Lck=90 no demuestra que existan 90 bloqueos activos ahora. [12].

28. **78 bytes.** Los datos de la fila 101 ocupan `3+9+9+11+19+6+11=68` bytes. Se añaden tres bytes de cabecera de fila y siete bytes de longitud de columna: **68+3+7=78**, igual a `tl: 78` del volcado. Los dos bytes de su entrada en el directorio del bloque se contabilizan aparte. [12].

### L · Capacidad y coste

29. **Factor de bloqueo.** Con r=20.000, R=76, B=8.192, h=96 y PCTFREE=10: `bfr=floor(8096×0,9/76)=95`; `b=ceil(20000/95)=211`. El modelo con cabecera Oracle 122 y dos bytes de directorio da bfr=93 y b=216. Se observan **244** bloques bajo HWM, **256** asignados y **231** con filas (68–95 filas, media 86,6). El modelo no incluye completamente metadatos ASSM, ocupación real, variación de longitud y bloques bajo HWM sin filas. [13].

30. **Latencias medidas.** 5a: 400.000 lecturas lógicas, cuatro por búsqueda, 1.130 ms de CPU, **2,83 µs/lectura**. 5b: 5.464 lecturas físicas, 59,5 ms, **10,9 µs/lectura**, cota superior porque incluye CPU. 5c: 4.595 bloques en 53 peticiones, 36 multibloque, **33,4 ms**; aproximadamente **7,27 µs/bloque**, 1.075 MiB/s según la convención del script. Son muestras diferentes, no tiempos de tres etapas de una misma consulta. [13].

31. **Umbral en HDD.** Manteniendo bfr=86 del banco y usando 150 MiB/s como hace el script: `c_sec=8192/(150×1048576)=52,08 µs`; `c_aleat=5000 µs`. Entonces `k/r < (1/86)×(52,08/5000)=0,0001211`, es decir **0,0121 %**, unas **48 filas de 400.000**. Los 4.595 bloques tardarían unos **239,3 ms** secuenciales frente a **22,975 s** aleatorios. Si MB/s se interpreta estrictamente como 10⁶ bytes/s, el umbral sería **0,0127 %**, unas 51 filas. El umbral medido del contenedor fue 0,78 %; no se extrapola al HDD. [13].

32. **Caché de Linux.** FLUSH BUFFER_CACHE vacía la caché Oracle, no la caché de páginas de Linux. Una lectura física desde el punto de vista de Oracle puede servirse desde RAM del host. El método sirve para comparar el entorno medido, pero esos microsegundos no certifican la latencia de un disco real ni de producción. [13].

### M · Migración y encadenamiento

33. **Diferencias.** Una fila migrada cabía inicialmente y, al crecer sin espacio, se mueve conservando una cabeza con un puntero. Una fila encadenada requiere varias piezas porque no cabe en un bloque. ANALYZE LIST CHAINED ROWS y `table fetch continued row` ayudan a detectarlas, pero no distinguen por sí solos ambas causas. En [14], MIGRA llega a 1.000 migradas de 5.000 y ANCHA a una encadenada de dos filas. MOVE con reserva suficiente cura la migración; una fila de unos 12.000 bytes requiere rediseño o un tamaño de bloque apropiado.

34. **3,2 lecturas.** Las búsquedas necesitan unas tres lecturas de base entre índice y tabla; las 200 filas migradas entre 1.000 añaden una lectura cada una: `3000+200=3200`, **3,2 por búsqueda**. Se midieron también 200 `table fetch continued row`. [14].

35. **Índice UNUSABLE.** MOVE cambia las direcciones físicas y el índice conserva las antiguas. [14] muestra UNUSABLE, REBUILD y VALID; después CHAIN_CNT=0, PCTFREE=20 y las mismas 5.000 filas. En producción se planificaría indisponibilidad o una operación ONLINE compatible con edición/licencias y recursos; no se supone que toda característica ONLINE esté disponible en Free.

### N–O · Autopsia y trabajo profesional

36. **Tres hallazgos.** Control files en el mismo volumen: riesgo de pérdida conjunta, separar dominios de fallo, P1. Un miembro por grupo de redo: sin réplica de ese archivo, planificar multiplexación, P1. ADR en la capa del contenedor: pérdida de diagnósticos, persistir/exportar, P2. El [informe de autopsia](lab4-autopsia.md) incluye también archivado, permisos, memoria y errores actuales con sus evidencias.

37. **Cuenta de observación.** C##OPS_RO tiene CREATE SESSION, SET CONTAINER, SELECT_CATALOG_ROLE y SELECT puntual de V_$DIAG_ALERT_EXT; CONTAINER_DATA permite observar otros contenedores desde la raíz. No tiene rol DBA ni privilegios de sistema de escritura, tampoco heredados de sus roles en el contraste [15-extra]. No puede administrar la instancia ni modificar las tablas de negocio con estas concesiones. SYSTEM tiene un alcance administrativo innecesario para leer métricas.

38. **Exposiciones corregidas.** V003 invalida contraseñas literales de propietarios que permanecen en V000 por ser una migración histórica. El ejecutor 08 usa `/ as sysdba`, sin credenciales en argumentos. La recreación reutiliza el volumen sin pasar contraseñas; Docker contiene cero variables de contraseña con valor. SYS se rotó y las credenciales locales están ignoradas por Git. El control [16-seguridad] no encontró valores vigentes de las cuatro variables de contraseña en archivos versionados ni en blobs del historial.

## Retos profesionales

### Diagnóstico inicial y prioridad

La prioridad alta inicial eran las credenciales publicadas de los propietarios: se invalidan con V003 y se comprueba su rechazo.

Los datafiles relativos estaban realmente dentro del volumen por el enlace dbs: riesgo operativo medio por rutas confusas y ausencia de un destino OMF explícito.

Se reubican antes de recrear el contenedor, se fija MAXSIZE y se demuestra persistencia.

El puerto 8181 no atendía ORDS en el contenedor: se retira para reducir exposición y confusión.

La copia fría validada precede a las correcciones; sus 182 segundos no se presentan como prueba de recuperación.

### Mínimo privilegio

Dar DBA a la cuenta permitiría modificar configuración y eliminar objetos, y convertiría el compromiso de su contraseña de monitorización en un incidente administrativo. Para el alert log basta `GRANT SELECT ON sys.v_$diag_alert_ext TO c##ops_ro CONTAINER=ALL;`, aplicado y probado en [11]. No se concedió SELECT ANY TABLE global.

### Prevención con OMF

Se aplicó en FREEPDB1 `ALTER SYSTEM SET db_create_file_dest='/opt/oracle/oradata/FREE/FREEPDB1' SCOPE=BOTH;`, en un commit de configuración separado. `CREATE TABLESPACE lab4_omf_probe;` generó un nombre OMF bajo ese destino. La sonda y su archivo se eliminaron; [10-check] confirma que la configuración seguía efectiva después. Para futuras altas se debe omitir DATAFILE o revisar rutas absolutas: una ruta relativa explícita no queda prohibida por OMF.

### Parte del reinicio

Según los timestamps del alert log en [11-alert], se pidió SHUTDOWN a **17:04:49.800 UTC**, terminó a **17:04:56.922**, arrancó de nuevo a **17:04:57.053** y completó OPEN a **17:05:01.631**. Son **11,831 s** desde la petición de parada hasta OPEN, y **4,578 s** desde STARTUP hasta OPEN. Hay mensajes `Crash Recovery excluding pdb ... which was cleanly closed`, pero no un inicio de redo scan ni una recuperación completada de bloques en el contraste: no se debe afirmar recuperación efectiva solo por aparecer esas palabras. Los ORA-00800 actuales indican fallo al fijar prioridades de VKTM/LGWR: advertencia identificada, pendiente de investigar la configuración del SO. Los ORA-27167/27300–27303 y ORA-07427 de julio pertenecen a la historia incluida en la imagen, no al reinicio actual. Los errores ORA-01507/01219 provocados por SQL son esperados en sus etapas y no indican una avería de arranque.

### Petición de cambio de OPEN_CURSORS

Valor actual: 300 en raíz y PDB, persistido en el SPFILE de la raíz; la PDB vuelve a heredarlo tras el experimento [07]. Propuesta: 1.000 solo en la PDB afectada mediante `ALTER SYSTEM SET open_cursors=1000 SCOPE=BOTH;`, únicamente tras localizar fugas con V$OPEN_CURSOR y medir `opened cursors current` por sesión. Validaría carga representativa, consumo y ausencia de ORA-01000. Rollback de la excepción local: `ALTER SYSTEM RESET open_cursors SCOPE=BOTH;` para heredar el valor de raíz. Guardaría antes/después, métricas por sesión y prueba de la aplicación. Es una petición diseñada: **no se ha elevado el límite a 1.000**.

### Literales y sesión de carga

`08-reto-literales.sql` agrupa por FORCE_MATCHING_SIGNATURE y exige más de 50 SQL_ID distintos. Su salida [08-reto] encuentra 1.000 textos de `lab4_literal`. En el reto H, la sesión de la consulta cartesiana tenía **SID 21**, **SPID 1514**, **PGA usada 3,71 MiB** y **asignada 4,12 MiB** mientras estaba ACTIVE. La consulta cruza ACA_MATRICULAS consigo misma filtrando el primer ID a `<3000`; devuelve **179.940.000** combinaciones. La carga era de lectura, terminó y [10-check] encontró cero sesiones con módulo LAB4_CPU. [09-reto].

### Diseño del acceso de una auditora externa

Usuario **local en FREEPDB1**, con una credencial gestionada fuera del repositorio:

```sql
ALTER SESSION SET CONTAINER=FREEPDB1;
CREATE USER auditora_clinica IDENTIFIED BY "<credencial-inyectada-fuera-de-Git>";
GRANT CREATE SESSION TO auditora_clinica;
GRANT READ ANY TABLE ON SCHEMA admin_clinica TO auditora_clinica;
```

Al acabar la semana:

```sql
REVOKE READ ANY TABLE ON SCHEMA admin_clinica FROM auditora_clinica;
REVOKE CREATE SESSION FROM auditora_clinica;
ALTER USER auditora_clinica ACCOUNT LOCK;
```

También se finalizarían sus sesiones activas si existieran; después se retiraría la cuenta según la política de auditoría. Una cuenta local evita acceso a raíz u otras PDB; READ permite lectura sin UPDATE ni SELECT FOR UPDATE. No usaría SELECT_CATALOG_ROLE. Este diseño **no se ha ejecutado** y el marcador mostrado no es una contraseña válida del entorno.

### Plan de copia a partir del inventario

[11-real] suma tamaños físicos mediante stat de los archivos que Oracle inventaría: datafiles **4.039,125 MiB**, control files **35,8438 MiB**, redo **600,0015 MiB**, SPFILE **0,0034 MiB** y password file **0,002 MiB**. Total sin TEMP: **4.902.067.200 bytes = 4.674,9756 MiB** antes de comprimir. Son tamaños de esta inspección, no el tamaño comprimido del backup original. TEMP añadiría 60,0234 MiB físicos; el backup por volumen incluye además archivos auxiliares y archived logs (unos 525 MiB), por lo que no debe confundirse con esa suma mínima.

En un backup RMAN se incluyen datafiles y control file y se configura el respaldo del SPFILE y de archived logs según la estrategia. Los online redo y tempfiles no se respaldan como datafiles; el password file se protege aparte, así como configuración de red y diagnósticos. No se ha ejecutado RMAN en este laboratorio.

### Otro bloque y capacidad de matrículas

El bloque **1174** de la fila **19501** tiene `nrow=85`, `fsbo=0xbc`, `fseo=0x3f6`, `avsp=0x33a=826` y una ITL `--U-` con Lck=85. Frente al bloque 779 de la fila 101 (90 filas y 865 bytes libres), sus filas son mayores; la fila elegida mide 83 bytes. También conserva información pendiente de limpieza diferida. Se guardó una traza completa adicional. [12-extra].

El reto de matrículas predijo **284 bloques** antes de consultar DBA_TABLES, usando una estimación de fila física de 34,31 bytes a partir de VSIZE y cabecera/longitudes. Las estadísticas informan AVG_ROW_LEN=30, que con la fórmula U3 predice **248**; se observan **370** bajo HWM y **301** con filas, entre 162 y 213 filas por bloque. No son medidas equivalentes: la estimación física añade overhead explícito; las estadísticas redondean su longitud media, y HWM también abarca bloques sin filas. ASSM, distribución y espacio reservado explican parte de la separación con el modelo ideal. Un recorrido de 370 bloques a 150 MiB/s cuesta aproximadamente **19,271 ms**, sin añadir latencia inicial, CPU ni contención. [13-matriculas] y [13-check].

## Preguntas tipo examen

Se responden las 46 numeradas y las tres adicionales intercaladas en v3.

| Pregunta | Respuesta | Justificación |
|---|---|---|
| P1 | A, D | Cierre limpio: copia consistente y apertura sin aplicar redo si se restaura el conjunto correcto. [00] |
| P2 | B | OFFLINE, copia SO, RENAME y ONLINE; la edición del laboratorio no admite Online Move Datafile. [03-move] |
| P-D1 | C | NO AUTHENTICATION conserva objetos y elimina el inicio de sesión con contraseña. [04-claves] |
| P3 | A, C | STARTUP_TIME pertenece al arranque; CREATED a la creación de la base. [05] |
| P4 | A, C | En NOMOUNT hay parámetros y se puede crear el control file; no diccionario abierto. [06] |
| P5 | B | ARCHIVELOG requiere MOUNT con la base sin abrir. |
| P6 | B | Al arrancar con SPFILE, el alcance predeterminado de ALTER SYSTEM para ese parámetro es BOTH. [07] |
| P7 | C | PROCESSES no se cambia desde una PDB: ORA-65040 observado. [07] |
| P8 | A, C | Arrancar con un PFILE válido y recrear el SPFILE corrige configuración de arranque. |
| P9 | B | ASMM redistribuye la SGA; un DB_CACHE_SIZE explícito actúa como mínimo. |
| P10 | A, D | Sort area y memoria de sesión dedicada son privadas; shared pool y caches son SGA. [08-memoria] |
| P-G1 | B | Los binds evitan nuevos textos por cada literal. [08-parse] |
| P-G2 | B | 6 PASSES y TEMP evidencian ordenación multipasada, no seis ejecuciones. [08-parse] |
| P11 | C | En el COMMIT síncrono habitual debe persistirse el redo mediante LGWR. |
| P12 | B, D | PMON y SMON son obligatorios; ARCn depende del archivado. [09] |
| P13 | B | Dentro de la PDB se ven sus propios datafiles, CON_ID 3. [10-usuarios] |
| P14 | B | CONTAINER_DATA amplía el conjunto visible desde la raíz. [10-usuarios] |
| P15 | A, D | La concesión de esquema cubre sus tablas futuras y no otros esquemas. [10-usuarios] |
| P16 | B, D | Control files y online redo forman la base; SPFILE y password file la acompañan. [11] |
| P17 | C | En el supuesto NOARCHIVELOG y pérdida del disco solo queda la última copia completa utilizable. No describe mi ARCHIVELOG actual. |
| P18 | B | DBMS_ROWID debe recibir BIGFILE para interpretar correctamente la dirección. [12] |
| P19 | A, B | PCTFREE reserva espacio para UPDATE y limita nuevas inserciones; no garantiza ausencia de migración. |
| P20 | B | bfr=floor((8192−96)×0,9/180)=40; ceil(2.000.000/40)=50.000 bloques. |
| P21 | B | db file scattered read indica lectura multibloque hacia buffer cache. [13] |
| P22 | A, C | LIST CHAINED ROWS detecta y reorganizar con reserva puede curar migración; DBMS_STATS no calcula CHAIN_CNT. [14] |
| P23 | B | Una fila de 12.000 bytes no cabe en 8 KiB; moverla no elimina su encadenamiento. [14] |
| P24 | B | Cuenta de observación con catálogo, CONTAINER_DATA y concesión puntual, sin DBA. [11] |
| P25 | B | PDB$SEED es la plantilla de solo lectura. [10-pdb] |
| P26 | C | Un nombre C## local dentro de FREEPDB1 produce ORA-65094. [10-pdb] |
| P27 | B | Cerrar la PDB y después DROP INCLUDING DATAFILES. [10-pdb] |
| P28 | A, C | V$DATAFILE y V$LOG pueden consultar estructura del control file en MOUNT. [06] |
| P29 | A | X$KCCLE pertenece a estructuras del control file, como muestra la definición de V$LOG. [10-diccionario] |
| P30 | B | Las vistas CDB_ existen en raíz y PDB; dentro de la PDB su ámbito es local. [10-usuarios] |
| P31 | B | Los tempfiles se recrean; no se respaldan como datafiles persistentes. [11] |
| P32 | B | La instancia sigue usando parámetros en memoria y puede recrear SPFILE FROM MEMORY. No se ha borrado el SPFILE para probarlo. |
| P33 | B | V$PWFILE_USERS lista las identidades y privilegios del password file. [11] |
| P34 | A, B | ITL y directorio de filas son estructuras del bloque. [12] |
| P35 | B | AUTOALLOCATE comienza con extensiones de 64 KiB y crece a 1 MiB. [12] |
| P36 | B | ASSM administra espacio libre mediante bitmaps; no es AUTOEXTEND. [12] |
| P37 | B | El valor predeterminado desde 23ai es BIGFILE con gestión local en el escenario del enunciado. [12] |
| P38 | A | Cero lecturas físicas y cuatro lógicas indican bloques servidos por caché. [08-cache] |
| P39 | A, B | Mayor reserva libre y mayor fila reducen filas por bloque. [13] |
| P40 | B | FLUSH BUFFER_CACHE afecta a las sesiones de la instancia y puede causar picos de lectura; aquí solo se hizo en laboratorio. |
| P41 | B | Migración por crecimiento; encadenamiento por no caber en el bloque. [14] |
| P42 | A | REBUILD repara el índice tras MOVE; ONLINE debe evaluarse según soporte real. [14] |
| P43 | A | V$DIAG_ALERT_EXT permite leer el alert log mediante SQL. [11] |
| P44 | A, B | Revisar crecimiento y ampliar capacidad conforme al tipo de tablespace, no borrar redo. |
| P45 | A, B | SGA/background y online redo son compartidos por las PDB; undo no siempre. [09], [11] |
| P46 | B | El usuario local con solo CREATE SESSION no puede saltar a raíz: ORA-01031. [10-usuarios] |

## Estado de entrega

La comprobación [16] finaliza con **TODO OK**. El informe [lab4-autorrevision.md](lab4-autorrevision.md) distingue la autorrevisión técnica realizada del requisito de revisión cruzada y del estado real del PR. No se ha realizado el laboratorio 5.

## Referencias de evidencia

[00]: lab4/evidencia/script/20261026T163053Z_00-backup-lab3-final.script.log
[01]: lab4/evidencia/script/20261026T163538Z_01-diagnostico-inicial.script.log
[03-move]: lab4/evidencia/script/20261026T170159Z_03-reubicar-datafiles.script.log
[03-persist]: lab4/evidencia/script/20261026T170241Z_03-prueba-persistencia.script.log
[03-omf]: lab4/evidencia/script/20261026T170623Z_03-reto-omf.script.log
[04-claves]: lab4/evidencia/script/20261026T170410Z_04-credenciales.script.log
[05]: lab4/evidencia/spool/20261026T170420Z_05-instancia-y-base.spool.log
[06]: lab4/evidencia/script/20261026T170449Z_06-arranque-por-etapas.script.log
[07]: lab4/evidencia/script/20261026T170521Z_07-parametros-cambios.script.log
[08-memoria]: lab4/evidencia/spool/20261026T170646Z_08-memoria.spool.log
[08-cache]: lab4/evidencia/script/20261026T170648Z_08-experimento-cache.script.log
[08-parse]: lab4/evidencia/script/20261026T170652Z_08-parse-y-pga.script.log
[08-check]: lab4/evidencia/script/20261026T170836Z_08-verificacion-corregida.script.log
[08-reto]: lab4/evidencia/script/20261026T170654Z_08-reto-literales.script.log
[09]: lab4/evidencia/spool/20261026T170809Z_09-procesos.spool.log
[09-check]: lab4/evidencia/script/20261026T170853Z_09-verificacion.script.log
[09-reto]: lab4/evidencia/script/20261026T170801Z_09-reto-sesion.script.log
[10-usuarios]: lab4/evidencia/script/20261026T170853Z_10-que-ve-cada-usuario.script.log
[10-pdb]: lab4/evidencia/script/20261026T170902Z_10-ciclo-vida-pdb.script.log
[10-diccionario]: lab4/evidencia/spool/20261026T170901Z_10-diccionario.spool.log
[10-check]: lab4/evidencia/script/20261026T170931Z_10-verificacion.script.log
[11]: lab4/evidencia/spool/20261026T170936Z_11-archivos.spool.log
[11-real]: lab4/evidencia/script/20261026T171029Z_11-verificacion.script.log
[11-linux]: lab4/evidencia/script/20261026T171029Z_11-archivos-so-corregido.script.log
[11-alert]: lab4/evidencia/script/20261026T171035Z_11-alert-reinicio.script.log
[12]: lab4/evidencia/script/20261026T171051Z_12-bloque.script.log
[12-extra]: lab4/evidencia/script/20261026T171052Z_12-bloque-extra.script.log
[12-check]: lab4/evidencia/script/20261026T171133Z_12-verificacion.script.log
[13]: lab4/evidencia/script/20261026T171133Z_13-capacidad.script.log
[13-matriculas]: lab4/evidencia/script/20261026T171133Z_13-reto-matriculas.script.log
[13-check]: lab4/evidencia/script/20261026T171220Z_13-verificacion.script.log
[14]: lab4/evidencia/script/20261026T171221Z_14-filas-migradas.script.log
[15]: lab4/evidencia/spool/20261026T171318Z_15-autopsia-instancia.spool.log
[15-extra]: lab4/evidencia/script/20261026T171404Z_15-comprobaciones-adicionales.script.log
[16]: lab4/evidencia/script/20261026T171321Z_16-verificacion-final.script.log
[16-seguridad]: lab4/evidencia/script/20261026T171324Z_16-control-seguridad.script.log
