# Trabajo Práctico: Estructuras de datos en ASM
## Objetivo
Familiarizarse con el uso de lenguaje ensamblador mediante la implementación de estructuras de datos, además de pedidos, manejo y liberación de memoria dinámica.

## Contenido
En la carpeta *codigoEnC* se encuentran los códigos de varias funciones del tp escritas en lenguaje C.
Las mismas fueron realizadas para facilitar el pasaje a lenguaje ensamblador. En el archivo *solucion/lib.asm* se encuentran las implementaciones de las funciones pedidas.

## Testing
Se presenta una serie de tests o pruebas intensivas para que pueda verificarse el buen funcionamiento del código de manera automática. Para correr el testing se debe ejecutar ./runTester.sh, que compilará el tester y correrá todos los tests. Un test consiste en la creación, inserción, eliminación, ejecución de funciones e impresión en archivos de alguna estructura implementada. Luego
de cada test, el script comparará los archivos generados por el TP con las soluciones correctas provistas. También será probada la correcta administración de la memoria dinámica.
