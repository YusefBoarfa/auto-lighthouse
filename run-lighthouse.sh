#!/bin/bash
# Ejemplo de uso:
#   ./run-lighthouse.sh mode=full
#   ./run-lighthouse.sh mode=normal   (normal es el valor por defecto)

# Valor por defecto para el modo
MODE="normal"

# Procesar argumentos para establecer el modo
for arg in "$@"
do
  case $arg in
    mode=full)
      MODE="full"
      shift
      ;;
    mode=normal)
      MODE="normal"
      shift
      ;;
    *)
      # Otras opciones se pueden agregar aquí
      ;;
  esac
done

# URL a auditar
URL="http://localhost:3000"

# Crear carpeta base de salida con timestamp
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BASE_OUTPUT_DIR="output/$TIMESTAMP"
mkdir -p "$BASE_OUTPUT_DIR"

echo "Modo: $MODE"
echo "Carpeta base de salida: $BASE_OUTPUT_DIR"

# Definir perfiles según el modo
if [ "$MODE" = "full" ]; then
  PROFILES=("hard-throttling" "soft-throttling" "cpu-slow" "net-slow" "native")
else
  PROFILES=("hard-throttling" "soft-throttling")
fi

# Iterar sobre cada perfil y ejecutar las auditorías para mobile y desktop
for PROFILE in "${PROFILES[@]}"; do
  OUTPUT_PROFILE_DIR="$BASE_OUTPUT_DIR/$PROFILE"
  mkdir -p "$OUTPUT_PROFILE_DIR"
  
  MOBILE_CONFIG="config/$PROFILE/mobile.json"
  DESKTOP_CONFIG="config/$PROFILE/desktop.json"
  
  echo "Ejecutando Lighthouse para el perfil '$PROFILE' - Móvil..."
  lighthouse "$URL" \
    --config-path="$MOBILE_CONFIG" \
    --chrome-flags="--headless" \
    --output html \
    --output-path="$OUTPUT_PROFILE_DIR/mobile-report.html"
  
  echo "Ejecutando Lighthouse para el perfil '$PROFILE' - Escritorio..."
  lighthouse "$URL" \
    --config-path="$DESKTOP_CONFIG" \
    --chrome-flags="--headless" \
    --output html \
    --output-path="$OUTPUT_PROFILE_DIR/desktop-report.html"
done

echo "Auditorías completadas. Revisa los reportes en: $BASE_OUTPUT_DIR"
