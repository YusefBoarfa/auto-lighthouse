#!/bin/bash
# Ejemplo de uso:
#   ./run-lighthouse.sh mode=full outputType=json
#   ./run-lighthouse.sh mode=normal outputType=html
# Si no se especifica, los valores por defecto serán mode=normal y outputType=json

# Valores por defecto
MODE="normal"
OUTPUT_TYPE="json"  # Opciones: json, html, csv (u otras que soporte Lighthouse)

# Procesar argumentos
for arg in "$@"; do
  case $arg in
    mode=full)
      MODE="full"
      shift
      ;;
    mode=normal)
      MODE="normal"
      shift
      ;;
    outputType=html)
      OUTPUT_TYPE="html"
      shift
      ;;
    outputType=json)
      OUTPUT_TYPE="json"
      shift
      ;;
    outputType=csv)
      OUTPUT_TYPE="csv"
      shift
      ;;
    *)
      # Se ignoran otros parámetros
      shift
      ;;
  esac
done

# Definir extensión en función del tipo de output
EXTENSION="$OUTPUT_TYPE"

# URL a auditar
URL="http://localhost:3000"

# Crear carpeta base de salida con timestamp
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BASE_OUTPUT_DIR="output/$TIMESTAMP"
mkdir -p "$BASE_OUTPUT_DIR"

echo "Modo: $MODE"
echo "Tipo de salida: $OUTPUT_TYPE"
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
    --output "$OUTPUT_TYPE" \
    --output-path="$OUTPUT_PROFILE_DIR/mobile-report.$EXTENSION"
  
  echo "Ejecutando Lighthouse para el perfil '$PROFILE' - Escritorio..."
  lighthouse "$URL" \
    --config-path="$DESKTOP_CONFIG" \
    --chrome-flags="--headless" \
    --output "$OUTPUT_TYPE" \
    --output-path="$OUTPUT_PROFILE_DIR/desktop-report.$EXTENSION"
done

echo "Auditorías completadas. Revisa los reportes en: $BASE_OUTPUT_DIR"
