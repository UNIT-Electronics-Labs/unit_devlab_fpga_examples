library ieee;
use ieee.std_logic_1164.all;

entity top is
    port (
        key_reset_n : in std_logic;
        key_enable_n : in std_logic;
        led_n : out std_logic
    );
end entity;

architecture rtl of top is
    signal hex : std_logic_vector(3 downto 0);
    signal raw : std_logic_vector(6 downto 0);
begin
    hex <= "00" & (not key_reset_n) & (not key_enable_n);

    with hex select raw <=
        "1111110" when "0000",
        "0110000" when "0001",
        "1101101" when "0010",
        "1111001" when "0011",
        "0110011" when "0100",
        "1011011" when "0101",
        "1011111" when "0110",
        "1110000" when "0111",
        "1111111" when "1000",
        "1111011" when "1001",
        "1110111" when "1010",
        "0011111" when "1011",
        "1001110" when "1100",
        "0111101" when "1101",
        "1001111" when "1110",
        "1000111" when others;

    led_n <= not raw(6);
end architecture;
