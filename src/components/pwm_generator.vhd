
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity pwm_generator is
    Generic (
        FREQ_CLK : INTEGER := 50_000_000
    );
    Port (
        clk         : in  STD_LOGIC;
        rst         : in  STD_LOGIC;
        position_in : in  INTEGER range 0 to 100; -- Posición (0-100%)
        pwm_out     : out STD_LOGIC
    );
end pwm_generator;

architecture Behavioral of pwm_generator is
    -- Constantes PWM (de tu Sección 12)
    constant CLK_HZ          : real := real(FREQ_CLK);
    constant PULSE_HZ        : real := 50.0;
    constant MIN_PULSE_US    : real := 1000.0;
    constant MAX_PULSE_US    : real := 2000.0;
    
    function cycles_per_us(us_count : real) return integer is
    begin
        return integer(round(CLK_HZ / 1.0e6 * us_count));
    end function;
        
    constant MIN_COUNT       : integer := cycles_per_us(MIN_PULSE_US);
    constant MAX_COUNT       : integer := cycles_per_us(MAX_PULSE_US);
    constant COUNTER_MAX     : integer := integer(round(CLK_HZ / PULSE_HZ)) - 1;
    constant CYCLES_PER_STEP : integer := (MAX_COUNT - MIN_COUNT) / 100;

    -- Señales para PWM
    signal servo_duty_cycle : integer := MIN_COUNT;
    signal pwm_counter      : integer range 0 to COUNTER_MAX := 0;
begin

    -- Proceso de Generador PWM (Contador)
    SERVO_PWM_COUNTER_PROC : process(clk, rst)
    begin
        if rst = '1' then
            pwm_counter <= 0;
        elsif rising_edge(clk) then
            if pwm_counter < COUNTER_MAX then
                pwm_counter <= pwm_counter + 1;
            else
                pwm_counter <= 0;
            end if;
        end if;
    end process;
    
    -- Proceso de Cálculo del duty cycle
    SERVO_DUTY_CYCLE_PROC : process(clk, rst)
    begin
        if rst = '1' then
            servo_duty_cycle <= MIN_COUNT;
        elsif rising_edge(clk) then
            -- Se actualiza basado en la posición de entrada
            servo_duty_cycle <= position_in * CYCLES_PER_STEP + MIN_COUNT;
        end if;
    end process;
    
    -- Lógica final de PWM (Comparador)
    pwm_out <= '1' when pwm_counter < servo_duty_cycle else '0';

end Behavioral;
