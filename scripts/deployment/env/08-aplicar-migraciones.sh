#!/usr/bin/env bash
# scripts/deployment/env/08-aplicar-migraciones.sh
# Aplica las migraciones indicadas con autenticación del sistema operativo.
set -euo pipefail
source scripts/deployment/env/00-config.sh
[ $# -ge 1 ] || { echo "Uso: $0 <migración> [migración...] (nombre sin .sql)"; exit 2; }
DEST="${MIG_EVID:-docs/bitacora/lab4/evidencia/spool}"
mkdir -p "$DEST"
for MIG in "$@"; do
 FILE="database/migrations/$MIG.sql"
 [ -f "$FILE" ] || { echo "ERROR: no existe $FILE"; exit 2; }
 echo ">> Aplicando $MIG"
 LOG="$DEST/$(ts)_${MIG_PARTE:-04}-$MIG.spool.log"
 if ! docker exec -i "$CONT_NAME" sqlplus -s -L / as sysdba \
 < "$FILE" | tee "$LOG"; then
 echo "ERROR en $MIG: revisa $LOG antes de continuar"
 exit 1
 fi
done
echo ">> Migraciones aplicadas. Evidencias en $DEST/"
