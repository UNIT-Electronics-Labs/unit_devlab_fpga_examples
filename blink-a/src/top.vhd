library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        clk : in std_logic;
        led : out std_logic
    );
end entity top;

architecture rtl of top is
    signal counter : unsigned(23 downto 0) := (others => '0');
begin
    process (clk)
    begin
        if rising_edge(clk) then
            counter <= counter + 1;
            led <= counter(23);
        end if;
    end process;
end architecture rtl;
