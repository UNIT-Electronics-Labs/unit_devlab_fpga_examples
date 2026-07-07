library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        clk : in std_logic;
        key_reset_n : in std_logic;
        led_n : out std_logic
    );
end entity;

architecture rtl of top is
    signal count : unsigned(23 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if key_reset_n = '0' then
                count <= (others => '0');
            else
                count <= count + 1;
            end if;
        end if;
    end process;

    led_n <= not count(23);
end architecture;
