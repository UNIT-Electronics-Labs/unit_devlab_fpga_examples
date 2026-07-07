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
    type state_t is (s0, s1, s10);
    signal divider : unsigned(23 downto 0) := (others => '0');
    signal state : state_t := s0;
    signal slow_clk : std_logic;
    signal din : std_logic;
    signal found : std_logic;
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
    din <= not key_enable_n;
    found <= '1' when state = s10 and din = '1' else '0';

    process(slow_clk)
    begin
        if rising_edge(slow_clk) then
            if key_reset_n = '0' then
                state <= s0;
            else
                case state is
                    when s0 =>
                        if din = '1' then
                            state <= s1;
                        else
                            state <= s0;
                        end if;
                    when s1 =>
                        if din = '1' then
                            state <= s1;
                        else
                            state <= s10;
                        end if;
                    when s10 =>
                        if din = '1' then
                            state <= s1;
                        else
                            state <= s0;
                        end if;
                end case;
            end if;
        end if;
    end process;

    led_n <= not found;
end architecture;
