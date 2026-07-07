library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        clk : in std_logic;
        key_reset_n : in std_logic;
        key_enable_n : in std_logic;
        led_n : out std_logic
    );
end entity;

architecture rtl of top is
    signal divider : unsigned(23 downto 0) := (others => '0');
    signal count : unsigned(7 downto 0) := (others => '0');
    signal slow_clk : std_logic;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if key_reset_n = '0' then
                divider <= (others => '0');
            else
                divider <= divider + 1;
            end if;
        end if;
    end process;

    slow_clk <= divider(23);

    process(slow_clk)
    begin
        if rising_edge(slow_clk) then
            if key_reset_n = '0' then
                count <= (others => '0');
            elsif key_enable_n = '0' then
                count <= count + 1;
            end if;
        end if;
    end process;

    led_n <= not count(7);
end architecture;
