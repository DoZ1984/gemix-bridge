#!/bin/bash
# Script para procesar solicitudes de compilación
# Este script lee un archivo de solicitud en formato YAML y ejecuta el compilador Gemix

# Encontrar la solicitud más reciente
LATEST_REQUEST=$(ls -t requests/*.yml 2>/dev/null | head -1)

if [ -z "$LATEST_REQUEST" ]; then
  echo "No se encontraron solicitudes pendientes"
  exit 0
fi

echo "Procesando solicitud: $LATEST_REQUEST"

# Extraer información de la solicitud usando grep y awk
REQUEST_ID=$(grep "id:" "$LATEST_REQUEST" | cut -d'"' -f2)
SOURCE_FILE=$(grep "source_file:" "$LATEST_REQUEST" | cut -d'"' -f2)
TIMEOUT=$(grep "timeout:" "$LATEST_REQUEST" | awk '{print $2}')

# Si no se especifica timeout, usar valor por defecto
if [ -z "$TIMEOUT" ]; then
  TIMEOUT=30
fi

echo "ID de solicitud: $REQUEST_ID"
echo "Archivo fuente: $SOURCE_FILE"
echo "Timeout: $TIMEOUT segundos"

# Si hay código fuente en la solicitud, guardarlo en un archivo temporal
if grep -q "source_code:" "$LATEST_REQUEST"; then
  echo "Extrayendo código fuente de la solicitud..."
  
  # Extraer el código fuente (líneas entre source_code: | y la siguiente clave)
  SOURCE_CODE=$(sed -n '/source_code: |/,/^[a-z]/p' "$LATEST_REQUEST" | tail -n +2 | sed '/^[a-z]/d')
  
  # Si source_file no existe, crear un archivo temporal
  if [ ! -f "$SOURCE_FILE" ]; then
    mkdir -p $(dirname "$SOURCE_FILE")
    echo "$SOURCE_CODE" > "$SOURCE_FILE"
    echo "Código fuente guardado en $SOURCE_FILE"
  else
    echo "El archivo $SOURCE_FILE ya existe, no se sobrescribirá"
  fi
fi

# Verificar que el archivo fuente existe
if [ ! -f "$SOURCE_FILE" ]; then
  echo "Error: El archivo fuente $SOURCE_FILE no existe"
  
  # Crear archivo de resultados con error
  RESULT_FILE="results/${REQUEST_ID}-result.md"
  mkdir -p results
  
  echo "# Resultados de compilación para $REQUEST_ID" > "$RESULT_FILE"
  echo "" >> "$RESULT_FILE"
  echo "## ❌ Error: Archivo fuente no encontrado" >> "$RESULT_FILE"
  echo "" >> "$RESULT_FILE"
  echo "El archivo \`$SOURCE_FILE\` no existe." >> "$RESULT_FILE"
  
  # Mover la solicitud procesada a un archivo histórico
  mkdir -p requests/history
  mv "$LATEST_REQUEST" "requests/history/${REQUEST_ID}.yml"
  
  echo "Solicitud procesada con error. Resultados guardados en $RESULT_FILE"
  exit 1
fi

# Crear archivo de resultados
RESULT_FILE="results/${REQUEST_ID}-result.md"
mkdir -p results

echo "# Resultados de compilación para $REQUEST_ID" > "$RESULT_FILE"
echo "" >> "$RESULT_FILE"
echo "Archivo fuente: \`$SOURCE_FILE\`" >> "$RESULT_FILE"
echo "" >> "$RESULT_FILE"
echo "## Salida del compilador" >> "$RESULT_FILE"
echo "" >> "$RESULT_FILE"
echo '```' >> "$RESULT_FILE"

# Configurar entorno para librerías compartidas
export LD_LIBRARY_PATH="$PWD/bin:$LD_LIBRARY_PATH"

# Ejecutar el compilador con timeout
timeout "${TIMEOUT}s" ./bin/gemix "$SOURCE_FILE" 2>&1 | tee -a "$RESULT_FILE"
COMPILE_RESULT=$?

echo '```' >> "$RESULT_FILE"
echo "" >> "$RESULT_FILE"

# Agregar información sobre el resultado
if [ $COMPILE_RESULT -eq 0 ]; then
  echo "## ✅ Compilación exitosa" >> "$RESULT_FILE"
  
  # Comprobar si se generó un ejecutable
  EXECUTABLE="${SOURCE_FILE%.prg}"
  if [ -f "$EXECUTABLE" ]; then
    echo "" >> "$RESULT_FILE"
    echo "Ejecutable generado: \`$EXECUTABLE\`" >> "$RESULT_FILE"
    
    # Listar información del ejecutable
    echo "" >> "$RESULT_FILE"
    echo "Información del ejecutable:" >> "$RESULT_FILE"
    echo '```' >> "$RESULT_FILE"
    ls -la "$EXECUTABLE" >> "$RESULT_FILE"
    echo '```' >> "$RESULT_FILE"
  fi
elif [ $COMPILE_RESULT -eq 124 ]; then
  echo "## ⚠️ Tiempo de compilación excedido (timeout)" >> "$RESULT_FILE"
else
  echo "## ❌ Error de compilación (código $COMPILE_RESULT)" >> "$RESULT_FILE"
fi

# Mover la solicitud procesada a un archivo histórico
mkdir -p requests/history
mv "$LATEST_REQUEST" "requests/history/${REQUEST_ID}.yml"

echo "Solicitud procesada. Resultados guardados en $RESULT_FILE"