----------------------------------------------------------------------------------
-- Entidad:   hex_to_7seg_cc
-- Propósito: Decodificador combinacional para el display de POSICIÓN.
--            Convierte una entrada (0-5) a 7 segmentos Cátodo Común.
-- Lógica:    Copia exacta de tu lógica original para DECODER_POSICION.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hex_to_7seg_cc is
    Port (
        hex_in  : in  STD_LOGIC_VECTOR (3 downto 0); -- Entrada (x"0" a x"5")
        seg_out : out STD_LOGIC_VECTOR (7 downto 0)  -- Salida (a,b,c,d,e,f,g,dp)
    );
end hex_to_7seg_cc;

architecture Combinational of hex_to_7seg_cc is
begin

    -- Lógica de tu DECODER_POSICION original:
    DECODER_LOGIC : with hex_in select
        seg_out <=
            "11000000" when x"0", -- 0
            "11111001" when x"1", -- 1
            "10100100" when x"2", -- 2
            "10110000" when x"3", -- 3
            "10011001" when x"4", -- 4
            "10010010" when x"5", -- 5
            "00000000" when others; -- Apagado

end Combinational;
