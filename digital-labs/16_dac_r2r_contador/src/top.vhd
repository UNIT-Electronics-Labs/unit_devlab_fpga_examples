library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        clk : in std_logic;
        key_reset_n : in std_logic;
        key_enable_n : in std_logic;
        dac : out std_logic_vector(7 downto 0);
        seg : out std_logic_vector(7 downto 0);
        digit_en : out std_logic_vector(1 downto 0)
    );
end entity;

architecture rtl of top is
    constant CLK_HZ : natural := 27000000;
    constant WAVE_HZ : natural := 1000;
    constant REFRESH_HZ : natural := 1000;
    constant TRIANGLE_STEP_MAX : natural := CLK_HZ / (WAVE_HZ * 512);
    constant SAW_STEP_MAX : natural := CLK_HZ / (WAVE_HZ * 256);
    constant WAVE_STEP_MAX : natural := CLK_HZ / (WAVE_HZ * 32);
    constant DEBOUNCE_MAX : natural := CLK_HZ / 100;
    constant REFRESH_MAX : natural := CLK_HZ / (REFRESH_HZ * 2);

    constant MODE_TRIANGLE : natural := 0;
    constant MODE_SAW : natural := 1;
    constant MODE_SQUARE : natural := 2;
    constant MODE_SINE : natural := 3;

    signal sample_div : natural range 0 to WAVE_STEP_MAX - 1 := 0;
    signal debounce_count : natural range 0 to DEBOUNCE_MAX - 1 := 0;
    signal refresh_div : natural range 0 to REFRESH_MAX - 1 := 0;
    signal triangle_phase : unsigned(8 downto 0) := (others => '0');
    signal saw_value : unsigned(7 downto 0) := (others => '0');
    signal phase : unsigned(4 downto 0) := (others => '0');
    signal mode : natural range 0 to 3 := MODE_TRIANGLE;
    signal mode_meta : std_logic := '1';
    signal mode_sync : std_logic := '1';
    signal mode_stable : std_logic := '1';
    signal selected_digit : std_logic := '0';
    signal dac_reg : unsigned(7 downto 0) := (others => '0');

    function seven_seg(value : natural) return std_logic_vector is
    begin
        case value is
            when 0 => return "1111110";
            when 1 => return "0110000";
            when 2 => return "1101101";
            when 3 => return "1111001";
            when 4 => return "0110011";
            when 5 => return "1011011";
            when 6 => return "1011111";
            when 7 => return "1110000";
            when 8 => return "1111111";
            when 9 => return "1111011";
            when others => return "0000000";
        end case;
    end function;

    function sine_lut(addr : unsigned(4 downto 0)) return unsigned is
    begin
        case to_integer(addr) is
            when 0  => return to_unsigned(128, 8);
            when 1  => return to_unsigned(153, 8);
            when 2  => return to_unsigned(177, 8);
            when 3  => return to_unsigned(199, 8);
            when 4  => return to_unsigned(218, 8);
            when 5  => return to_unsigned(234, 8);
            when 6  => return to_unsigned(245, 8);
            when 7  => return to_unsigned(253, 8);
            when 8  => return to_unsigned(255, 8);
            when 9  => return to_unsigned(253, 8);
            when 10 => return to_unsigned(245, 8);
            when 11 => return to_unsigned(234, 8);
            when 12 => return to_unsigned(218, 8);
            when 13 => return to_unsigned(199, 8);
            when 14 => return to_unsigned(177, 8);
            when 15 => return to_unsigned(153, 8);
            when 16 => return to_unsigned(128, 8);
            when 17 => return to_unsigned(103, 8);
            when 18 => return to_unsigned(79, 8);
            when 19 => return to_unsigned(57, 8);
            when 20 => return to_unsigned(38, 8);
            when 21 => return to_unsigned(22, 8);
            when 22 => return to_unsigned(11, 8);
            when 23 => return to_unsigned(3, 8);
            when 24 => return to_unsigned(0, 8);
            when 25 => return to_unsigned(3, 8);
            when 26 => return to_unsigned(11, 8);
            when 27 => return to_unsigned(22, 8);
            when 28 => return to_unsigned(38, 8);
            when 29 => return to_unsigned(57, 8);
            when 30 => return to_unsigned(79, 8);
            when 31 => return to_unsigned(103, 8);
            when others => return to_unsigned(128, 8);
        end case;
    end function;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            mode_meta <= key_enable_n;
            mode_sync <= mode_meta;

            if key_reset_n = '0' then
                sample_div <= 0;
                debounce_count <= 0;
                triangle_phase <= (others => '0');
                saw_value <= (others => '0');
                phase <= (others => '0');
                mode <= MODE_TRIANGLE;
                mode_stable <= '1';
                dac_reg <= (others => '0');
            else
                if mode_sync = mode_stable then
                    debounce_count <= 0;
                elsif debounce_count = DEBOUNCE_MAX - 1 then
                    debounce_count <= 0;
                    mode_stable <= mode_sync;

                    if mode_sync = '0' then
                        if mode = MODE_SINE then
                            mode <= MODE_TRIANGLE;
                        else
                            mode <= mode + 1;
                        end if;

                        triangle_phase <= (others => '0');
                        saw_value <= (others => '0');
                        phase <= (others => '0');
                        dac_reg <= (others => '0');
                    end if;
                else
                    debounce_count <= debounce_count + 1;
                end if;

                if ((mode = MODE_TRIANGLE) and (sample_div = TRIANGLE_STEP_MAX - 1)) or
                   ((mode = MODE_SAW) and (sample_div = SAW_STEP_MAX - 1)) or
                   (((mode = MODE_SQUARE) or (mode = MODE_SINE)) and (sample_div = WAVE_STEP_MAX - 1)) then
                    sample_div <= 0;

                    case mode is
                        when MODE_SAW =>
                            dac_reg <= saw_value;
                            saw_value <= saw_value + 1;

                        when MODE_SQUARE =>
                            if phase(4) = '1' then
                                dac_reg <= (others => '1');
                            else
                                dac_reg <= (others => '0');
                            end if;
                            phase <= phase + 1;

                        when MODE_SINE =>
                            dac_reg <= sine_lut(phase);
                            phase <= phase + 1;

                        when others =>
                            if triangle_phase(8) = '1' then
                                dac_reg <= not triangle_phase(7 downto 0);
                            else
                                dac_reg <= triangle_phase(7 downto 0);
                            end if;
                            triangle_phase <= triangle_phase + 1;
                    end case;
                else
                    sample_div <= sample_div + 1;
                end if;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
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

    process(mode, selected_digit)
        variable raw_seg : std_logic_vector(7 downto 0);
        variable raw_digit_en : std_logic_vector(1 downto 0);
        variable selected_bcd : natural range 0 to 9;
    begin
        if selected_digit = '1' then
            selected_bcd := 0;
            raw_digit_en := "01";
        else
            selected_bcd := mode + 1;
            raw_digit_en := "10";
        end if;

        raw_seg := seven_seg(selected_bcd) & '0';
        seg <= not raw_seg;
        digit_en <= not raw_digit_en;
    end process;

    dac <= std_logic_vector(dac_reg);
end architecture;
