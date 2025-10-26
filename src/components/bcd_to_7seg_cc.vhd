----------------------------------------------------------------------------------
-- Entidad:   bcd_to_7seg_cc
-- Propósito: Decodificador combinacional. Convierte una entrada BCD (4 bits)
--            a una salida de 7 segmentos (más DP) para un display
--            de Cátodo Común (activo en alto).
-- Lógica:    Copia exacta de tu lógica original para DECODER_UNIDADES.
--            El 8vo bit (MSB) se asume como Punto Decimal (DP) y se
--            mantiene en '1' (apagado).
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bcd_to_7seg_cc is
    Port (
        bcd_in  : in  STD_LOGIC_VECTOR (3 downto 0); -- Entrada BCD (0000 a 1001)
        seg_out : out STD_LOGIC_VECTOR (7 downto 0)  -- Salida (a,b,c,d,e,f,g,dp)
    );
end bcd_to_7seg_cc;

architecture Combinational of bcd_to_7seg_cc is
begin

    -- Proceso combinacional (o un with-select) para decodificar
    -- (Seg_Out(7 downto 0) = (DP, g, f, e, d, c, b, a))
    -- Tu lógica original para 0-9:
    DECODER_LOGIC : with bcd_in select
        seg_out <=
            "11000000" when "0000", -- 0
            "11111001" when "0001", -- 1
            "10100100" when "0010", -- 2
            "10110000" when "0011", -- 3
            "10011001" when "0100", -- 4
            "10010010" when "0101", -- 5
            "10000010" when "0110", -- 6
            "11111000" when "0111", -- 7
            "10000000" when "1000", -- 8
            "10010000" when "1001", -- 9
            "00000000" when others; -- Apagado (Error)

end Combinational;
