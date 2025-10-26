
----------------------------------------------------------------------------------
-- Entidad:   parking_timer (Refactorizado)
-- Propósito: Genera la base de tiempo de 1 segundo (usando tick_generator)
--            y gestiona la acumulación de tiempo para los 6 parqueaderos.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Definimos el tipo de array
type time_array_t is array (0 to 5) of unsigned(5 downto 0);

entity parking_timer is
    Generic (
        FREQ_CLK : INTEGER := 50_000_000
    );
    Port (
        clk                   : in  STD_LOGIC;
        rst                   : in  STD_LOGIC;
        timer_running_vector_in : in  STD_LOGIC_VECTOR(5 downto 0);
        blink_out             : out STD_LOGIC;
        accumulated_time_array: out time_array_t
    );
end parking_timer;

architecture Behavioral of parking_timer is

    -- Componente del divisor de frecuencia
    component tick_generator is
        Generic (
            MAX_COUNT : INTEGER
        );
        Port (
            clk      : in  STD_LOGIC;
            rst      : in  STD_LOGIC;
            enable   : in  STD_LOGIC;
            tick_out : out STD_LOGIC
        );
    end component;

    -- Constante para el tick de 1 segundo
    constant CICLOS_POR_SEG : integer := FREQ_CLK - 1;
    
    -- Señales internas
    signal s_tick_1s          : std_logic := '0';
    signal s_blink_toggle     : std_logic := '0';
    signal s_accumulated_time : time_array_t := (others => (others => '0'));

begin

    -- Instancia del generador de tick de 1 segundo
    U_TICK_1S : tick_generator
        Generic map (
            MAX_COUNT => CICLOS_POR_SEG
        )
        Port map (
            clk      => clk,
            rst      => rst,
            enable   => '1', -- Siempre habilitado
            tick_out => s_tick_1s
        );

    -- Proceso de acumulación (ahora solo reacciona al tick)
    TIMER_ACCUM_PROC : process(clk, rst)
    begin
        if rst = '1' then
            s_blink_toggle     <= '0';
            s_accumulated_time <= (others => (others => '0'));
            
        elsif rising_edge(clk) then
            
            -- Solo se ejecuta cuando hay un tick de 1 segundo
            if s_tick_1s = '1' then
                
                -- Lógica de parpadeo (1s ON, 1s OFF)
                s_blink_toggle <= not s_blink_toggle;
                
                -- Lógica de acumuladores
                for i in 0 to 5 loop
                    if timer_running_vector_in(i) = '1' then
                        if s_accumulated_time(i) = 59 then
                            s_accumulated_time(i) <= (others => '0');
                        else
                            s_accumulated_time(i) <= s_accumulated_time(i) + 1;
                        end if;
                    end if;
                end loop;
            end if;
            
        end if;
    end process TIMER_ACCUM_PROC;

    -- Asignaciones concurrentes a las salidas
    blink_out            <= s_blink_toggle;
    accumulated_time_array <= s_accumulated_time;

end Behavioral;
