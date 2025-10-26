
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity servo_control is
    Generic (
        FREQ_CLK : INTEGER := 50_000_000
    );
    Port (
        clk           : in  STD_LOGIC;
        rst           : in  STD_LOGIC;
        start_cmd     : in  STD_LOGIC;
        servo_pwm_out : out STD_LOGIC;
        busy_out      : out STD_LOGIC
    );
end servo_control;

architecture Structural of servo_control is

    component servo_fsm is
        Generic ( FREQ_CLK : INTEGER );
        Port (
            clk          : in  STD_LOGIC;
            rst          : in  STD_LOGIC;
            start_cmd    : in  STD_LOGIC;
            position_out : out INTEGER range 0 to 100;
            busy_out     : out STD_LOGIC
        );
    end component;
    
    component pwm_generator is
        Generic ( FREQ_CLK : INTEGER );
        Port (
            clk         : in  STD_LOGIC;
            rst         : in  STD_LOGIC;
            position_in : in  INTEGER range 0 to 100;
            pwm_out     : out STD_LOGIC
        );
    end component;
    
    -- Señal interna para conectar FSM -> PWM
    signal s_position : INTEGER range 0 to 100;
    
begin

    -- Instancia de la FSM del servo
    U_FSM : servo_fsm
        Generic map ( FREQ_CLK => FREQ_CLK )
        Port map (
            clk          => clk,
            rst          => rst,
            start_cmd    => start_cmd,
            position_out => s_position, -- Salida: posición deseada
            busy_out     => busy_out    -- Salida: ocupado
        );
        
    -- Instancia del generador PWM
    U_PWM : pwm_generator
        Generic map ( FREQ_CLK => FREQ_CLK )
        Port map (
            clk         => clk,
            rst         => rst,
            position_in => s_position,    -- Entrada: posición deseada
            pwm_out     => servo_pwm_out  -- Salida: PWM
        );

end Structural;
