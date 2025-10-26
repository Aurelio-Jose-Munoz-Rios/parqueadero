-- Entidad:   top_level

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- La entidad (los puertos) sigue siendo la misma, 
-- ya que es la interfaz con el mundo exterior (la FPGA).
entity top_level is
    Generic (
        FREQ_CLK : INTEGER := 50_000_000 -- Frecuencia del reloj (50 MHz)
    );
    Port (
        clk             : in  STD_LOGIC; -- Reloj principal
        boton_reset     : in  STD_LOGIC; -- Reset asíncrono (Activo en '1')
        boton_inicio    : in  STD_LOGIC; -- Botón para iniciar la búsqueda de referencia
        sensor          : in  STD_LOGIC; -- Sensor de posición
        
        -- Puertos para el Teclado
        COLUMNAS        : in  STD_LOGIC_VECTOR(3 downto 0);
        FILAS           : out STD_LOGIC_VECTOR(3 downto 0);
        
        -- Puertos para el Motor
        step            : out STD_LOGIC;
        dir             : out STD_LOGIC;
        
        -- TRES SALIDAS DE DISPLAY
        seven_seg_out   : out STD_LOGIC_VECTOR(7 downto 0); -- Para Posición (0-5)
        seven_seg_out_D : out STD_LOGIC_VECTOR(7 downto 0); -- Para Tiempo (Decenas)
        seven_seg_out_U : out STD_LOGIC_VECTOR(7 downto 0); -- Para Tiempo (Unidades)
        
        -- Salidas para Sirena y LED
        sirena_out      : out STD_LOGIC;
        led_sirena_out  : out STD_LOGIC;
        
        -- Salida para el Servomotor
        servo_pwm_out   : out STD_LOGIC
    );
end top_level;

architecture Structural of top_level is

    -- --- 1. Declaraciones de Componentes ---
    -- (Aquí listamos todos los "ladrillos" que vamos a usar)

    -- Módulo para acondicionar botones (detecta flancos)
    component button_conditioner is
        Port (
            clk      : in  STD_LOGIC;
            rst      : in  STD_LOGIC;
            btn_in   : in  STD_LOGIC;
            tick_out : out STD_LOGIC  -- Pulso de 1 ciclo en flanco de bajada
        );
    end component;

    -- Módulo que maneja el teclado (incluye el remapeo)
    component keypad_manager is
        Generic (
            FREQ_CLK : INTEGER := 50_000_000
        );
        Port (
            clk           : in  STD_LOGIC;
            rst           : in  STD_LOGIC;
            COLUMNAS      : in  STD_LOGIC_VECTOR(3 downto 0);
            FILAS         : out STD_LOGIC_VECTOR(3 downto 0);
            key_value_out : out STD_LOGIC_VECTOR(3 downto 0); -- Valor remapeado
            key_strobe_out: out STD_LOGIC   -- Pulso de 1 ciclo al presionar
        );
    end component;

    -- Módulo del cronómetro (maneja los 6 contadores de tiempo)
    component parking_timer is
        Generic (
            FREQ_CLK : INTEGER := 50_000_000
        );
        Port (
            clk                   : in  STD_LOGIC;
            rst                   : in  STD_LOGIC;
            timer_running_vector_in : in  STD_LOGIC_VECTOR(5 downto 0); -- Indica qué timers correr
            blink_out             : out STD_LOGIC;                    -- Salida de parpadeo 1Hz
            accumulated_time_array: out time_array_t                  -- Array con los 6 tiempos
        );
    end component;
    -- (El tipo time_array_t debe estar en un paquete, pero por simplicidad
    --  lo declaramos aquí y en el módulo del timer)
    type time_array_t is array (0 to 5) of unsigned(5 downto 0);

    -- Módulo del servomotor
    component servo_control is
        Generic (
            FREQ_CLK : INTEGER := 50_000_000
        );
        Port (
            clk           : in  STD_LOGIC;
            rst           : in  STD_LOGIC;
            start_cmd     : in  STD_LOGIC; -- Pulso de inicio
            servo_pwm_out : out STD_LOGIC; -- Salida PWM
            busy_out      : out STD_LOGIC  -- '1' si el servo está ocupado
        );
    end component;

    -- Módulo de la sirena
    component siren_control is
        Generic (
            FREQ_CLK : INTEGER := 50_000_000
        );
        Port (
            clk        : in  STD_LOGIC;
            rst        : in  STD_LOGIC;
            start_cmd  : in  STD_LOGIC; -- Pulso de inicio
            sirena_out : out STD_LOGIC; -- Salida de audio
            active_out : out STD_LOGIC  -- '1' si la sirena está sonando
        );
    end component;

    -- Módulo de control del motor a pasos
    component stepper_control is
        Generic (
            STEP_PERIOD_CYCLES : INTEGER := 2_500_000 -- Valor de la constante
        );
        Port (
            clk      : in  STD_LOGIC;
            rst      : in  STD_LOGIC;
            enable   : in  STD_LOGIC; -- '1' para mover, '0' para detener
            dir_in   : in  STD_LOGIC; -- Dirección
            step_out : out STD_LOGIC; -- Pulsos de paso
            dir_out  : out STD_LOGIC  -- Salida de dirección (solo pasa la entrada)
        );
    end component;

    -- Módulo de control de los 3 displays 7-segmentos
    component display_manager is
        Generic (
            FREQ_CLK : INTEGER := 50_000_000
        );
        Port (
            clk               : in  STD_LOGIC;
            rst               : in  STD_LOGIC;
            target_pos_in     : in  STD_LOGIC_VECTOR(3 downto 0); -- Posición a mostrar
            target_pos_strobe : in  STD_LOGIC;                    -- Pulso para mostrar posición (10s)
            time_in           : in  unsigned(5 downto 0);         -- Tiempo/Pago a mostrar
            time_strobe       : in  STD_LOGIC;                    -- Pulso para mostrar tiempo/pago (10s)
            seg_out_pos       : out STD_LOGIC_VECTOR(7 downto 0);
            seg_out_time_D    : out STD_LOGIC_VECTOR(7 downto 0);
            seg_out_time_U    : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    
    -- Módulo "CEREBRO" (La máquina de estados principal)
    component parking_fsm is
        Port (
            clk                   : in  STD_LOGIC;
            rst                   : in  STD_LOGIC;
            -- Entradas de control
            start_btn_tick        : in  STD_LOGIC;
            sensor_edge_tick      : in  STD_LOGIC;
            key_value_in          : in  STD_LOGIC_VECTOR(3 downto 0);
            key_strobe_in         : in  STD_LOGIC;
            servo_busy_in         : in  STD_LOGIC;
            accumulated_time_in   : in  time_array_t;
            -- Salidas de comando
            motor_enable          : out STD_LOGIC;
            motor_dir             : out STD_LOGIC;
            servo_start_cmd       : out STD_LOGIC;
            siren_start_cmd       : out STD_LOGIC;
            timer_running_vector_out : out STD_LOGIC_VECTOR(5 downto 0);
            display_pos_strobe    : out STD_LOGIC;
            display_pos_value     : out STD_LOGIC_VECTOR(3 downto 0);
            display_time_strobe   : out STD_LOGIC;
            display_time_value    : out unsigned(5 downto 0)
        );
    end component;


    -- --- 2. Señales Internas ("Cables") ---
    -- (Estas señales conectan todos los módulos entre sí)

    -- Acondicionadores de entrada
    signal s_start_tick      : STD_LOGIC;
    signal s_sensor_tick     : STD_LOGIC;

    -- Teclado
    signal s_keypad_value    : STD_LOGIC_VECTOR(3 downto 0);
    signal s_keypad_strobe   : STD_LOGIC;
    
    -- Servo
    signal s_servo_start_cmd : STD_LOGIC;
    signal s_servo_busy      : STD_LOGIC;
    
    -- Sirena
    signal s_siren_start_cmd : STD_LOGIC;
    signal s_siren_active    : STD_LOGIC;
    
    -- Motor a Pasos
    signal s_motor_enable    : STD_LOGIC;
    signal s_motor_dir       : STD_LOGIC;

    -- Cronómetro
    signal s_timer_running_vector : STD_LOGIC_VECTOR(5 downto 0);
    signal s_blink_1hz            : STD_LOGIC;
    signal s_time_array           : time_array_t;

    -- Displays
    signal s_display_pos_strobe   : STD_LOGIC;
    signal s_display_pos_value    : STD_LOGIC_VECTOR(3 downto 0);
    signal s_display_time_strobe  : STD_LOGIC;
    signal s_display_time_value   : unsigned(5 downto 0);


begin

    -- --- 3. Instanciación de Componentes ---
    -- (Aquí "pinchamos" cada componente en la placa y conectamos los cables)

    -- Acondiciona el botón de inicio
    U_BTN_START : button_conditioner
        Port map (
            clk      => clk,
            rst      => boton_reset,
            btn_in   => boton_inicio,
            tick_out => s_start_tick
        );

    -- Acondiciona el sensor de posición
    U_SENSOR : button_conditioner
        Port map (
            clk      => clk,
            rst      => boton_reset,
            btn_in   => sensor,
            tick_out => s_sensor_tick
        );

    -- Manejador del teclado
    U_KEYPAD : keypad_manager
        Generic map (
            FREQ_CLK => FREQ_CLK
        )
        Port map (
            clk            => clk,
            rst            => boton_reset,
            COLUMNAS       => COLUMNAS,
            FILAS          => FILAS,
            key_value_out  => s_keypad_value,
            key_strobe_out => s_keypad_strobe
        );

    -- Controlador del Servomotor
    U_SERVO : servo_control
        Generic map (
            FREQ_CLK => FREQ_CLK
        )
        Port map (
            clk           => clk,
            rst           => boton_reset,
            start_cmd     => s_servo_start_cmd,
            servo_pwm_out => servo_pwm_out,
            busy_out      => s_servo_busy
        );

    -- Controlador de la Sirena
    U_SIREN : siren_control
        Generic map (
            FREQ_CLK => FREQ_CLK
        )
        Port map (
            clk        => clk,
            rst        => boton_reset,
            start_cmd  => s_siren_start_cmd,
            sirena_out => sirena_out,
            active_out => s_siren_active
        );

    -- Controlador del Cronómetro
    U_TIMER : parking_timer
        Generic map (
            FREQ_CLK => FREQ_CLK
        )
        Port map (
            clk                     => clk,
            rst                     => boton_reset,
            timer_running_vector_in => s_timer_running_vector,
            blink_out               => s_blink_1hz,
            accumulated_time_array  => s_time_array
        );
        
    -- Controlador de los Displays
    U_DISPLAY : display_manager
        Generic map (
            FREQ_CLK => FREQ_CLK
        )
        Port map (
            clk               => clk,
            rst               => boton_reset,
            target_pos_in     => s_display_pos_value,
            target_pos_strobe => s_display_pos_strobe,
            time_in           => s_display_time_value,
            time_strobe       => s_display_time_strobe,
            seg_out_pos       => seven_seg_out,
            seg_out_time_D    => seven_seg_out_D,
            seg_out_time_U    => seven_seg_out_U
        );

    -- Controlador del Motor a Pasos
    U_STEPPER : stepper_control
        Generic map (
            -- Este valor (2.5M) es el que tenías, ajústalo para la velocidad
            STEP_PERIOD_CYCLES => 2_500_000 
        )
        Port map (
            clk      => clk,
            rst      => boton_reset,
            enable   => s_motor_enable,
            dir_in   => s_motor_dir,
            step_out => step,
            dir_out  => dir
        );

    -- EL CEREBRO: Máquina de Estados Principal
    U_FSM_BRAIN : parking_fsm
        Port map (
            clk                   => clk,
            rst                   => boton_reset,
            -- Entradas
            start_btn_tick        => s_start_tick,
            sensor_edge_tick      => s_sensor_tick,
            key_value_in          => s_keypad_value,
            key_strobe_in         => s_keypad_strobe,
            servo_busy_in         => s_servo_busy,
            accumulated_time_in   => s_time_array,
            -- Salidas
            motor_enable          => s_motor_enable,
            motor_dir             => s_motor_dir,
            servo_start_cmd       => s_servo_start_cmd,
            siren_start_cmd       => s_siren_start_cmd,
            timer_running_vector_out => s_timer_running_vector,
            display_pos_strobe    => s_display_pos_strobe,
            display_pos_value     => s_display_pos_value,
            display_time_strobe   => s_display_time_strobe,
            display_time_value    => s_display_time_value
        );


    -- --- 4. Lógica Concurrente (Mínima) ---
    -- La única lógica que queda aquí es la del LED, que depende
    -- de las salidas de dos módulos diferentes.
    
    led_sirena_out <= '1' when s_siren_active = '1' else
                      s_blink_1hz when s_timer_running_vector = "111111" else
                      '0';

end Structural;
