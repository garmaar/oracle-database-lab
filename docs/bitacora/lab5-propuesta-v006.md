# Reto G · Descripción de PR propuesta, no fusionada

Autor: Pablo García Martínez. Rama: `experiment/lab5-v006-fecha-importe`. Migración experimental: `V006__propuesta_fecha_importe.sql`. La propuesta se conserva aparte y no forma parte del diseño final de V005.

## Título propuesto

`experiment(db): evaluate a covering date/amount index for Q11`

## Problema y comportamiento medido

Q11 suma el importe de un año completo. Con V005, Oracle usa un INDEX FAST FULL SCAN del cubriente existente y mide **5.008 lecturas**. El candidato `(fecha_pedido, importe)` reduce la lectura a **3.340**, también mediante fast full scan, con **27 MiB** y **3.321 hojas** adicionales.

## Las cinco preguntas

1. **Necesidad:** hay una consulta demostrada, pero no una frecuencia observada de informes que justifique el coste permanente en la carga OLTP.
2. **Viabilidad:** no se busca una fila muy selectiva. La mejora procede de leer una estructura cubriente más estrecha; no prueba que el rango de un año sea barato por sí mismo.
3. **Escritura:** para 2.000 INSERT, los bloques modificados pasan de **24.242 a 28.251** (12,121 a 14,126 por fila). UPDATE de importe pasa de **12.080 a 20.130** y su redo de **1.586 a 2.535 KiB**.
4. **Redundancia:** IX_PED_FECHA es prefijo del candidato. Sustituirlo sería una propuesta diferente que requeriría medir de nuevo Q2/Q8/Q9; no se supone gratis ni se ha hecho.
5. **Ciclo de vida:** se creó temporalmente, se midió y se eliminó; la comprobación posterior encuentra cero candidatos y exactamente los cinco índices de PEDIDO definidos por V005.

## Decisión

**No fusionar.** La reducción observada de 1.668 lecturas por ejecución no demuestra que compense el mantenimiento en una carga con muchas escrituras. La decisión podría revisarse si se midiera una frecuencia suficiente de Q11, con una prueba de carga completa y un plan de retirada.

## Validación

Evidencias `06-reto-propio`, `06-dml-candidato`, `06-quitar-candidato` y `06-verificacion-candidato` en `lab5/evidencia/script/`. La migración se guarda en la rama separada para inspección; el índice está retirado del entorno. Este texto es la descripción preparada para el reto, no una aprobación de un tercero.
