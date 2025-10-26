
----------------------------------------------------------------------------------
-- Entidad:   stepper_control (Refactorizado)
-- Propósito: Genera los pulsos 'step' para el motor a pasos usando un
--            'tick_generator' genérico.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity stepper_control is
    Generic (
        -- El período (en ciclos) entre pulsos. 
        STEP_PERIOD_CYCLES : INTEGER := 2_500_000 
    );
    Port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        enable   : in  STD_LOGIC; -- '1' para mover, '0' para detener
        dir_in   : in  STD_LOGIC; -- Dirección deseada
        step_out : out STD_LOGIC; -- Pulsos de paso
        dir_out  : out STD_LOGIC  -- Salida de dirección
    );
end stepper_control;

architecture Behavioral of stepper_control is

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

    signal s_step_tick : std_logic;
    signal s_step_reg  : std_logic := '0';
    
begin

    -- Instancia del generador de pulsos 'step'
    U_STEP_TICK : tick_generator
        Generic map (
            MAX_COUNT => STEP_PERIOD_CYCLES
        )
        Port map (
            clk      => clk,
            rst      => rst,
            enable   => enable, -- Se habilita solo cuando el FSM lo ordena
            tick_out => s_step_tick
        );

    -- Proceso que genera la onda cuadrada (toggle)
    STEPPER_WAVE_PROC : process(clk, rst)
    begin
        if rst = '1' then
            s_step_reg <= '0';
        elsif rising_edge(clk) then
            if enable = '0' then
                s_step_reg <= '0'; -- Resetea el pulso si está deshabilitado
            elsif s_step_tick = '1' then
                s_step_reg <= not s_step_reg; -- Invierte la salida en cada tick
            end if;
        end if;
    end process STEPPER_WAVE_PROC;

    -- Asignaciones finales
    step_out <= s_step_reg; -- El pulso de salida
    dir_out  <= dir_in;   -- Pasa la dirección directamente

end Behavioral;
