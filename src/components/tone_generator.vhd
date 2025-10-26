library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tone_generator is
    Port (
        clk        : in  STD_LOGIC;
        rst        : in  STD_LOGIC;
        enable     : in  STD_LOGIC; -- '1' para sonar, '0' para silencio
        tone_period_in : in  INTEGER;   -- Período de la nota
        wave_out   : out STD_LOGIC  -- Onda cuadrada
    );
end tone_generator;

architecture Behavioral of tone_generator is
    signal s_tone_counter : integer := 0;
    signal s_buzzer_wave  : std_logic := '0';
begin
    -- Proceso Generador de Onda (Tu Sección 11)
    PROCESS_SIRENA_WAVE : process(clk, rst)
    begin
        if rst = '1' then
            s_tone_counter <= 0;
            s_buzzer_wave  <= '0';
        elsif rising_edge(clk) then
            if enable = '1' then
                if s_tone_counter < tone_period_in - 1 then
                    s_tone_counter <= s_tone_counter + 1;
                else
                    s_tone_counter <= 0;
                    s_buzzer_wave  <= not s_buzzer_wave;
                end if;
            else
                s_tone_counter <= 0;
                s_buzzer_wave  <= '0';
            end if;
        end if;
    end process PROCESS_SIRENA_WAVE;
    
    wave_out <= s_buzzer_wave;

end Behavioral;
