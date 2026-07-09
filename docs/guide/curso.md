# Ruta del Curso

Esta ruta organiza los ejemplos del repositorio como un curso corto de sistemas digitales con FPGA Gowin. La idea es que cada práctica se pueda ejecutar en placa y también leer como una unidad de teoría aplicada.

## Objetivo General

Al terminar el curso, el estudiante debe poder leer, modificar, sintetizar y cargar diseños digitales pequeños en Verilog y VHDL usando `DevLab`. El recorrido avanza desde **compuertas** y **bloques combinacionales** hasta **contadores** y **máquinas de estado**.

## Prerrequisitos

- Manejo básico de la terminal.
- Conceptos de álgebra booleana: **AND**, **OR**, **NOT**, **XOR** y **tablas de verdad**.
- Representación binaria de números enteros.
- Instalación funcional de DevLab y toolchain Gowin.
- Tarjeta FPGA conectada y archivo `pins.cst` correspondiente.
- Esquemático de la tarjeta para validar pines, voltajes y conexiones.

## Flujo de Trabajo por Práctica

1. Leer el objetivo y la teoría mínima.
2. Revisar `src/digital_labs.v` cuando exista un módulo reutilizable.
3. Revisar `src/top.v` para entender como se conecta el módulo a botones, reloj y LED.
4. Compilar con `devlab build`.
5. Cargar con `devlab flash`.
6. Repetir con VHDL usando `devlab build -c devlab-vhdl.toml`.
7. Registrar observaciones y contestar las preguntas de cierre.

## Evaluación Recomendada

- Evidencia de compilación sin errores.
- Evidencia de carga en placa.
- Tabla de verdad o tabla de estados cuando aplique.
- Explicación breve de entradas, salidas y señales internas.
- Modificación pequeña propuesta en la sección de actividades.

## Secuencia Sugerida

| Sesión | Prácticas | Tema central | Producto esperado |
| --- | --- | --- | --- |
| 1 | Básicos, 01 | Flujo DevLab, pines, LED activo en bajo, suma binaria | Primer bitstream cargado y tabla de suma de 1 bit |
| 2 | 02, 03 | Resta, préstamo y comparadores | Comparación entre operaciones aritméticas y relacionales |
| 3 | 04, 05 | Decodificadores y exhibidores | Tabla de segmentos para valores de entrada |
| 4 | 06, 07 | Composición de bloques y ALU | Bloque combinacional con selector de operación |
| 5 | 08, 09, 10 | Reloj, registros y contadores | Contadores visibles mediante divisor de frecuencia |
| 6 | 11, 12 | Control secuencial con dirección, enable y reset | Contador controlado desde botones |
| 7 | 13, 14 | Máquinas Moore y Mealy | Detector de secuencia `101` comparando ambos estilos |

## Mapa de Conceptos

- Combinacional: la salida depende solo de las entradas actuales.
- Secuencial: la salida también depende del estado guardado en registros.
- `top`: módulo o entidad que conecta el diseño con pines físicos.
- `pins.cst`: restricciones que asignan puertos HDL a pines de la FPGA.
- Esquemático: referencia eléctrica para confirmar que el pin usado en `pins.cst` corresponde al recurso físico correcto.
- LED activo en bajo: `led_n = 0` enciende el LED y `led_n = 1` lo apaga.
- Reset activo en bajo: `key_reset_n = 0` reinicia el circuito.
- VHDL y Verilog describen el mismo hardware con sintaxis distinta.

## Proyecto de Cierre

Extiende una práctica secuencial para mostrar más de una salida. Una opción viable es tomar el contador de la práctica 12 y cambiar el `top` para observar otro bit de `count`, agregar una dirección configurable o combinarlo con un decodificador de segmentos. El entregable debe incluir:

- Descripción del cambio.
- Fragmento HDL modificado.
- Resultado de `devlab build`.
- Observación en placa.
- Diferencia entre la versión Verilog y la versión VHDL si se implementaron ambas.
