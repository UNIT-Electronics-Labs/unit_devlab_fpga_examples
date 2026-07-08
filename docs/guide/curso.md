# Ruta del Curso

Esta ruta organiza los ejemplos del repositorio como un curso corto de sistemas digitales con FPGA Gowin. La idea es que cada practica se pueda ejecutar en placa y tambien leer como una unidad de teoria aplicada.

## Objetivo General

Al terminar el curso, el estudiante debe poder leer, modificar, sintetizar y cargar disenos digitales pequenos en Verilog y VHDL usando DevLab. El recorrido avanza desde compuertas y bloques combinacionales hasta contadores y maquinas de estado.

## Prerrequisitos

- Manejo basico de terminal.
- Conceptos de algebra booleana: AND, OR, NOT, XOR y tablas de verdad.
- Representacion binaria de numeros enteros.
- Instalacion funcional de DevLab y toolchain Gowin.
- Tarjeta FPGA conectada y archivo `pins.cst` correspondiente.
- Esquematico de la tarjeta para validar pines, voltajes y conexiones.

## Flujo de Trabajo por Practica

1. Leer el objetivo y la teoria minima.
2. Revisar `src/digital_labs.v` cuando exista un modulo reutilizable.
3. Revisar `src/top.v` para entender como se conecta el modulo a botones, reloj y LED.
4. Compilar con `devlab build`.
5. Cargar con `devlab flash`.
6. Repetir con VHDL usando `devlab build -c devlab-vhdl.toml`.
7. Registrar observaciones y contestar las preguntas de cierre.

## Evaluacion Recomendada

- Evidencia de compilacion sin errores.
- Evidencia de carga en placa.
- Tabla de verdad o tabla de estados cuando aplique.
- Explicacion breve de entradas, salidas y senales internas.
- Modificacion pequena propuesta en la seccion de actividades.

## Secuencia Sugerida

| Sesion | Practicas | Tema central | Producto esperado |
| --- | --- | --- | --- |
| 1 | Basicos, 01 | Flujo DevLab, pines, LED activo en bajo, suma binaria | Primer bitstream cargado y tabla de suma de 1 bit |
| 2 | 02, 03 | Resta, prestamo y comparadores | Comparacion entre operaciones aritmeticas y relacionales |
| 3 | 04, 05 | Decodificadores y exhibidores | Tabla de segmentos para valores de entrada |
| 4 | 06, 07 | Composicion de bloques y ALU | Bloque combinacional con selector de operacion |
| 5 | 08, 09, 10 | Reloj, registros y contadores | Contadores visibles mediante divisor de frecuencia |
| 6 | 11, 12 | Control secuencial con direccion, enable y reset | Contador controlado desde botones |
| 7 | 13, 14 | Maquinas Moore y Mealy | Detector de secuencia `101` comparando ambos estilos |

## Mapa de Conceptos

- Combinacional: la salida depende solo de las entradas actuales.
- Secuencial: la salida tambien depende del estado guardado en registros.
- `top`: modulo o entidad que conecta el diseno con pines fisicos.
- `pins.cst`: restricciones que asignan puertos HDL a pines de la FPGA.
- Esquematico: referencia electrica para confirmar que el pin usado en `pins.cst` corresponde al recurso fisico correcto.
- LED activo en bajo: `led_n = 0` enciende el LED y `led_n = 1` lo apaga.
- Reset activo en bajo: `key_reset_n = 0` reinicia el circuito.
- VHDL y Verilog describen el mismo hardware con sintaxis distinta.

## Proyecto de Cierre

Extiende una practica secuencial para mostrar mas de una salida. Una opcion viable es tomar el contador de la practica 12 y cambiar el `top` para observar otro bit de `count`, agregar una direccion configurable o combinarlo con un decodificador de segmentos. El entregable debe incluir:

- Descripcion del cambio.
- Fragmento HDL modificado.
- Resultado de `devlab build`.
- Observacion en placa.
- Diferencia entre la version Verilog y la version VHDL si se implementaron ambas.
