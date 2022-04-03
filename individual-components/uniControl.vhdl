library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;
use std.textio.all;

entity controlunit is
    port (
    -- To Datapath
        reg2loc : out bit ;
        uncondBranch : out bit ;
        branch : out bit ;
        memRead: out bit ;
        memToReg : out bit ;
        aluOp : out bit_vector(1 downto 0 ) ;
        memWrite : out bit ;
        aluSrc : out bit ;
        regWrite : out bit;
    --From Datapath
        opcode : in bit_vector(10 downto 0)
    ) ;
end entity ;

architecture URGH3 of controlunit is
    signal total : bit_vector(9 downto 0);
begin
    total(9 downto 0) <= "0000010001" when opcode(8 downto 7) = "00" or opcode(10 downto 7) = "1010" else
             "0001100011" when opcode = "11111000010" else
             "1000000110" when opcode = "11111000000" else
             "1010001000" when opcode(10 downto 3) = "10110100" else
             "0100001000" when opcode(10 downto 5) = "000101" else
             unaffected;
    
    reg2loc <= total(9);
    uncondBranch <= total(8);
    branch <= total(7);
    memRead <=total(6);
    memToReg <= total(5);
    aluOp <= total(4 downto 3);
    memWrite <= total(2);
    aluSrc <= total(1);
    regWrite <= total(0);
    
end URGH3;
    