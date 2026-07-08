# NOT

Ejemplo de inversor lógico.

## Qué Aprendes

- Usar una entrada como señal booleana.
- Aplicar negación lógica.
- Enviar el resultado al LED activo en bajo.

## Lógica

La salida cambia al valor contrario de la entrada lógica. Como el LED es activo en bajo, el `top` también considera la polaridad física del LED.

![top entity](img/top_entity.png)

## Código Fuente

::: code-group

```verilog [Verilog]
module top (
    input wire gpio3_n,
    input wire gpio4_n,
    output wire led_n
);
    wire a = ~gpio3_n;

    assign led_n = ~(~a);
endmodule
```

```vhdl [VHDL]
library ieee;
use ieee.std_logic_1164.all;

entity top is
    port (
        gpio3_n : in std_logic;
        gpio4_n : in std_logic;
        led_n : out std_logic
    );
end entity top;

architecture rtl of top is
    signal a : std_logic;
begin
    a <= not gpio3_n;

    led_n <= not (not a);
end architecture rtl;
```

:::

## Compilar

```bash
cd not
devlab build
devlab flash
```

## VHDL

```bash
cd not
devlab build -c devlab-vhdl.toml
devlab flash
```
