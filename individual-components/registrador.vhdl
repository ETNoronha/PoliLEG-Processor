library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is
    generic(wordSize: natural := 4);
    port(
        clock: in  bit;
        reset: in  bit;
        load:  in  bit;
        d:     in  bit_vector(wordSize-1 downto 0);
        q:     out bit_vector(wordSize-1 downto 0)
    );
end reg;

architecture behavior of reg is
begin
    process(clock, reset)
    begin
        if (reset = '1') then
            q <= (others=>'0');
        elsif (clock'event and clock = '1' and load = '1') then
            q <= d;
        end if;
    end process;
end architecture;
