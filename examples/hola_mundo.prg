// Hola Mundo en Gemix
// Este es el ejemplo más básico para empezar a programar en Gemix

PROGRAM hola_mundo;

BEGIN
    // Configuración de la pantalla
    set_mode(640, 480);
    set_title("Mi primer programa en Gemix");
    
    // Mostramos un mensaje en pantalla
    write(320, 240, 0, "¡Hola, mundo!");
    
    // Esperamos a que el usuario presione una tecla
    WHILE (NOT key(_ESC))
        FRAME;
    END
END