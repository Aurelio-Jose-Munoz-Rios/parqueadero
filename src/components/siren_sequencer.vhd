
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity siren_sequencer is
    Generic (
        FREQ_CLK : INTEGER := 50_000_000
    );
    Port (
        clk             : in  STD_LOGIC;
        rst             : in  STD_LOGIC;
        start_cmd       : in  STD_LOGIC;
        tone_period_out : out INTEGER;   -- Salida: El período de la nota actual
        active_out      : out STD_LOGIC    -- Salida: '1' si está sonando
    );
end siren_sequencer;

architecture Behavioral of siren_sequencer is
    -- Constantes de notas
    type freq_array is array (0 to 7) of integer;
    constant NOTE_FREQS : freq_array := (
        523, 587, 659, 698, 784, 880, 988, 1047
    );
    constant NOTE_DURATION_MS     : integer := 60;
    constant NOTE_DURATION_CYCLES : integer := FREQ_CLK / 1000 * NOTE_DURATION_MS;

    -- Señales internas
    signal s_tone_period     : integer := 10000;
    signal s_note_timer      : integer := 0;
    signal s_note_index      : integer range 0 to 7 := 0;
    signal s_sequence_active : std_logic := '0';
begin

    -- Proceso Secuenciador (Tu Sección 10)
    PROCESS_SIRENA_SEQ : process(clk, rst)
    begin
        if rst = '1' then
            s_sequence_active <= '0';
            s_note_index      <= 0;
            s_note_timer      <= 0;
            s_tone_period     <= 10000;
        elsif rising_edge(clk) then
            if start_cmd = '1' and s_sequence_active = '0' then -- Inicia solo si no está activo
                s_sequence_active <= '1';
                s_note_index      <= 0;
                s_note_timer      <= 0;
                s_tone_period     <= FREQ_CLK / (2 * NOTE_FREQS(0));
            end if;
            
            if s_sequence_active = '1' then
                if s_note_timer < NOTE_DURATION_CYCLES then
                    s_note_timer <= s_note_timer + 1;
                else -- Cambiar de nota
                    s_note_timer <= 0;
                    if s_note_index < 7 then
                        s_note_index  <= s_note_index + 1;
                        s_tone_period <= FREQ_CLK / (2 * NOTE_FREQS(s_note_index + 1)); -- Próxima nota
                    else -- Se acabaron las notas
                        s_sequence_active <= '0';
                        s_note_index      <= 0;
                    end if;
                end if;
            end if;
        end if;
    end process PROCESS_SIRENA_SEQ;
    
    -- Asignación de salidas
    tone_period_out <= s_tone_period;
    active_out      <= s_sequence_active;

end Behavioral;
