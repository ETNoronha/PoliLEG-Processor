library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;
use std.textio.all;

entity rom is
    generic (
        addressSize : natural := 3 ;
        wordSize    : natural := 5 ;
        mifFileName : string := "rom.dat"
    );
    port (
		addr   : in bit_vector(addressSize-1 downto 0);
		data   : out bit_vector(wordSize-1 downto 0)
	);

end rom;

architecture behaviour of rom is
    
    type mem_t is array(0 to 2**addressSize-1) of bit_vector(wordSize-1 downto 0);
    
    impure function inicializa(nome_do_arquivo : in string) return mem_t is
        file     arquivo  : text open read_mode is nome_do_arquivo;
        variable linha    : line;
        variable temp_bv  : bit_vector(wordSize-1 downto 0);
        variable temp_mem : mem_t;
    begin
        for i in mem_t'range loop
            readline(arquivo, linha);
            read(linha, temp_bv);
            temp_mem(i) := temp_bv;
        end loop;
        return temp_mem;
    end;

    constant mem : mem_t := inicializa(mifFileName);

begin
    data <= mem(to_integer(unsigned(addr)));
end behaviour;
