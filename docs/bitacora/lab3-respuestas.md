# Laboratorio 3 — Respuestas de comprobación

## Docker

### 1. ¿Qué diferencia hay entre una imagen y un contenedor?

Una imagen es la plantilla con los archivos y programas necesarios para ejecutar una aplicación. Un contenedor es una instancia creada a partir de ella. En la práctica creamos un contenedor desde alpine:3.20 y entramos con sh. De una misma imagen se pueden crear varios contenedores independientes.

### 2. ¿Por qué nota.txt desapareció en G5 y no en G6?

En G5 el archivo estaba en el sistema de archivos del contenedor, así que al eliminarlo y crear otro, nota.txt ya no estaba. En G6 usamos un volumen, que guarda los datos fuera del sistema de archivos del contenedor y se puede montar en uno nuevo para recuperarlos.

### 3. ¿Qué diferencia hay entre docker ps y docker ps -a? ¿Qué significa Exited (0)?

docker ps lista solo los contenedores en ejecución, y docker ps -a incluye también los detenidos. Exited (0) indica que el proceso principal terminó con código 0, o sea, sin indicar un error.

### 4. ¿Qué significan los números de -p 8181:8181? ¿Qué pasaría con -p 80:8080 en nginx?

El primer número es el puerto del equipo anfitrión y el segundo, el del contenedor. Con -p 80:8080 las conexiones al puerto 80 del equipo irían al 8080 del contenedor. No funcionaría con el nginx de la práctica, porque escucha en el puerto 80 dentro del contenedor.

### 5. ¿Por qué Oracle sigue en marcha y hello-world termina?

El proceso principal de Oracle mantiene la base de datos atendiendo conexiones, por eso el contenedor sigue activo. El de hello-world solo imprime un mensaje y termina, y el contenedor con él. Un contenedor permanece en ejecución mientras su proceso principal siga activo.

### 6. ¿Qué es el digest y por qué registrarlo aunque usemos latest?

El digest es una huella criptográfica del contenido de una imagen. La etiqueta latest puede acabar apuntando a otra versión, así que registrar el digest deja constancia de qué imagen usamos exactamente y permite reproducir el entorno con ella.

### 7. ¿Qué comando borraría los datos de Oracle? ¿Por qué docker rm oralab-26ai no lo hace?

docker volume rm oralab-26ai-data borraría el volumen y sus datos, siempre que ningún contenedor lo esté usando. docker rm oralab-26ai solo elimina el contenedor y deja el volumen con nombre. Por eso se puede crear otro contenedor que lo monte y recuperar los datos.

## Git, organización y evidencia

### 8. ¿Por qué hacemos el laboratorio dentro del repositorio, con Issue, branch y Pull Request?

Para tener juntos los scripts, la documentación y las evidencias, y poder ver cómo cambia todo. El Issue describe la tarea, la branch nos deja trabajar sin tocar main y el Pull Request sirve para revisar el trabajo antes de integrarlo.

### 9. ¿Qué diferencia hay entre source 00-config.sh y bash 00-config.sh?

Con source el archivo se ejecuta en la terminal actual, así que sus variables y funciones siguen disponibles para los comandos siguientes. Con bash se ejecuta en otro proceso y lo que cambie en su entorno se pierde al terminar. Por eso usamos source para cargar las constantes y la función ts.

### 10. ¿Qué significa el nombre 20260915T091230Z_02-docker.script.log?

20260915 es la fecha, la T separa fecha y hora (091230) y la Z indica que es UTC. El 02 es el paso de la práctica, docker es la tarea y .script.log indica que es una evidencia de terminal.

### 11. ¿Para qué sirve .gitattributes y qué error evita?

Le dice a Git cómo tratar ciertos archivos. Aquí fija los finales de línea LF en los scripts y otros archivos de texto. Así evitamos que los CRLF de Windows den errores al ejecutar los scripts en Linux, como el del carácter inesperado \r.

### 12. ¿Por qué elegimos Create a merge commit en lugar de Squash and merge?

Queremos que en el historial de main queden los commits de cada parte del laboratorio. Con Squash se juntarían en uno solo y se perdería esa separación. Además, el merge commit deja registrado cuándo se integró la branch.

## Seguridad

### 13. ¿Cuáles son las cuatro capas de la estrategia de contraseñas?

Primera, .gitignore deja fuera el archivo con secretos. Segunda, .env.example documenta las variables con valores de ejemplo. Tercera, config/.env guarda las contraseñas reales solo en nuestro equipo. Cuarta, los comandos y scripts leen esas variables, así que no escribimos la contraseña directamente en los comandos ni en los scripts versionados. Si omitimos la primera capa, podríamos subir a Git el archivo real por accidente.

### 14. ¿Por qué no escribimos la contraseña directamente en docker run?

El comando puede quedarse en el historial de la terminal o en una grabación de la sesión, aunque no subamos el script. Con la variable no escribimos el valor real. De todas formas hay que revisar las evidencias por si se ha mostrado.

### 15. Si una contraseña aparece en un commit publicado, ¿basta con borrarla en otro?

No, sigue estando en los commits anteriores. Lo primero es cambiarla o revocarla, porque debemos considerarla expuesta. Después hay que quitarla del historial publicado, coordinándolo con quienes tengan copias del repositorio, y arreglar la causa para que no se repita.

## Oracle y herramientas

### 16. ¿Por qué no usamos SPOOL ni @archivo.sql con SQL*Plus dentro del contenedor?

Porque las rutas se interpretarían dentro del contenedor y ahí no están los archivos de nuestro repositorio, salvo que los copiemos o montemos expresamente. Enviamos el SQL por la entrada estándar con docker exec -i y guardamos la salida desde Ubuntu con tee, así la evidencia queda directamente en el repositorio.

### 17. ¿Qué hace WHENEVER SQLERROR EXIT SQL.SQLCODE?

Hace que SQL*Plus termine cuando se produce un error SQL y devuelva su código. Sin esa línea podría seguir ejecutando instrucciones después del fallo y la migración podría quedar aplicada a medias. No deshace automáticamente lo que ya se haya ejecutado.

### 18. ¿Qué es una migración y por qué no debemos editar V000 y V001 después de aplicarlas?

Una migración es un script numerado que aplica cambios a la base de datos. V000 prepara los tablespaces y usuarios, y V001 crea las tablas. Si modificamos una migración ya aplicada, su archivo deja de reflejar lo que ejecutamos. Los cambios nuevos van en otra migración.

### 19. ¿Por qué usamos el servicio FREEPDB1 y no FREE ni un SID?

FREEPDB1 es el servicio de la base de datos enchufable donde están los esquemas de trabajo, y FREE corresponde al contenedor raíz. Con FREEPDB1 conectamos directamente a la PDB correcta. Un SID identifica una instancia y por sí solo no elige esa PDB.

### 20. ¿Qué aporta SQLcl frente a SQL*Plus y por qué debemos conocer ambos?

SQLcl tiene una línea de comandos más cómoda, con autocompletado, historial y más opciones para mostrar o exportar resultados. SQL*Plus sigue siendo habitual en instalaciones y scripts de administración. Conocer los dos permite moverse en distintos entornos sin depender solo de SQLcl.

## Entorno de trabajo

### 21. ¿Por qué pasamos de Git Bash a Ubuntu en WSL 2?

WSL 2 da un Linux real, más parecido a un servidor. Git Bash no trae todas las herramientas de Linux y puede dar problemas con la conversión de rutas en los comandos de Docker. En Ubuntu usamos apt, los permisos de Linux y herramientas como tmux o ss de forma nativa.

### 22. ¿Por qué trabajamos en el sistema de archivos de Linux y recomendamos bash?

Dentro de /home evitamos problemas de rendimiento y diferencias de permisos que pueden aparecer al acceder al disco de Windows por /mnt/c. Mi repositorio está en ~/UCAM_projects/ADMON_BBDD/oracle-database-lab, dentro del sistema de archivos de Linux. Recomendamos bash porque los scripts de la práctica están escritos para él, y zsh tiene diferencias de comportamiento, así que no podemos asumir que los ejecute igual.