library IEEE;
use IEEE.numeric_bit.all;
use IEEE.math_real.ceil;
use IEEE.math_real.log2;

entity regfile is
    generic(
        regn: natural := 32;
        wordSize: natural := 64
    );
    port(
        clock:      in  bit;
        reset:      in  bit;
        regWrite:   in  bit;
        rr1,rr2,wr: in  bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
        d:          in  bit_vector(wordSize-1 downto 0);
        q1, q2:     out bit_vector(wordSize-1 downto 0)
    );
end regfile;

architecture arch_regfile of regfile is
    signal int_w: integer;

    type reg_tipo is array(0 to regn-1) of bit_vector(wordSize-1 downto 0);
    signal rBanco: reg_tipo;

begin
  
    ffdr: process(clock, reset)
    begin
        int_w <= to_integer(unsigned(wr));
        if reset = '1' then
            rBanco <= (others => (others => '0'));
          
        elsif clock ='1' and clock'event then
            if regWrite = '1' then
                if int_w = regn-1 then
                    rBanco(to_integer(unsigned(wr))) <= (others => '0');
                else
                rBanco(to_integer(unsigned(wr))) <= d;
                end if;        
            end if;
        end if;
    end process;

    --leitura
            q1 <= rBanco(to_integer(unsigned(rr1)));
            q2 <= rBanco(to_integer(unsigned(rr2)));
        

end arch_regfile;