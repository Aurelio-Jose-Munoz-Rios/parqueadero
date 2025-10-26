
----------------------------------------------------------------------------------
-- Entidad:   display_manager (Refactorizado)
-- Propósito: Controla los 3 displays. Gestiona los timers de 10 segundos
--            e instancia los decodificadores BCD y HEX por separado.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_manager is
    Generic (
        FREQ_CLK : INTEGER := 50_000_000
    );
    Port (
        clk               : in  STD_LOGIC;
        rst               : in  STD_LOGIC;
        target_pos_in     : in  STD_LOGIC_VECTOR(3 downto 0);
        target_pos_strobe : in  STD_LOGIC;
        time_in           : in  unsigned(5 downto 0);
        time_strobe       : in  STD_LOGIC;
        seg_out_pos       : out STD_LOGIC_VECTOR(7 downto 0);
        seg_out_time_D    : out STD_LOGIC_VECTOR(7 downto 0);
        seg_out_time_U    : out STD_LOGIC_VECTOR(7 downto 0)
    );
end display_manager;

architecture Structural of display_manager is

    -- --- Componentes de los decodificadores ---
    component hex_to_7seg_cc is
        Port (
            hex_in  : in  STD_LOGIC_VECTOR (3 downto 0);
            seg_out : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;
    
    component bcd_to_7seg_cc is
        Port (
            bcd_in  : in  STD_LOGIC_VECTOR (3 downto 0);
            seg_out : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    -- --- Constantes ---
    constant DISPLAY_TIME_10S : unsigned(31 downto 0) := to_unsigned(500_000_000, 32);
    constant SEVEN_SEG_OFF    : std_logic_vector(7 downto 0) := (others => '0');

    -- --- Señales para el display de POSICIÓN ---
    signal s_pos_timer_active : std_logic := '0';
    signal s_pos_timer_reg    : unsigned(31 downto 0) := (others => '0');
    signal s_pos_display_digit: std_logic_vector(3 downto 0) := (others => '0');

    -- --- Señales para el display de TIEMPO ---
    signal s_time_timer_active  : std_logic := '0';
    signal s_time_timer_reg   : unsigned(31 downto 0) := (others => '0');
    signal s_time_display_value : unsigned(5 downto 0) := (others => '0');
    signal s_disp_decenas_val   : std_logic_vector(3 downto 0);
    signal s_disp_unidades_val  : std_logic_vector(3 downto 0);
    
    -- Señales de salida de los decos
    signal s_pos_seg_out      : std_logic_vector(7 downto 0);
    signal s_disp_decenas_seg : std_logic_vector(7 downto 0);
    signal s_disp_unidades_seg: std_logic_vector(7 downto 0);

begin

    -- --- Proceso de Control de Timers de Display ---
    -- (Esta lógica es la misma de antes)
    DISPLAY_TIMER_PROC : process(clk, rst)
    begin
        if rst = '1' then
            s_pos_timer_active  <= '0';
            s_pos_timer_reg     <= (others => '0');
            s_pos_display_digit <= (others => '0');
            s_time_timer_active <= '0';
            s_time_timer_reg    <= (others => '0');
            s_time_display_value <= (others => '0');
        elsif rising_edge(clk) then
            if target_pos_strobe = '1' then
                s_pos_timer_active  <= '1';
                s_pos_timer_reg     <= (others => '0');
                s_pos_display_digit <= target_pos_in;
                s_time_timer_active <= '0';
            end if;
            if s_pos_timer_active = '1' then
                if s_pos_timer_reg < DISPLAY_TIME_10S then
                    s_pos_timer_reg <= s_pos_timer_reg + 1;
                else
                    s_pos_timer_active <= '0';
                end if;
            end if;
            if time_strobe = '1' then
                s_time_timer_active  <= '1';
                s_time_timer_reg     <= (others => '0');
                s_time_display_value <= time_in;
                s_pos_timer_active   <= '0';
            end if;
            if s_time_timer_active = '1' then
                if s_time_timer_reg < DISPLAY_TIME_10S then
                    s_time_timer_reg <= s_time_timer_reg + 1;
                else
                    s_time_timer_active <= '0';
                end if;
            end if;
        end if;
    end process DISPLAY_TIMER_PROC;
    
    -- --- Lógica Combinacional de Descomposición BCD ---
    PROCESS_DECOMP : process(s_time_display_value)
        variable v_time_int : integer;
    begin
        v_time_int := to_integer(s_time_display_value);
        s_disp_decenas_val  <= std_logic_vector(to_unsigned(v_time_int / 10, 4));
        s_disp_unidades_val <= std_logic_vector(to_unsigned(v_time_int mod 10, 4));
    end process PROCESS_DECOMP;

    -- --- Instanciación de Decodificadores ---
    
    -- Deco de Posición
    U_DECO_POS : hex_to_7seg_cc
        Port map (
            hex_in  => s_pos_display_digit,
            seg_out => s_pos_seg_out
        );
        
    -- Deco de Tiempo - Decenas
    U_DECO_DECENAS : bcd_to_7seg_cc
        Port map (
            bcd_in  => s_disp_decenas_val,
            seg_out => s_disp_decenas_seg
        );

    -- Deco de Tiempo - Unidades
    U_DECO_UNIDADES : bcd_to_7seg_cc
        Port map (
            bcd_in  => s_disp_unidades_val,
            seg_out => s_disp_unidades_seg
        );

    -- --- Asignación final a las salidas ---
    -- (Habilita la salida solo si el timer correspondiente está activo)
    seg_out_pos    <= s_pos_seg_out    when s_pos_timer_active = '1'  else SEVEN_SEG_OFF;
    seg_out_time_D <= s_disp_decenas_seg when s_time_timer_active = '1' else SEVEN_SEG_OFF;
    seg_out_time_U <= s_disp_unidades_seg when s_time_timer_active = '1' else SEVEN_SEG_OFF;

end Structural;
