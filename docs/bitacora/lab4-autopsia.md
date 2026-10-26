# Laboratorio 4 · Autopsia de la arquitectura

Autor: Pablo García Martínez. Fecha: 26 de octubre de 2026.

La inspección se realizó con `C##OPS_RO` desde SQLcl, usando SYSDBA únicamente para los cambios y experimentos. Los números siguientes pertenecen a esta ejecución en WSL, Oracle AI Database Free `23.26.3.0.0`.

## Identidad y estado comprobado

La instancia `FREE` está `OPEN/ACTIVE`, con último arranque a las 17:04 UTC; la base tiene DBID `1509902213`, es `PRIMARY`, está en `ARCHIVELOG`, `FORCE_LOGGING=YES` y `FLASHBACK_ON=NO`. `CDB$ROOT` y `FREEPDB1` están `READ WRITE`; `PDB$SEED`, `READ ONLY`. El cambio de contenedor Docker cambió el host de `26dddb590dba` a `8f2fc0e763a0`, conservando el DBID y las 14 tablas de negocio. Véanse [autopsia 15](lab4/evidencia/spool/20261026T171318Z_15-autopsia-instancia.spool.log), [persistencia 03](lab4/evidencia/script/20261026T170241Z_03-prueba-persistencia.script.log) y [verificación 14](lab4/evidencia/script/20261026T171314Z_14-verificacion.script.log).

## Hallazgos, riesgos y acciones

Prioridades: P1 antes de usar el entorno para datos importantes; P2 mejora operativa planificada; P3 seguimiento. Las acciones pendientes son recomendaciones, no operaciones ejecutadas del laboratorio 5.

| Sección / evidencia | Hallazgo propio | Riesgo | Acción y estado | Prioridad |
|---|---|---|---|---|
| 15 §4; [11, rutas reales](lab4/evidencia/script/20261026T171029Z_11-verificacion.script.log) | Dos control files, ambos bajo `/opt/oracle/oradata/FREE`, en el mismo volumen Docker. | La segunda copia ayuda frente a corrupción de un archivo, pero la pérdida del volumen afecta a ambas. | Planificar copias en dominios de fallo distintos; mantener la copia fría local ya validada. No se ha añadido almacenamiento. | P1 |
| [11, redo y alert](lab4/evidencia/script/20261026T171035Z_11-alert-reinicio.script.log) | Tres grupos de redo de 200 MiB, con `MEMBERS=1` en cada grupo. | No hay miembro alternativo si se pierde un archivo; todos comparten volumen. | Planificar multiplexación y validar recuperación antes de producción. No ejecutado aquí. | P1 |
| 15 §4 y [11, Linux corregido](lab4/evidencia/script/20261026T171029Z_11-archivos-so-corregido.script.log) | ARCHIVELOG activo; cinco archived logs, unos 525 MiB, en `dbconfig/FREE/dbs`; FRA sin configurar y tamaño 0. | El archivado existe, pero no hay una política demostrada de espacio, retención y recuperación. | Vigilar crecimiento del volumen y definir esa política en el trabajo posterior. No cambiar a NOARCHIVELOG. | P1 |
| 15 §4 y 11 Linux §4 | ADR en `/opt/oracle/diag`, fuera del volumen; el directorio tenía unos 29 MiB. La imagen también incluye mensajes de julio anteriores a esta ejecución. | Recrear el contenedor pierde los diagnósticos generados en su capa; los mensajes heredados pueden confundirse con incidentes actuales. | Exportar logs de forma periódica o persistir ADR por separado y filtrar por fecha. Se han conservado las evidencias actuales. | P2 |
| 15 §10; [15, contraste](lab4/evidencia/script/20261026T171404Z_15-comprobaciones-adicionales.script.log) | Seis entradas ORA en 24 h: cuatro `ORA-00800`, una `ORA-65025` y una `ORA-959`. | Mezclar denegaciones de prueba con fallos operativos produce falsas alarmas. | `ORA-65025` corresponde al DROP deliberado de una PDB abierta; `ORA-959`, al DROP IF EXISTS previo al banco L. `ORA-00800` informa de `Set Priority Failed` en VKTM/LGWR: investigar permisos/prioridades del contenedor antes de producción. No atribuirlo a pérdida de datos. | P2 |
| 15 §6; contraste 15 | Academia: nueve índices, altura máxima 2, dos con CF cercano al número de filas y cero inválidos. Otros cuatro esquemas tienen 11 tablas sin estadísticas. | El CF debe interpretarse por consulta; las estadísticas ausentes dificultarán las estimaciones cuando se carguen esos esquemas. | Recoger estadísticas después de cargas reales y evaluar planes antes de modificar índices. No se ha hecho el laboratorio 5. | P3 |
| 15 §5; [03, reubicación](lab4/evidencia/script/20261026T170159Z_03-reubicar-datafiles.script.log) | Los cinco datafiles de negocio están ONLINE en `FREE/FREEPDB1`, 100 MiB iniciales, AUTOEXTEND de 50 MiB y MAXSIZE de 1 GiB. Academia usa 23 MiB, 2,3 % del máximo. | El porcentaje respecto al máximo no equivale al espacio libre real del sistema de archivos. | Reubicación y límites aplicados; seguir comprobando consumo del volumen y crecimiento, además del porcentaje Oracle. | P3 |
| [03, OMF](lab4/evidencia/script/20261026T170623Z_03-reto-omf.script.log); contraste 15 | `DB_CREATE_FILE_DEST=/opt/oracle/oradata/FREE/FREEPDB1` en la PDB, con SCOPE=BOTH; el valor de la raíz sigue vacío. El tablespace sonda generó un archivo OMF dentro del volumen y se eliminó. | Una ruta relativa explícita todavía puede eludir OMF; no basta con configurar el destino. | Usar OMF omitiendo DATAFILE o exigir rutas absolutas revisadas. El ajuste es de FREEPDB1, no global del CDB. | P3 |
| 15 §7; [04, credenciales](lab4/evidencia/script/20261026T170410Z_04-credenciales.script.log) | Cinco propietarios ADMIN_* con `AUTHENTICATION_TYPE=NONE`; sus credenciales históricas son rechazadas. SYS tiene contraseña rotada. C##OPS_RO solo hereda CREATE SESSION y SET CONTAINER como privilegios de sistema; SELECT_CATALOG_ROLE y el SELECT puntual permiten observar. | Reintroducir una cuenta DBA para monitorizar ampliaría innecesariamente el impacto de un error. | Mantener autenticación local de SYSDBA para cambios y observabilidad separada; no publicar `.env` ni el password file. | P2 |

## Memoria, bloques y datos

ASMM gestiona la SGA: `memory_target=0`, `memory_size=0`, `sga_target=1536M`; PGA automática con objetivo 512 MiB. La autopsia registró 441 MiB de PGA asignada y un máximo de 533 MiB: son medidas de ese instante, no límites fijos. La caché caliente pasó de 262 lecturas físicas a cero. Los 1.000 textos con literales ocuparon 38.845 KiB de shared pool; un único cursor con bind, 39 KiB. La ordenación manual de 64 KiB necesitó seis pasadas y 2.048 KiB de TEMP, frente a OPTIMAL con gestión automática. [Memoria y parse](lab4/evidencia/script/20261026T170652Z_08-parse-y-pga.script.log).

La fila 101 tiene ROWID `AAAR2mAAAAAAAMLAAF`: objeto 73126, archivo absoluto 24, bloque 779 y ranura 5. El bloque contiene 90 filas y 865 bytes libres (`0x427-0xc6=0x361`); su fila ocupa 78 bytes. El bloque 1174 de la fila 19501 contiene 85 filas, 826 bytes libres y una fila de 83 bytes. Ambos conservan una ITL `--U-`, compatible con limpieza diferida tras el commit. No se ha copiado el bloque 782 del ejemplo del profesor. [Verificación de ambos volcados](lab4/evidencia/script/20261026T171133Z_12-verificacion.script.log).

Los datos finales son 20.000 estudiantes, 40 asignaturas y 60.000 matrículas, sin matrículas huérfanas. La migración de prueba pasó de 1.000 filas migradas a cero; el índice quedó VALID antes de eliminar el banco. La comprobación posterior encontró cero usuarios, PDB, tablespaces y segmentos temporales de prueba, y cero índices de negocio inválidos. [04](lab4/evidencia/script/20261026T170416Z_04-verificacion.script.log), [14](lab4/evidencia/script/20261026T171221Z_14-filas-migradas.script.log).

## Resumen para el responsable

El entorno conserva los datos y supera la verificación técnica final; las credenciales expuestas de los propietarios ya no permiten iniciar sesión.

Los principales riesgos pendientes son la concentración de archivos críticos en un único volumen y la falta de una política demostrada de conservación de archivos de redo y diagnósticos.

Es adecuado para continuar el curso; esos riesgos deben resolverse antes de considerarlo un despliegue de producción.
