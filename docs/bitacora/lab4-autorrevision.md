# Laboratorio 4 v3 · Autorrevisión técnica

Autor y responsable: **Pablo García Martínez**. Fecha: 26 de octubre de 2026.

**Estado de la revisión técnica: realizada.** Modalidad: autorrevisión con consultas y comprobaciones automatizadas sobre el repositorio y Oracle.

No disponía de otro compañero para realizar la revisión cruzada. Se ha realizado una autorrevisión técnica. La revisión por un compañero queda pendiente. La aceptación de esta alternativa corresponde al profesor. Este informe no representa una aprobación de otra persona.

## Alcance y método

Se contrastó el PDF «P1_Lab 4 Oracle DBA Workflow I v3 - Estudiante», versión de 21 de octubre de 2026, con los archivos del kit, la salida de cada ejecución y consultas posteriores. Se revisaron Partes A–O, retos profesionales, preguntas de comprobación, preguntas tipo examen y checklist del apartado 10. El laboratorio 5 queda fuera de este trabajo.

Las evidencias son salidas reales. Los resultados de consultas posteriores se conservan junto a las ejecuciones originales; los errores corregidos no se han ocultado. No se ha repetido el backup, la recreación del contenedor, el arranque por etapas, la creación de la PDB ni el banco de migración únicamente para comprobarlos.

## Resultado por parte

| Parte | Comprobación realizada | Resultado y evidencia |
|---|---|---|
| A | Revisar cierre limpio, manifiesto, integridad y lectura del comprimido existentes; volver a comprobar SHA-256 con el verificador final. | Backup `20261026T163058Z_lab3-final`, 630 MiB aproximados, procedimiento de 182 s, commit de origen 03321af. No se ha medido restauración/RTO. [00](lab4/evidencia/script/20261026T163053Z_00-backup-lab3-final.script.log). |
| B | Conectar desde SQLcl y consultar permisos y CONTAINER_DATA. | C##OPS_RO común, SELECT_CATALOG_ROLE, CREATE SESSION y SET CONTAINER; ve 4/3/9 datafiles. [02](lab4/evidencia/script/20261026T165439Z_02-verificacion.script.log). |
| C | Contrastar rutas y ONLINE; recrear una vez el contenedor; revisar volumen, objetos y puertos; probar OMF con una sonda. | Cinco datafiles en FREE/FREEPDB1, MAXSIZE 1 GiB, 14 tablas conservadas; solo puerto 1521. OMF efectivo en FREEPDB1; sonda eliminada. [03](lab4/evidencia/script/20261026T170317Z_03-verificacion.script.log), [OMF](lab4/evidencia/script/20261026T170623Z_03-reto-omf.script.log). |
| D | Comprobar autenticación de propietarios, rechazo real de las cinco credenciales antiguas, conexión con SYS rotado, recuentos, referencias y segunda ejecución idempotente de V002. | NONE en cinco cuentas; ORA-01017 en cinco conexiones antiguas; 20.000/40/60.000 filas y cero matrículas huérfanas. [04](lab4/evidencia/script/20261026T170416Z_04-verificacion.script.log), [credenciales](lab4/evidencia/script/20261026T170410Z_04-credenciales.script.log). |
| E | Observar instancia y SO, NOMOUNT/MOUNT/OPEN y alert log; consultar apertura final. | ORA-01507/01219 esperados; CDB/PDB READ WRITE y SAVE STATE efectivo. [06](lab4/evidencia/script/20261026T170449Z_06-arranque-por-etapas.script.log), [sonda](lab4/evidencia/script/20261026T170501Z_06-verificacion.script.log). |
| F | Contrastar memoria/SPFILE, revertir experimentos y consultar desde una nueva sesión en raíz y PDB. | OPEN_CURSORS=300 en ambos; DB_FILES=200 sin especificación pendiente; PFILE de SPFILE y de memoria exportados. [07](lab4/evidencia/script/20261026T170623Z_07-verificacion.script.log). |
| G | Revisar rondas de caché, estadísticas de parse, V$SQL, work areas y estado de una sesión nueva. | 262→0 físicas, 1.000→1 cursores; OPTIMAL frente a 6 PASSES/2.048 KiB TEMP; política AUTO conservada. [08](lab4/evidencia/script/20261026T170836Z_08-verificacion-corregida.script.log). |
| H | Cruzar SPID con /proc y PID del host; observar una consulta activa y comprobar su finalización. | LGWR SPID=857/PID host=6880. Sesión de carga SID=21/SPID=1514/PGA usada=3,71 MiB; después cero sesiones LAB4_CPU. [09](lab4/evidencia/script/20261026T170853Z_09-verificacion.script.log), [carga](lab4/evidencia/script/20261026T170801Z_09-reto-sesion.script.log). |
| I | Revisar denegaciones esperadas y consultar restos después de eliminar usuarios y PDB. | ORA-00942/01031/41900/65096/65094/65025 explicados; cero usuarios/PDB de prueba; carpeta física eliminada. [10](lab4/evidencia/script/20261026T170931Z_10-verificacion.script.log). |
| J | Comparar inventario SQL con stat/readlink; comprobar acceso real al alert log. | 16 datafiles, 3 tempfiles, 2 control files, 3 miembros redo. Todas las rutas reales inventariadas dentro del volumen. ADR fuera. [11](lab4/evidencia/script/20261026T171029Z_11-verificacion.script.log). |
| K | Cruzar DBMS_ROWID y dos trazas; recalcular espacio libre independientemente. | Fila 101 en archivo 24/bloque 779/ranura 5, 78 bytes; fila 19501 en bloque 1174/ranura 78. Dos identidades avsp=fseo−fsbo correctas. [12](lab4/evidencia/script/20261026T171133Z_12-verificacion.script.log). |
| L | Revisar fórmulas y salidas; consultar filas, índice, tablespace y conservación de negocio antes de M. | Banco de 400.000 filas, índice VALID, archivo dentro del volumen y límite 512 MiB. Cálculos de matrículas y umbral HDD documentados. [13](lab4/evidencia/script/20261026T171220Z_13-verificacion.script.log). |
| M | Revisar CHAIN_CNT antes/después y estado del índice; consultar restos tras limpieza y ausencia del archivo físico. | 1.000 migradas, 3,2 lecturas/búsqueda; tras MOVE/REBUILD, cero migradas e índice VALID. Después cero usuarios, PDB, tablespaces, segmentos de prueba e índices de negocio inválidos. [14](lab4/evidencia/script/20261026T171314Z_14-verificacion.script.log). |
| N | Ejecutar autopsia como C##OPS_RO, contrastar permisos heredados, errores y configuración por PDB; ejecutar 16. | [Autopsia](lab4-autopsia.md) basada en resultados propios; [16](lab4/evidencia/script/20261026T171321Z_16-verificacion-final.script.log) termina TODO OK. |
| O | Revisar respuestas, seguridad, historia por parte y flujo de GitHub. | 38 respuestas de comprobación y 49 de examen, con evidencias. Autorrevisión realizada; el estado de revisión cruzada y fusión se distingue expresamente abajo. |

## Correcciones detectadas y comprobadas

1. El último bloque de la sesión anterior no estaba ejecutado: no existía C##OPS_RO ni el commit A. Se verificó el estado real antes de continuar y se completaron ambos.
2. Se adaptó el contenedor para reutilizar el volumen sin pasar credenciales y sin publicar 8181. La inspección posterior encontró **cero variables de contraseña con valor**, un montaje de volumen y solo el puerto 1521.
3. Los archivos heredados estaban dentro del volumen mediante un enlace, no fuera de él. Se corrigieron las rutas estándar y la explicación para reflejar esa diferencia real.
4. El listado del kit de `dbs` mostraba el enlace y omitía sus archivos; se añadió la inspección del contenido con barra final y mayor profundidad. Se repitió el inventario de solo lectura y se localizaron SPFILE/password file dentro del volumen.
5. Una comprobación auxiliar usó SET SQLFORMAT en SQL*Plus, que respondió SP2-0158. Se retiró esa opción y se repitió la consulta: [comprobación corregida](lab4/evidencia/script/20261026T170836Z_08-verificacion-corregida.script.log). No se repitieron los experimentos de caché o parse por ese motivo.
6. Se reforzaron los ejecutores para que fallen ante errores SQL/OS no previstos, sin imprimir credenciales, y se fijó UTF-8 en el ejecutor SYSDBA. Durante una carga ya en ejecución, actualizar su envoltorio produjo un aviso de fin de archivo en el shell; el SQL terminó y registró 179.940.000 filas. Se comprobó sintaxis del envoltorio, ejecución posterior correcta y ausencia de la sesión de carga, sin repetirla.
7. El reto OMF se aplicó en un commit separado. Se documentó que la raíz mantiene destino vacío y que OMF no impide una ruta relativa explícita.
8. Se usaron los bloques propios 779 y 1174, en lugar del 782 del ejemplo. Se recalcularon ROWID, offsets, filas, tamaños y ambos espacios libres.
9. Se separó el tiempo de copia de un RTO no medido; se distinguieron MB decimales y MiB en los cálculos de I/O.
10. Se clasificaron los errores del alert log por fecha y causa. ORA-65025 y ORA-959 proceden de pruebas; ORA-00800 de prioridades sigue siendo un hallazgo operativo. No se declaró el alert log libre de errores por el hecho de pasar 16.

## Seguridad y conservación de las migraciones

[Control de seguridad](lab4/evidencia/script/20261026T171324Z_16-control-seguridad.script.log): cero coincidencias de las credenciales locales vigentes ORACLE_PWD, OPS_RO_PWD, APP_USER_PWD y ORDS_PUBLIC_PWD en archivos versionados y blobs de todo el historial local examinado. Cero rutas `config/.env`, `backups/` o archivos `.tar.gz` en el índice y en los objetos históricos. Cero cláusulas de contraseña literal en las evidencias del Lab 4.

V000 y V001 se compararon byte a byte con el commit `03321af`: **idénticas**. V000 contiene credenciales históricas que ya no son utilizables; la solución aplicada es V003, no reescribir esa migración o afirmar que nunca hubo literales. La copia fría se conserva localmente e ignorada por Git, junto con su inventario y manifiesto.

## Checklist de archivos y contenido

- [x] Scripts ops requeridos y scripts 01–16 del kit del Lab 4.
- [x] V002/V003 presentes; V000/V001 sin cambios.
- [x] Evidencias reales no vacías de todos los números 00–16.
- [x] `config/initFREE_lab4.ora` y `initFREE_lab4_memoria.ora` dentro de la carpeta de evidencia.
- [x] Volcado completo del bloque de la fila 101 y volcado adicional del reto.
- [x] Respuestas: 38 preguntas de comprobación, P1–P46 y P-D1/P-G1/P-G2; retos profesionales incluidos.
- [x] Autopsia: valores propios, riesgo, acción, prioridad y resumen para el responsable.
- [x] `16-verificacion-final.sh` sin fallos y consultas adicionales de estado coherentes.
- [x] Cuenta de observación sin privilegios heredados de escritura; cuentas temporales, PDB, banco y archivo de pruebas eliminados.
- [x] `.env.example` con valores vacíos y `.env` real ignorado.
- [x] Seguridad sobre archivos e historial, sin publicar backup ni credenciales vigentes.

## GitHub y pendientes

Issue: [#4](https://github.com/garmaar/oracle-database-lab/issues/4). Pull Request: [#5](https://github.com/garmaar/oracle-database-lab/pull/5), hacia `main` desde `chore/4-oracle-dba-workflow-i`. La historia contiene commits separados de A a N, el de respuestas O y el ajuste OMF del reto C en su propio commit. `lab3-final` identifica `03321af` y se ha publicado en GitHub.

La revisión técnica de este informe está realizada. No se ha utilizado otra identidad, no se han creado comentarios atribuidos a compañeros y no existe una aprobación externa que pueda darse por recibida. El PR identifica la revisión como autorrevisión de Pablo García Martínez y enlaza este informe.

La validación documental final comprobó los enlaces y todos los números de evidencia; la auditoría de seguridad se repitió con los documentos añadidos al índice. El [verificador de entrega](lab4/evidencia/script/20261026T172827Z_16-verificacion-entrega.script.log) volvió a terminar TODO OK. [Revisión documental](lab4/evidencia/script/20261026T172827Z_16-revision-documental.script.log) y [seguridad previa a publicación](lab4/evidencia/script/20261026T172827Z_16-seguridad-prepublicacion.script.log).

Se comprobó sintaxis de todos los scripts Bash y formato de código/documentación. Los logs y volcados nativos contienen espacios de alineación y líneas finales tal como los emitieron SQLcl/Oracle: se conservan sin reformatear para mantener la evidencia original.

El cierre de entrega comprende la fusión del PR mediante merge commit, el cierre automático del Issue y la publicación de [lab4-final](https://github.com/garmaar/oracle-database-lab/tree/lab4-final) sobre el resultado fusionado. Los enlaces del PR, Issue y etiqueta permiten comprobar el estado final en GitHub.

La entrega incluye la autorrevisión técnica realizada por Pablo García Martínez. La revisión cruzada de otra persona no se ha realizado y no se marca como cumplida. Esta diferencia respecto al enunciado permanece explícita; la aceptación de la modalidad de revisión corresponde al profesor.

## Entrega en Canvas

Entregar en Canvas: **https://github.com/garmaar/oracle-database-lab/pull/5**. Es el artefacto principal del enunciado y reúne código, evidencias e informes. El informe de autorrevisión es documentación complementaria y no sustituye el PR. La entrega debe advertir el estado real de la revisión cruzada y de la fusión. No se debe adjuntar `config/.env`, el backup ni el password file.
