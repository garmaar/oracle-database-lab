# Laboratorio 5 v3 · Autorrevisión técnica

Autor y responsable: **Pablo García Martínez**. Fecha: 27 de octubre de 2026. Modalidad: autorrevisión técnica con consultas de estado, inspección de salidas y comprobaciones automatizadas.

La revisión cruzada de otro compañero no se ha realizado. No se utiliza otra identidad ni se simulan aprobaciones externas. La entrega identifica esta modalidad y su aceptación corresponde al profesor.

## Fuente y alcance

Se utiliza el enunciado **v3 de 21 de octubre de 2026**, PDF de 150 páginas de la carpeta «Labs 4-5 v3 - Estudiante», y su repo-kit. Se localizó también el PDF independiente de Descargas, de 100 páginas; no se mezclan instrucciones de ambas versiones. Se comprueban Partes A–Q, preguntas, retos profesionales, checklist y rúbrica del v3.

Se conserva el Lab 4 entregado: PR #5 fusionado, etiqueta lab4-final en 984b9e0, copia original lab3-final y copia lab4-final. No se reescriben V000–V003 ni sus evidencias.

## Comprobaciones y correcciones

| Área | Comprobación real | Resultado |
|---|---|---|
| Docker / prerrequisitos | Contenedor, volumen, salud y verificador del Lab 4 antes de empezar. | Docker 29.8.0, 12 CPU, unos 7,6 GiB RAM; Oracle healthy y Lab 4 TODO OK. |
| Copia inicial | Se reutiliza la copia fría del usuario de hoy y se comprueban SHA-256 y gzip. | lab4-final `20261027T165012Z`, unos 690 MiB, commit 984b9e0, cero archivos externos al volumen. No se repite su creación. |
| Banco | COUNT reales, relaciones, paquete compilado y permisos. | 100.000 clientes, 1.000.000 pedidos, cero huérfanos, MEDIR y cuerpo VALID; propietarios sin autenticación. |
| Anatomía | Plan real, INDEX_STATS, treedump, raíz/hoja y ROWID de cliente 1. | Búsqueda PK: 4 lecturas con tabla, 3 cubierta. Entrada apunta a bloque 795/ranura 0. Gráficos y traza completa en evidencia 02. |
| Estimación | Comparar hipótesis de email con estructura real. | Se estiman dos niveles bajo las hipótesis del reto y se observan tres; no se altera el resultado para hacerlo coincidir. |
| Tipos / sargabilidad | Medidas de lecturas antes/después y consulta del catálogo tras limpieza. | Las pruebas temporales se eliminan; 100.000/1.000.000 filas conservadas y cero errores del paquete. El reto de reescritura tiene MINUS=0 en ambos sentidos, aunque no mejora lecturas. |
| Agrupamiento | CF calculado con ROWID/LAG y curva de doce porcentajes. | CF 5.220/999.041 coincide con diccionario. CSV y SVG logarítmico distinguen cruces medidos y decisión del optimizador. |
| Diseño | Escenarios con cuatro, nueve y cinco índices; monitorización y prueba INVISIBLE. | INSERT 10,157 / 20,186 / 12,121 bloques modificados por fila. V005 justificada en su cabecera con estas evidencias. |
| Candidato V006 | Crear, medir, retirar y verificar; conservar propuesta en rama aparte. | Q11 5.008→3.340 lecturas, a costa de más DML y 27 MiB. Candidato retirado, no fusionado. Descripción preparada en lab5-propuesta-v006.md. |
| Texto UTF-8 | Se inspeccionaron los bytes reales de apellidos, no solo la apariencia del terminal. | 65.616 filas tenían U+FFFD. Se fija NLS_LANG del cargador y se repara mediante V004_1, con cero caracteres de reemplazo posteriores. V004 aplicada permanece intacta; se documenta qué medidas son anteriores a esta corrección. |
| Patrón cola | Gráficos, INDEX_STATS y acceso al siguiente mensaje antes/después. | COALESCE: 425→201 hojas y 226→2 lecturas; SHRINK 4→1,69 MiB; REBUILD no mejora esas dos lecturas. LAB5_PRUEBAS y sus segmentos se eliminan. |
| SCN / MTTR | Cabeceras frente a control file; consulta sin checkpoint tras carga. | Checkpoint sincronizado. Redo pendiente 487.029→490.692; MTTR permanece 19 s. No se inventa un incremento del estimador. |
| Control files | Copia con base cerrada, hashes y valores efectivos/persistidos. | Tercera copia idéntica a la sana antes de abrir; tres activas después y CDB/PDB READ WRITE. |
| Redo | Tres grupos y seis rutas, estados y comprobación posterior. | Un miembro queda INVALID en el primer intento; checkpoint y rotación acotada lo inicializan. Se repite la comprobación afectada y da cero INVALID/STALE. |
| DROP de demostración | Se revisa si la operación del kit sería realmente ilegal. | El tercer DROP no se ejecuta con tres grupos: quitar uno dejaría dos y podría ser válido. Se conserva el número de grupos y se explica la desviación del kit, sin inventar ORA-01567. |
| FRA | Ruta/tamaño, agotamiento de 2 MiB y posterior archivado. | ORA-19802, ORA-19815/19809/16038 esperados; 4 GiB restaurados en memoria y SPFILE, archivado funcionando. |
| Undo / consistencia | Dos sesiones simultáneas, locks, valor previo, flashback y rollback. | Lectura no bloqueada; FOR UPDATE denegado; fila 101 restaurada, cero errores de falta de undo/snapshot y recuentos intactos. |
| WAL | Estadísticas antes de COMMIT y después de checkpoint. | COMMIT: 8.370 KiB redo, 0 escrituras de caché y 231 buffers de tabla sucios; checkpoint: 0 buffers sucios. Se distingue actividad global de la específica de la tabla. |
| Fallos A/B | Reloj, estados intermedios, alert log y consultas tras reparación. | A: 9 s, RPO confirmado 0; 102 conservada y 103 deshecha. B: 6 s desde pérdida, 5 s reparación, RPO 0; se recupera control03 desde copia sana. |

## Salvaguardas de los simulacros

Los cuatro simulacros se ejecutan en orden. C crea su propia copia previa y la valida antes de DROP; conserva la salida completa de copia y restauración. D valida la copia RMAN y restringe el archivo víctima a la ruta de Academia antes de borrarlo, y comprueba el COMMIT posterior al backup antes de devolver la fila de control a ACTIVO. Se añadió cronometraje explícito a A y B y comprobación de las filas confirmadas/no confirmadas.

No se repite una pérdida, caída o restauración únicamente para volver a comprobarla. Las verificaciones posteriores son consultas y comprobaciones de archivos/metadatos. Los fallos y comprobaciones inicialmente fallidas se mantienen como evidencia junto a sus correcciones.

## Requisitos externos diferenciados

El reto H pide un índice ciego creado por el profesor. No se recibió un caso externo de ese tipo: se diagnosticó el caso reproducible del kit y se publicó un comentario en el Issue indicando expresamente su procedencia. No se atribuye al profesor ni a un compañero un experimento que no proporcionaron.

La autorrevisión es la modalidad de esta entrega; no equivale a una revisión cruzada por otra persona. El candidato V006 está separado y rechazado, y su descripción de PR no es una revisión externa ni una migración del diseño final.

## Resultados de recuperación y cierre técnico

C recuperó las 60.000 matrículas y el banco TiendaSur completo, con **390 s** de restauración. Su ventana de 3 s del guion se toma tras validar la copia y no se presenta como un RPO exacto desde el checkpoint. D validó su backup RMAN, restauró el archivo 24 y recuperó la fila 104 con su COMMIT posterior al backup: **12 s desde el fallo, 11 s de reparación, RPO 0 demostrado**. Oracle cerró FREEPDB1 por ORA-63999; se reparó montada y se reabrió. La consulta posterior encuentra cero recuperación pendiente y cero apellidos dañados.

El [verificador 16](lab5/evidencia/script/20261027T173645Z_16-verificacion-final.script.log) termina **TODO OK**. La [comprobación adicional](lab5/evidencia/script/20261027T173755Z_15-verificacion-adicional.script.log) confirma cero miembros redo inválidos y cero cabeceras con ERROR/RECOVER pendiente. El alert log conserva errores de los simulacros: se han clasificado, no borrado. FRA al 2,4 %, cero errores de undo y ninguna alerta de FRA >85 %.

Se prepararon **22 respuestas de comprobación y 53 preguntas tipo examen** (27 intercaladas y S1–S26), con citas a valores propios; hay SVG y CSV de la curva, gráficos de hojas, volcado completo y runbook de datafile. La equivalencia de reescrituras y los cálculos se contrastan con las salidas reales. F2 se explica con su hipótesis de precisión temporal, en lugar de afirmar dos equivalencias universales.

Para la copia final se permite elegir el nivel de gzip mediante BACKUP_GZIP_LEVEL (1–9, predeterminado 6). Se elige nivel 1 para reducir tiempo de compresión; se conservan el mismo cierre limpio, contenido completo, propietarios/permisos, manifiesto y SHA-256. Un valor inválido se rechaza antes de tocar Oracle. La copia final se valida después de crearla; no se reemplaza por renombrar una copia anterior.

## Entrega y flujo de GitHub

Issue: [#6](https://github.com/garmaar/oracle-database-lab/issues/6). Entrega: [Pull Request #7](https://github.com/garmaar/oracle-database-lab/pull/7). Rama principal del trabajo: `chore/5-oracle-dba-workflow-ii`. Hay un commit por Parte A–Q y una corrección UTF-8 separada. La [rama de V006](https://github.com/garmaar/oracle-database-lab/tree/experiment/lab5-v006-fecha-importe) conserva el candidato rechazado; no se fusiona su migración. La [descripción preparada para esa propuesta](lab5-propuesta-v006.md) documenta la decisión.

El cierre de entrega comprende PR con merge commit, etiqueta [lab5-final](https://github.com/garmaar/oracle-database-lab/tree/lab5-final) sobre el estado fusionado y copia fría final conservada localmente. El PR y la etiqueta permiten consultar la versión entregada cuando avance main. La descripción del PR recoge el estado de revisión, las verificaciones y la validación de la copia final.

**En Canvas se entrega el enlace https://github.com/garmaar/oracle-database-lab/pull/7**, que reúne scripts, migraciones, evidencias, respuestas, retrospectiva y esta autorrevisión. No se adjunta la copia de la base ni el archivo de credenciales.

**Revisión técnica: realizada como autorrevisión de Pablo García Martínez.** Revisión cruzada externa y caso ciego externo de H no proporcionados, diferenciados del trabajo reproducible completado. No se marcan como aprobaciones de terceros. No entregar .env, backups, piezas RMAN, control files, datafiles ni trazas nativas `.trc`; las trazas de texto exportadas llevan extensión `.trc.txt`.
