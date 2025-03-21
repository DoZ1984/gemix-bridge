#!/bin/bash
# Script para preparar el entorno de Gemix en Linux
# Este script configura las librerías compartidas y permisos necesarios

# Directorio base del repositorio
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="$BASE_DIR/bin"
MODULES_DIR="$BIN_DIR/modules/linux/release"

echo "=== Preparando entorno para Gemix en Linux ==="
echo "Directorio base: $BASE_DIR"

# Comprobar si se ejecuta como root (necesario para algunas operaciones)
if [ "$EUID" -ne 0 ] && [ -z "$GITHUB_ACTIONS" ]; then
  echo "Este script necesita permisos de administrador para configurar las librerías."
  echo "Por favor, ejecuta: sudo $0"
  exit 1
fi

# Instalar dependencias del sistema si estamos en GitHub Actions
if [ ! -z "$GITHUB_ACTIONS" ]; then
  echo "Detectado entorno GitHub Actions, instalando dependencias..."
  sudo apt-get update
  sudo apt-get install -y libsdl2-2.0-0 libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev
fi

# Configurar permisos de ejecución
echo "Configurando permisos de ejecución..."
chmod +x "$BIN_DIR/gemix" 2>/dev/null || true
find "$BIN_DIR" -name "*.so*" -exec chmod +x {} \; 2>/dev/null || true
if [ -d "$MODULES_DIR" ]; then
  find "$MODULES_DIR" -name "*.so" -exec chmod +x {} \; 2>/dev/null || true
fi

# Crear enlaces simbólicos para las librerías
echo "Creando enlaces simbólicos para librerías compartidas..."
if [ -f "$BIN_DIR/libSDL2-2.0.so.0" ]; then
  sudo mkdir -p /usr/local/lib/gemix
  sudo cp "$BIN_DIR/libSDL2-2.0.so.0" /usr/local/lib/gemix/ 2>/dev/null || true
  sudo ln -sf /usr/local/lib/gemix/libSDL2-2.0.so.0 /usr/lib/libSDL2-2.0.so.0 2>/dev/null || true
fi

if [ -f "$BIN_DIR/libfmod.so.7" ]; then
  sudo mkdir -p /usr/local/lib/gemix
  sudo cp "$BIN_DIR/libfmod.so.7" /usr/local/lib/gemix/ 2>/dev/null || true
  sudo ln -sf /usr/local/lib/gemix/libfmod.so.7 /usr/lib/libfmod.so.7 2>/dev/null || true
fi

if [ -f "$BIN_DIR/libfmodex-4.44.61.so" ]; then
  sudo mkdir -p /usr/local/lib/gemix
  sudo cp "$BIN_DIR/libfmodex-4.44.61.so" /usr/local/lib/gemix/ 2>/dev/null || true
  sudo ln -sf /usr/local/lib/gemix/libfmodex-4.44.61.so /usr/lib/libfmodex-4.44.61.so 2>/dev/null || true
fi

if [ -f "$BIN_DIR/libfmodstudio.so.7" ]; then
  sudo mkdir -p /usr/local/lib/gemix
  sudo cp "$BIN_DIR/libfmodstudio.so.7" /usr/local/lib/gemix/ 2>/dev/null || true
  sudo ln -sf /usr/local/lib/gemix/libfmodstudio.so.7 /usr/lib/libfmodstudio.so.7 2>/dev/null || true
fi

# Actualizar cache de librerías
echo "Actualizando cache de librerías..."
sudo ldconfig 2>/dev/null || true

# Configurar LD_LIBRARY_PATH
export LD_LIBRARY_PATH="$BIN_DIR:/usr/local/lib/gemix:$LD_LIBRARY_PATH"
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"

# Verificar que los módulos estén disponibles
echo "Verificando módulos..."
if [ ! -d "$MODULES_DIR" ]; then
  echo "Advertencia: No se encuentra el directorio de módulos: $MODULES_DIR"
  echo "Es posible que necesites copiar los módulos desde el repositorio gemix-learning."
else
  # Listar los módulos disponibles
  echo "Módulos disponibles:"
  ls -la "$MODULES_DIR" 2>/dev/null || echo "No se pueden listar los módulos"
fi

# Verificar que el compilador existe
if [ ! -f "$BIN_DIR/gemix" ]; then
  echo "Advertencia: No se encuentra el compilador gemix en $BIN_DIR"
  echo "Es necesario copiar el compilador desde el repositorio gemix-learning."
else
  echo "Compilador Gemix encontrado: $BIN_DIR/gemix"
fi

echo "=== Entorno preparado con éxito ==="
echo "Ahora puedes compilar ejemplos con: $BASE_DIR/bin/gemix ruta/al/archivo.prg"