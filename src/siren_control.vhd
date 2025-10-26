library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity siren_control is
    Generic (
        FREQ_CLK : INTEGER := 50_000_000
    );
    Port (
        clk        : in  STD_LOGIC;
        rst        : in  STD_LOGIC;
        start_cmd  : in  STD_LOGIC;
        sirena_out : out STD_LOGIC;
        active_out : out STD_LOGIC
    );
end siren_control;

architecture Structural of siren_control is

    component siren_sequencer is
        Generic ( FREQ_CLK : INTEGER );
        Port (
            clk             : in  STD_LOGIC;
            rst             : in  STD_LOGIC;
            start_cmd       : in  STD_LOGIC;
            tone_period_out : out INTEGER;
            active_out      : out STD_LOGIC
        );
    end component;
    
    component tone_generator is
        Port (
            clk            : in  STD_LOGIC;
            rst            : in  STD_LOGIC;
            enable         : in  STD_LOGIC;
            tone_period_in : in  INTEGER;
            wave_out       : out STD_LOGIC
        );
    end component;

    -- Señales internas para conectar los dos módulos
    signal s_tone_period : INTEGER;
    signal s_active      : STD_LOGIC;

begin

    -- Instancia del secuenciador
    U_SEQUENCER : siren_sequencer
        Generic map ( FREQ_CLK => FREQ_CLK )
        Port map (
            clk             => clk,
            rst             => rst,
            start_cmd       => start_cmd,
            tone_period_out => s_tone_period,
            active_out      => s_active
        );
        
    -- Instancia del generador de tono
    U_GENERATOR : tone_generator
        Port map (
            clk            => clk,
            rst            => rst,
            enable         => s_active, -- Habilitado solo si el secuenciador lo dice
            tone_period_in => s_tone_period,
            wave_out       => sirena_out -- Salida directa al pin
        );
        
    -- Asigna la salida 'active'
    active_out <= s_active;

end Structural;
