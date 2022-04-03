library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;
use std.textio.all;

entity alucontrol is 
    port (
        aluop : in bit_vector(1 downto 0);
        opcode: in bit_vector(10 downto 0);
        aluCtrl: out bit_vector(3 downto 0)
    );
end entity;

architecture URGH2 of alucontrol is
    signal total : bit_vector(12 downto 0);

begin
    total(12 downto 11) <= aluop;
    total(10 downto 0) <= opcode;

    aluCtrl <= "0010" when total = "1010001011000" else
         "0110" when total = "1011001011000" else
         "0000" when total = "1010001010000" else
         "0001" when total = "1010101010000" else
         "0010" when total(12 downto 11) = "00" else
         "0111" when total(12 downto 11) = "01" else
         unaffected;
end URGH2;
