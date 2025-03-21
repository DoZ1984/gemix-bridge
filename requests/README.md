# Carpeta de solicitudes

En esta carpeta se colocarán las solicitudes de compilación en formato YAML.

Formato de solicitud:

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

Las solicitudes procesadas se moverán automáticamente a la subcarpeta `history/`.