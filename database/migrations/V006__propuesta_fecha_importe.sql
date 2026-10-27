-- Propuesta experimental del reto G; no fusionar ni aplicar como diseño definitivo.
-- Q11: 5008 -> 3340 lecturas; 27 MiB adicionales, 3321 hojas.
-- INSERT: 24242 -> 28251 bloques/2000 filas; UPDATE importe: 12080 -> 20130.
-- IX_PED_FECHA es prefijo de este candidato: conservar ambos introduce redundancia.
-- Se rechaza añadirlo a la carga OLTP por el coste sostenido de escritura.
WHENEVER SQLERROR EXIT FAILURE
ALTER SESSION SET CONTAINER=FREEPDB1;
CREATE INDEX tiendasur.ix_ped_fec_importe_l5 ON tiendasur.pedido(fecha_pedido,importe) ONLINE;
EXIT
