library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
	generic (
		addressSize : natural := 8;
		wordSize 	: natural := 32
	);

	port (
		ck, wr : in bit;
		addr   : in bit_vector(addressSize-1 downto 0);
		data_i : in bit_vector(wordSize-1 downto 0);
		data_o : out bit_vector(wordSize-1 downto 0)
	);

end ram;

architecture behaviour of ram is
	type mem_tipo is array(0 to 2**addressSize) of bit_vector(wordSize-1 downto 0);
	signal mem: mem_tipo;
	signal address: integer;

begin
	write: process(ck)
	begin
		if (ck'event and ck = '1' and wr = '1') then
			mem(to_integer(unsigned(to_stdlogicvector(addr)))) <= data_i;
		end if;
	end process write;

	read: process(addr)
	begin
		data_o <= mem(to_integer(unsigned(to_stdlogicvector(addr))));
	end process read;
end behaviour;

	
	


