----------------------------------------------------------------------------------
-- Entidad:   tick_generator
-- Propósito: Divisor de frecuencia genérico. Cuenta hasta un valor MÁXIMO
--            y genera un pulso 'tick' de un solo ciclo de reloj.
-- Genéricos:
--   MAX_COUNT: El valor final del contador (ej: 50_000_000 para 1 seg a 50MHz)
-- Puertos:
--   enable: Si está en '0', el contador se pausa.
--   tick_out: Pulso de 1 ciclo de reloj cuando se llega a MAX_COUNT.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tick_generator is
    Generic (
        MAX_COUNT : INTEGER := 50_000_000 -- Valor por defecto
    );
    Port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        enable   : in  STD_LOGIC; -- '1' para contar, '0' para pausar
        tick_out : out STD_LOGIC
    );
end tick_generator;

architecture Behavioral of tick_generator is
    -- Usamos un contador de tipo 'integer' que va de 0 a MAX_COUNT
    signal s_counter : integer range 0 to MAX_COUNT := 0;
begin

    TICK_PROC : process(clk, rst)
    begin
        if rst = '1' then
            s_counter <= 0;
            tick_out  <= '0';
        elsif rising_edge(clk) then
            -- Por defecto, el tick está en bajo
            tick_out <= '0';
            
            if enable = '1' then
                -- Si estamos habilitados, contamos
                if s_counter = MAX_COUNT then
                    s_counter <= 0;       -- Resetea el contador
                    tick_out  <= '1';       -- Genera el pulso
                else
                    s_counter <= s_counter + 1;
                end if;
            end if;
            
        end if;
    end process TICK_PROC;

end Behavioral;
