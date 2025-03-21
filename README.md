# Gemix Bridge

Este repositorio actúa como puente para permitir que una IA interactúe con el compilador Gemix a través de GitHub Actions.

## Estructura

- `requests/`: Carpeta donde la IA coloca solicitudes de compilación
- `results/`: Carpeta donde se almacenan los resultados de compilación
- `examples/`: Ejemplos de código Gemix
- `bin/`: Binarios del compilador Gemix
- `scripts/`: Scripts para procesar solicitudes y preparar el entorno
- `.github/workflows/`: Configuración de GitHub Actions

## Cómo funciona

1. La IA crea un archivo YAML en la carpeta `requests/`
2. GitHub Actions detecta el nuevo archivo y ejecuta el workflow de compilación
3. El script procesa la solicitud, compila el código y guarda los resultados
4. Los resultados se almacenan en la carpeta `results/`
5. La IA puede leer los resultados y presentarlos al usuario

## Formato de solicitud

```yaml
id: "request-20250321-001"
type: "compile"
source_file: "examples/test.prg"
source_code: |
  PROGRAM test;
  BEGIN
    write(0, 0, 0, "Hola mundo");
    FRAME;
  END
options:
  verbose: true
  timeout: 30
```