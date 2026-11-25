# Guardia nocturna · Lab 6 · E028

## INC-601 · Bloqueo de fila en ACA_ESTUDIANTES
- **Detección:**  Se detecta a las 11:07 UTC gracias al 20261124T110701Z_08-guardia-1.script.log
- **Impacto:** El usuario ANA GARCIA no puede guardar los cambios sobre la ficha de un alumno durante aproximadamente 1 minuto y 35 segundos. De 11:07:01Z a 11:08:35Z
- **Diagnóstico:** El diagnostico se ha realizado con 20261124T110708Z_08-diagnostico-1.script.log, con C##OPS_RO. ANA_GARCIA (SID 219) esperaba en enq: TX - row lock contention sobre ACA_ESTUDIANTES, bloqueada por APP_ACADEMIA (SID 64, SERIAL# 14523), que estaba en PL/SQL lock timer con 1 bloque y 1 registro de undo (USED_UBLK=1, USED_UREC=1).
- **Causa raíz:** La causa raíz es un proceso de matrículas llamado cierre-periodo, que dejó una transacción abierta sin commit o rollback mientras quedaba en espera, reteniendo el bloqueo de la fila por concurrencia normal en Oracle.
- **Intervención:** La intervención se realizó con 20261124T110835Z_08-resolucion-1.script.log, usando ALTER SYSTEM KILL SESSION '64,14523' IMMEDIATE; Es la intervención mínima, ya que solo mata la sesión que está bloqueando el proceso y nada más.
- **Validación:** Con 20261124T110838Z_08-verificacion-1.script.log y 09-verificacion-final.sh vemos que hay 0 bloqueos y 0 sesiones esperando en V$SESSION y en V$LOCK, y que el alumno 101 quedó en estado ACTIVO.
- **Acción preventiva:** Una acción para prevenir esto podría ser el evitar pausas o evitar esperas usando transacciones abiertas en el código de matriculas, y añadir una alerta o un timeout para transacciones inactivas que estén bloqueando a otras sesiones.

## INC-602 · Servicio academia_app parado (ORA-12514)
- **Detección:** Se detectó a las 11:09 UTC gracias al 20261124T110905Z_08-guardia-2.script.log
- **Impacto:** El impacto es absolutamente crítico, toda la aplicación de matrículas quedaba sin conexión durante aproximadamente 3 minutos, de 11:09:05Z a 11:12:11Z.
- **Diagnóstico:** El diagnostico se ha realizado con 20261124T110905Z_08-diagnostico-2.script.log, con C##OPS_RO, salía que la base no estaba caída, pero en la sección 6, en CON_ID = 3, FREEPDB1 está ARRANCADO = SI, pero la academia_app salía en ARRANCADO = NO, el listener no lo anunciaba, devolviendo ORA-12514
- **Causa raíz:** La causa principal era que el servicio academia_app se detenía dentro de FREEPDB1, lo que hacía que se dejase de registrar dinámicamente en el listener aunque la PDB siguiera abierta.
- **Intervención:** La intervención se realizó con 20261124T111211Z_08-resolucion-2.script.log, que hacía ALTER SESSION SET CONTAINER = FREEPDB1; EXEC DBMS_SERVICE.START_SERVICE('academia_app'); Es la mínima modificación para devolver el servicio porque no reiniciamos la instancia, solo levantamos el servicio que se ha caído.
- **Validación:** Se valida con 20261124T111212Z_08-verificacion-2.script.log. En la sección 6 del diagnóstico ahora aparece academia_app con ARRANCADO = SI
- **Acción preventiva:** Una acción que podríamos implementar para prevenir este problema podría ser añadir una comprobación automática de servicios definidos frente a servicios realmente activos, en la monitorización de turno.

## INC-603 · Cuenta APP_ACADEMIA bloqueada (ORA-28000)
- **Detección:** Se detecta a las 11:12 UTC, gracias al 20261124T111252Z_08-guardia-3.script.log. Se detecta un error ORA-28000, la aplicación no entra, sin haber cambiado ninguna contraseña.
- **Impacto:** Es un impacto alto, la aplicación de matriculas no puede autenticarse ni operar durante 1 minuto y 20 segundos, desde las 11:12:52Z hasta las 11:14:11Z.
- **Diagnóstico:** El diagnóstico lo realizamos con 20261124T111252Z_08-diagnostico-3.script.log, con C##OPS_RO: En la sección 7 vemos que en el CON_ID = 3, aparece que APP_ACADEMIA tiene ACCOUNT_STATUS = LOCKED. Es un bloqueo manual, no LOCKED(TIMED) por intentos fallidos, lo que prueba que fue el script y no una contraseña errónea.
- **Causa raíz:** La causa raíz es que el script del trimestre de bajas no distingue entre las cuentas nominales de personas, PRF_PERSONAS y las cuentas de aplicación, APP_ACADEMIA, lo que resulta en bloqueos de una cuenta de servicio por error.
- **Intervención:** La intervención viene de la mano de 20261124T111411Z_08-resolucion-3.script.log, se hace un ALTER SESSION SET CONTAINER = FREEPDB1; ALTER USER app_academia ACCOUNT UNLOCK; Resulta el mínimo cambio porque únicamente desbloquea la cuenta sin cambiar contraseñas o tocar nada que no sea eso.
- **Validación:** Se valida con 20261124T111412Z_08-verificacion-3.script.log, La sección 7 ahora queda vacía, con 0 cuentas bloqueadas, y la aplicación ahora se conecta de nuevo por academia_app, muestra su rol y lee los 17600 estudiantes activos.
- **Acción preventiva:** Una acción preventiva para evitar este error, es evidente, modificar el script trimestral de las bajas para filtrar por cuentas exclusivamente pertenecientes a personas, y excluir cuentas de aplicación.
