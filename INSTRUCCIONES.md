# Instrucciones para configurar Gemix Bridge

Este documento explica cómo configurar y utilizar el sistema Gemix Bridge para permitir que una IA interactúe con el compilador Gemix.

## Requisitos previos

1. Una cuenta de GitHub
2. Los binarios del compilador Gemix para Linux (del repositorio gemix-learning)
3. Un token de acceso personal de GitHub con permisos de escritura en el repositorio

## Pasos para la configuración inicial

### 1. Clonar el repositorio

```bash
git clone https://github.com/DoZ1984/gemix-bridge.git
cd gemix-bridge
```

### 2. Copiar los binarios de Gemix

Copia todos los archivos de la carpeta `bin` del repositorio gemix-learning a la carpeta `bin` de este repositorio:

```bash
cp -r /ruta/a/gemix-learning/bin/* bin/
```

Asegúrate de incluir:
- El ejecutable `gemix`
- Las librerías compartidas (.so)
- Los módulos en la carpeta `modules/linux/release`

### 3. Configurar los permisos

```bash
chmod +x bin/gemix
chmod +x scripts/process-request.sh
chmod +x scripts/prepare-environment.sh
```

### 4. Hacer commit de los binarios

```bash
git add bin/
git commit -m "Añadir binarios de Gemix"
git push
```

### 5. Crear un token de acceso personal en GitHub

1. Ve a GitHub → Settings → Developer settings → Personal access tokens
2. Crea un nuevo token con permisos para el repositorio
3. Guarda este token de forma segura para usarlo en la integración con la IA

## Cómo funciona el sistema

1. La IA crea un archivo YAML en la carpeta `requests/` con la información de compilación
2. GitHub Actions detecta el nuevo archivo y ejecuta el workflow de compilación
3. El script `process-request.sh` procesa la solicitud y compila el código
4. Los resultados se guardan en la carpeta `results/`
5. La IA puede leer los resultados y presentarlos al usuario

## Ejemplo de uso

### 1. Crear una solicitud manualmente (para pruebas)

Crea un archivo en `requests/mi-solicitud.yml`:

```yaml
id: "test-001"
type: "compile"
source_file: "examples/hola_mundo.prg"
options:
  verbose: true
  timeout: 30
```

### 2. Hacer commit de la solicitud

```bash
git add requests/mi-solicitud.yml
git commit -m "Añadir solicitud de prueba"
git push
```

### 3. Verificar los resultados

Después de que GitHub Actions procese la solicitud, verás un nuevo archivo en la carpeta `results/`:

```
results/test-001-result.md
```

Este archivo contendrá los resultados de la compilación.

## Integración con una IA

Para que una IA utilice este sistema, necesita:

1. Autenticarse con GitHub usando el token de acceso personal
2. Crear archivos de solicitud en la carpeta `requests/`
3. Esperar a que el workflow procese la solicitud
4. Leer los resultados de la carpeta `results/`

Consulta el archivo `docs/guia-para-ia.md` para obtener instrucciones detalladas y ejemplos de código para la integración.

## Solución de problemas

### El workflow no se ejecuta

- Verifica que el archivo de solicitud tenga la extensión `.yml`
- Asegúrate de que el formato YAML sea válido
- Comprueba los logs de GitHub Actions para ver si hay errores

### Error de compilación

- Verifica que los binarios de Gemix estén correctamente copiados
- Asegúrate de que el código Gemix sea válido
- Revisa los permisos de los archivos ejecutables

### No se encuentran las librerías compartidas

- Ejecuta el script `prepare-environment.sh` para configurar el entorno
- Verifica que todas las librerías necesarias estén en la carpeta `bin/`

## Limitaciones

- El sistema solo puede compilar código, no ejecutarlo
- Depende de GitHub Actions, que tiene límites de uso
- Requiere que los binarios de Gemix estén presentes en el repositorio