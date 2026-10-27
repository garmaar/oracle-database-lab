#!/usr/bin/env bash
set -euo pipefail
source scripts/deployment/env/00-config.sh
LOG="$EVID_LAB5/script/$(ts)_12-reto-fra.script.log"
{
  printf "SET LINES 200 PAGES 100\nSELECT 'ANTES' AS momento,space_used FROM v\$recovery_file_dest;\nEXIT\n" \
    | docker exec -i "$CONT_NAME" sqlplus -s -L / as sysdba
  bash scripts/ops/sysdba.sh scripts/lab5/12-undo-y-redo.sql
  printf "WHENEVER SQLERROR EXIT FAILURE\nALTER SYSTEM ARCHIVE LOG CURRENT;\nSELECT 'DESPUES' AS momento,space_used FROM v\$recovery_file_dest;\nEXIT\n" \
    | docker exec -i "$CONT_NAME" sqlplus -s -L / as sysdba
} | tee "$LOG"
