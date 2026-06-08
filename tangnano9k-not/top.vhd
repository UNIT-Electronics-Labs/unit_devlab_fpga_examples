library ieee;
use ieee.std_logic_1164.all;

entity top is
    port (
        gpio3_n : in std_logic;
        gpio4_n : in std_logic;
        led_n : out std_logic
    );
end entity;

architecture rtl of top is

signal a : std_logic;

begin

a <= not gpio3_n;

led_n <= not (not a);

end architecture;
