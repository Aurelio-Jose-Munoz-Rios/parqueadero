
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity servo_fsm is
    Generic (
        FREQ_CLK : INTEGER := 50_000_000
    );
    Port (
        clk          : in  STD_LOGIC;
        rst          : in  STD_LOGIC;
        start_cmd    : in  STD_LOGIC;
        position_out : out INTEGER range 0 to 100; -- Posición (0-100%)
        busy_out     : out STD_LOGIC
    );
end servo_fsm;

architecture Behavioral of servo_fsm is
    -- Estados y señales de tiempo (de tu Sección 12)
    type servo_state_type is (IDLE, MOVING_TO_90, HOLDING_90, MOVING_TO_0);
    signal s_servo_state, s_servo_next_state : servo_state_type := IDLE;
    
    constant COUNT_1SEC_SERVO : integer := integer(FREQ_CLK);
    signal servo_timer_counter : integer range 0 to COUNT_1SEC_SERVO - 1 := 0;
    signal servo_seconds_counter : integer range 0 to 110 := 0;
    
    signal servo_position : integer range 0 to 100 := 0;
begin

    -- Proceso de Registro de Estado
    SERVO_STATE_REG_PROC : process(clk, rst)
    begin
        if rst = '1' then
            s_servo_state <= IDLE;
        elsif rising_edge(clk) then
            s_servo_state <= s_servo_next_state;
        end if;
    end process;
    
    -- Proceso de Temporizador de segundos
    SERVO_TIMER_PROC : process(clk, rst)
    begin
        if rst = '1' then
            servo_timer_counter <= 0;
            servo_seconds_counter <= 0;
        elsif rising_edge(clk) then
            if s_servo_state = IDLE then
                servo_timer_counter <= 0;
                servo_seconds_counter <= 0;
            else
                if servo_timer_counter < COUNT_1SEC_SERVO - 1 then
                    servo_timer_counter <= servo_timer_counter + 1;
                else
                    servo_timer_counter <= 0;
                    if servo_seconds_counter < 110 then
                        servo_seconds_counter <= servo_seconds_counter + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    -- Proceso de Lógica FSM (Combinacional)
    SERVO_STATE_LOGIC_PROC : process(s_servo_state, start_cmd, servo_seconds_counter)
    begin
        s_servo_next_state <= s_servo_state;
        case s_servo_state is
            when IDLE =>
                if start_cmd = '1' then
                    s_servo_next_state <= MOVING_TO_90;
                end if;
            when MOVING_TO_90 =>
                if servo_seconds_counter >= 30 then
                    s_servo_next_state <= HOLDING_90;
                end if;
            when HOLDING_90 =>
                if servo_seconds_counter >= 80 then
                    s_servo_next_state <= MOVING_TO_0;
                end if;
            when MOVING_TO_0 =>
                if servo_seconds_counter >= 110 then
                    s_servo_next_state <= IDLE;
                end if;
        end case;
    end process;
    
    -- Proceso de Control de posición
    SERVO_POSITION_PROC : process(clk, rst)
        variable target_position : integer range 0 to 100;
    begin
        if rst = '1' then
            servo_position <= 0;
        elsif rising_edge(clk) then
            case s_servo_state is
                when IDLE =>
                    servo_position <= 0; -- 0 grados
                when MOVING_TO_90 =>
                    target_position := (servo_seconds_counter * 100) / 30;
                    if target_position > 100 then servo_position <= 100;
                    else servo_position <= target_position;
                    end if;
                when HOLDING_90 =>
                    servo_position <= 100; -- 90 grados
                when MOVING_TO_0 =>
                    target_position := 100 - ((servo_seconds_counter - 80) * 100) / 30;
                    if target_position < 0 then servo_position <= 0;
                    else servo_position <= target_position;
                    end if;
            end case;
        end if;
    end process;
    
    -- Asignación de salidas
    position_out <= servo_position;
    busy_out <= '0' when s_servo_state = IDLE else '1';

end Behavioral;
