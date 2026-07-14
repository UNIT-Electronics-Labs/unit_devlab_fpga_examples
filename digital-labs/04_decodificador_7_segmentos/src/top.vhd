library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        clk : in std_logic;
        key_reset_n : in std_logic;
        key_enable_n : in std_logic;
        seg : out std_logic_vector(7 downto 0);
        digit_en : out std_logic_vector(1 downto 0)
    );
end entity;

architecture rtl of top is
    constant CLK_HZ : natural := 27000000;
    constant REFRESH_HZ : natural := 1000;
    constant REFRESH_MAX : natural := CLK_HZ / (REFRESH_HZ * 2);
    constant BUTTON_DEBOUNCE_MAX : natural := CLK_HZ / 100;

    signal refresh_div : natural range 0 to REFRESH_MAX - 1 := 0;
    signal debounce_div : natural range 0 to BUTTON_DEBOUNCE_MAX - 1 := 0;
    signal ones : unsigned(3 downto 0) := (others => '0');
    signal tens : unsigned(3 downto 0) := (others => '0');
    signal selected_digit : std_logic := '0';
    signal enable_meta : std_logic := '0';
    signal enable_sync : std_logic := '0';
    signal enable_stable : std_logic := '0';
    signal enable_last : std_logic := '0';
    signal selected_bcd : unsigned(3 downto 0);
    signal raw_seg : std_logic_vector(6 downto 0);
    signal raw_digit_en : std_logic_vector(1 downto 0);
begin
    process (clk)
    begin
        if rising_edge(clk) then
            enable_meta <= not key_enable_n;
            enable_sync <= enable_meta;

            if key_reset_n = '0' then
                debounce_div <= 0;
                enable_stable <= '0';
                enable_last <= '0';
                ones <= (others => '0');
                tens <= (others => '0');
            else
                if enable_sync = enable_stable then
                    debounce_div <= 0;
                elsif debounce_div = BUTTON_DEBOUNCE_MAX - 1 then
                    debounce_div <= 0;
                    enable_stable <= enable_sync;
                else
                    debounce_div <= debounce_div + 1;
                end if;

                enable_last <= enable_stable;

                if enable_stable = '1' and enable_last = '0' then
                    if ones = 9 then
                        ones <= (others => '0');
                        if tens = 9 then
                            tens <= (others => '0');
                        else
                            tens <= tens + 1;
                        end if;
                    else
                        ones <= ones + 1;
                    end if;
                end if;
            end if;

            if key_reset_n = '0' then
                refresh_div <= 0;
                selected_digit <= '0';
            elsif refresh_div = REFRESH_MAX - 1 then
                refresh_div <= 0;
                selected_digit <= not selected_digit;
            else
                refresh_div <= refresh_div + 1;
            end if;
        end if;
    end process;

    selected_bcd <= tens when selected_digit = '1' else ones;
    raw_digit_en <= "01" when selected_digit = '1' else "10";

    with selected_bcd select raw_seg <=
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
        "0000000" when others;

    seg <= not (raw_seg & '0');
    digit_en <= not raw_digit_en;
end architecture;
