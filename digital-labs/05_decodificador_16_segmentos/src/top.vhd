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
    signal raw : std_logic_vector(15 downto 0);
begin
    hex <= "00" & (not key_reset_n) & (not key_enable_n);

    with hex select raw <=
        "1111110000001100" when "0000",
        "0110000000000000" when "0001",
        "1101101100000000" when "0010",
        "1111001100000000" when "0011",
        "0110011100000000" when "0100",
        "1011011100000000" when "0101",
        "1011111100000000" when "0110",
        "1110000000000000" when "0111",
        "1111111100000000" when "1000",
        "1111011100000000" when "1001",
        "1110111100000000" when "1010",
        "1111000010010010" when "1011",
        "1001110000000000" when "1100",
        "1111000010010010" when "1101",
        "1001111100000000" when "1110",
        "1000111100000000" when others;

    led_n <= not raw(15);
end architecture;
