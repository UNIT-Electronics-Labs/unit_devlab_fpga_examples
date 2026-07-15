library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        clk : in std_logic;
        key_down_n : in std_logic;
        key_up_n : in std_logic;
        dac : out std_logic_vector(7 downto 0);
        seg : out std_logic_vector(7 downto 0);
        digit_en : out std_logic_vector(1 downto 0)
    );
end entity;

architecture rtl of top is
    constant CLK_HZ : natural := 27000000;
    constant REFRESH_HZ : natural := 1000;
    constant DEBOUNCE_CYCLES : natural := CLK_HZ / 100;
    constant REFRESH_CYCLES : natural := CLK_HZ / (REFRESH_HZ * 2);

    signal down_meta : std_logic := '1';
    signal down_sync : std_logic := '1';
    signal down_stable : std_logic := '1';
    signal up_meta : std_logic := '1';
    signal up_sync : std_logic := '1';
    signal up_stable : std_logic := '1';
    signal down_pressed : std_logic := '0';
    signal up_pressed : std_logic := '0';
    signal down_count : natural range 0 to DEBOUNCE_CYCLES - 1 := 0;
    signal up_count : natural range 0 to DEBOUNCE_CYCLES - 1 := 0;

    signal frequency_index : natural range 0 to 5 := 1;
    signal phase : unsigned(31 downto 0) := (others => '0');
    signal dac_reg : unsigned(7 downto 0) := to_unsigned(128, 8);
    signal refresh_count : natural range 0 to REFRESH_CYCLES - 1 := 0;
    signal selected_digit : std_logic := '0';
    signal display_number : natural range 1 to 6;
    signal display_value : natural range 0 to 9;
    signal raw_seg : std_logic_vector(7 downto 0);
    signal raw_digit_en : std_logic_vector(1 downto 0);

    function phase_increment(index : natural) return unsigned is
    begin
        case index is
            when 0 => return to_unsigned(79536, 32);    -- 500 Hz
            when 1 => return to_unsigned(159073, 32);   -- 1 kHz
            when 2 => return to_unsigned(238609, 32);   -- 1.5 kHz
            when 3 => return to_unsigned(318146, 32);   -- 2 kHz
            when 4 => return to_unsigned(477219, 32);   -- 3 kHz
            when others => return to_unsigned(636291, 32); -- 4 kHz
        end case;
    end function;

    function sine_lut(addr : unsigned(4 downto 0)) return unsigned is
    begin
        case to_integer(addr) is
            when 0 => return to_unsigned(128,8); when 1 => return to_unsigned(153,8);
            when 2 => return to_unsigned(177,8); when 3 => return to_unsigned(199,8);
            when 4 => return to_unsigned(218,8); when 5 => return to_unsigned(234,8);
            when 6 => return to_unsigned(245,8); when 7 => return to_unsigned(253,8);
            when 8 => return to_unsigned(255,8); when 9 => return to_unsigned(253,8);
            when 10 => return to_unsigned(245,8); when 11 => return to_unsigned(234,8);
            when 12 => return to_unsigned(218,8); when 13 => return to_unsigned(199,8);
            when 14 => return to_unsigned(177,8); when 15 => return to_unsigned(153,8);
            when 16 => return to_unsigned(128,8); when 17 => return to_unsigned(103,8);
            when 18 => return to_unsigned(79,8); when 19 => return to_unsigned(57,8);
            when 20 => return to_unsigned(38,8); when 21 => return to_unsigned(22,8);
            when 22 => return to_unsigned(11,8); when 23 => return to_unsigned(3,8);
            when 24 => return to_unsigned(0,8); when 25 => return to_unsigned(3,8);
            when 26 => return to_unsigned(11,8); when 27 => return to_unsigned(22,8);
            when 28 => return to_unsigned(38,8); when 29 => return to_unsigned(57,8);
            when 30 => return to_unsigned(79,8); when others => return to_unsigned(103,8);
        end case;
    end function;

    function seven_seg(value : natural) return std_logic_vector is
    begin
        case value is
            when 0 => return "1111110"; when 1 => return "0110000";
            when 2 => return "1101101"; when 3 => return "1111001";
            when 4 => return "0110011"; when 5 => return "1011011";
            when 6 => return "1011111"; when 7 => return "1110000";
            when 8 => return "1111111"; when 9 => return "1111011";
            when others => return "0000000";
        end case;
    end function;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            down_meta <= key_down_n;
            down_sync <= down_meta;
            up_meta <= key_up_n;
            up_sync <= up_meta;
            down_pressed <= '0';
            up_pressed <= '0';

            if down_sync = down_stable then
                down_count <= 0;
            elsif down_count = DEBOUNCE_CYCLES - 1 then
                down_count <= 0;
                down_stable <= down_sync;
                if down_sync = '0' then down_pressed <= '1'; end if;
            else
                down_count <= down_count + 1;
            end if;

            if up_sync = up_stable then
                up_count <= 0;
            elsif up_count = DEBOUNCE_CYCLES - 1 then
                up_count <= 0;
                up_stable <= up_sync;
                if up_sync = '0' then up_pressed <= '1'; end if;
            else
                up_count <= up_count + 1;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if up_pressed = '1' and down_pressed = '0' and frequency_index < 5 then
                frequency_index <= frequency_index + 1;
            elsif down_pressed = '1' and up_pressed = '0' and frequency_index > 0 then
                frequency_index <= frequency_index - 1;
            end if;

            phase <= phase + phase_increment(frequency_index);
            dac_reg <= sine_lut(phase(31 downto 27));

            if refresh_count = REFRESH_CYCLES - 1 then
                refresh_count <= 0;
                selected_digit <= not selected_digit;
            else
                refresh_count <= refresh_count + 1;
            end if;
        end if;
    end process;

    display_number <= frequency_index + 1;
    display_value <= 0 when selected_digit = '1' else display_number;
    raw_seg <= seven_seg(display_value) & '0';
    raw_digit_en <= "01" when selected_digit = '1' else "10";

    dac <= std_logic_vector(dac_reg);
    seg <= not raw_seg;
    digit_en <= not raw_digit_en;
end architecture;
