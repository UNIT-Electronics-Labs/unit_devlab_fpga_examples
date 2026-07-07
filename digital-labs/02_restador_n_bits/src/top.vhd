library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        key_reset_n : in std_logic;
        key_enable_n : in std_logic;
        led_n : out std_logic
    );
end entity;

architecture rtl of top is
    signal a : unsigned(3 downto 0);
    signal b : unsigned(3 downto 0);
    signal diff : unsigned(3 downto 0);
begin
    a <= "000" & (not key_reset_n);
    b <= "000" & (not key_enable_n);
    diff <= a - b;

    led_n <= not diff(0);
end architecture;
