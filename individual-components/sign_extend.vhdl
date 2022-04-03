library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;
use std.textio.all;

entity signExtend is
    port (
        i : in  bit_vector(31 downto 0);
        o : out bit_vector(63 downto 0)
    );
end signExtend;

architecture URGH of signExtend is
begin
    o <= bit_vector(resize(signed(i(20 downto 12)), o'length)) when i(31 downto 21) = "11111000010" else
        bit_vector(resize(signed(i(20 downto 12)), o'length)) when i(31 downto 21) = "11111000000" else
        bit_vector(resize(signed(i(23 downto 5)), o'length)) when i(31 downto 24) = "10110100" else
        bit_vector(resize(signed(i(25 downto 0)), o'length)) when i(31 downto 26) = "000101" else
        unaffected;
end URGH;
