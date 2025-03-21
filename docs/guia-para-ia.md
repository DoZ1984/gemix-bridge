# Guía para interactuar con Gemix Bridge desde una IA

Esta guía explica cómo una IA puede interactuar con el compilador Gemix a través de este repositorio puente.

## Flujo de trabajo

1. **Recibir código Gemix del usuario**: La IA recibe código Gemix que el usuario quiere compilar.
2. **Crear solicitud**: La IA crea un archivo YAML en la carpeta `requests/` con la información necesaria.
3. **Esperar procesamiento**: GitHub Actions detecta el archivo y ejecuta el workflow de compilación.
4. **Leer resultados**: La IA lee el archivo generado en la carpeta `results/` y presenta los resultados al usuario.

## Crear una solicitud

Para crear una solicitud, la IA debe usar la API de GitHub para crear un archivo en la carpeta `requests/` con el siguiente formato:

```yaml
id: "request-{timestamp}-{random}"
type: "compile"
source_file: "examples/{nombre_archivo}.prg"
source_code: |
  // Código Gemix proporcionado por el usuario
  PROGRAM ejemplo;
  BEGIN
    // ...
  END
options:
  verbose: true
  timeout: 30
```

### Parámetros

- `id`: Identificador único para la solicitud (usar timestamp y número aleatorio)
- `type`: Tipo de solicitud (actualmente solo "compile")
- `source_file`: Ruta donde se guardará el archivo fuente
- `source_code`: Código Gemix a compilar
- `options`: Opciones adicionales
  - `verbose`: Si se debe mostrar información detallada
  - `timeout`: Tiempo máximo de compilación en segundos

## Leer resultados

Después de crear la solicitud, la IA debe esperar a que el workflow de GitHub Actions se complete. Luego, puede leer el archivo de resultados en la carpeta `results/`:

```
results/{id}-result.md
```

Este archivo contiene:
- La salida del compilador
- El estado de la compilación (éxito/error)
- Información sobre los archivos generados

## Ejemplo de código para IA

```python
import requests
import base64
import time
import yaml
import random
import datetime

# Configuración
GITHUB_TOKEN = "tu_token_de_github"
REPO_OWNER = "DoZ1984"
REPO_NAME = "gemix-bridge"
API_BASE = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}"

headers = {
    "Authorization": f"token {GITHUB_TOKEN}",
    "Accept": "application/vnd.github.v3+json"
}

# Función para crear una solicitud
def crear_solicitud(codigo_gemix, nombre_archivo=None):
    # Generar ID único
    timestamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    random_id = random.randint(1000, 9999)
    request_id = f"request-{timestamp}-{random_id}"
    
    # Si no se proporciona nombre, crear uno basado en el ID
    if nombre_archivo is None:
        nombre_archivo = f"code-{timestamp}-{random_id}"
    
    # Crear contenido YAML
    request_content = {
        "id": request_id,
        "type": "compile",
        "source_file": f"examples/{nombre_archivo}.prg",
        "source_code": codigo_gemix,
        "options": {
            "verbose": True,
            "timeout": 30
        }
    }
    
    # Convertir a YAML
    yaml_content = yaml.dump(request_content)
    
    # Crear archivo en GitHub
    url = f"{API_BASE}/contents/requests/{request_id}.yml"
    data = {
        "message": f"Solicitud de compilación {request_id}",
        "content": base64.b64encode(yaml_content.encode()).decode(),
        "branch": "main"
    }
    
    response = requests.put(url, headers=headers, json=data)
    if response.status_code not in [201, 200]:
        print(f"Error al crear solicitud: {response.json()}")
        return None
    
    return request_id

# Función para verificar si los resultados están disponibles
def verificar_resultados(request_id, max_intentos=10, espera=5):
    for intento in range(max_intentos):
        url = f"{API_BASE}/contents/results/{request_id}-result.md"
        response = requests.get(url, headers=headers)
        
        if response.status_code == 200:
            content_base64 = response.json()["content"]
            content = base64.b64decode(content_base64).decode()
            return content
        
        print(f"Resultados no disponibles aún, intento {intento+1}/{max_intentos}")
        time.sleep(espera)
    
    return None

# Ejemplo de uso
codigo_usuario = """
PROGRAM hola;
BEGIN
    write(320, 240, 0, "Hola desde la IA!");
    FRAME;
END
"""

# Crear solicitud
request_id = crear_solicitud(codigo_usuario, "hola_ia")
if request_id:
    print(f"Solicitud creada con ID: {request_id}")
    
    # Esperar y verificar resultados
    resultados = verificar_resultados(request_id)
    if resultados:
        print("Resultados de compilación:")
        print(resultados)
    else:
        print("No se pudieron obtener los resultados")
```

## Consideraciones

- **Rate Limits**: La API de GitHub tiene límites de tasa. Asegúrate de no excederlos.
- **Autenticación**: Necesitas un token de GitHub con permisos para el repositorio.
- **Tiempos de espera**: El procesamiento puede tardar, implementa un mecanismo de polling adecuado.
- **Manejo de errores**: Implementa un manejo robusto de errores para casos donde el workflow falle.

## Limitaciones actuales

- El sistema requiere que los binarios de Gemix estén presentes en la carpeta `/bin`.
- No se pueden ejecutar los programas compilados, solo compilarlos.
- El workflow puede fallar si hay problemas con las dependencias del sistema.