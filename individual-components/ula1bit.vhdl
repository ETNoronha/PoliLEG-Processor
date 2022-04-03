library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;
use std.textio.all;

-------- MUX 2 -> 1 --------
entity mux_2to1 is
    Port ( SEL : in  bit;
           A   : in  bit;
           B   : in  bit;
           X   : out bit);
end mux_2to1;

architecture Behavioral of mux_2to1 is
begin
    X <= A when (SEL = '0') else B;
end Behavioral;

-------- MUX 4 ->1 --------
entity mux_4to1 is
    Port ( SEL : in  bit_vector(1 downto 0);
           A   : in  bit;
           B   : in  bit;
           C   : in  bit;
           D   : in  bit;
           X   : out bit);
end mux_4to1;

architecture Behavioral of mux_4to1 is
begin
    with SEL select X <=
        A when "00",
        B when "01",
        C when "10",
        D when "11";
end Behavioral;

-------- FULL ADDER ---------
entity fulladder is
    Port ( a, b, cin : in bit;
           s, cout : out bit);
    end fulladder;
    
    architecture gate_level of fulladder is
    begin
    
    s <= a XOR b XOR cin ;
    cout <= (a AND b) OR (cin AND a) OR (cin AND b) ;
    
    end gate_level;

-------- ALU 1 bit --------

entity alu1bit is 
    port (
        a, b, less, cin: in bit;
        result, cout, set, overflow: out bit;
        ainvert, binvert: in bit;
        operation: in bit_vector(1 downto 0)
    );
end entity alu1bit;

architecture behavior of alu1bit is
    signal muxA, muxB: bit;
    signal AmaisB, AmenosB, somaOut: bit;
    signal notA, notB: bit;
    signal AandB, AorB: bit;

    component mux_2to1 is
        port ( SEL, A, B : in  bit;
               X : out bit);
    end component;

    component mux_4to1 is
        port (SEL : in  bit_vector(1 downto 0);
              A, B, C, D : in bit;
              X : out bit);
    end component;

    component fulladder is
        Port ( a, b, cin : in bit;
               s, cout : out bit);
    end component;

begin
    notA <= not a;
    notB <= not b;

    Ainv : mux_2to1 port map(ainvert, a, notA, muxA);
    Binv : mux_2to1 port map(binvert, b, notB, muxB);

    AandB <= muxA and muxB;
    AorB <= muxA or muxB;

    maisAB : fulladder port map(muxA, muxB, cin, AmaisB, somaOut);

    MUX4 : mux_4to1 port map(operation, AandB, AorB, AmaisB, less, result);

    set <= AmaisB;
    cout <= somaOut;
    overflow <= '1' when muxA = '1' and muxB = '1' and AmaisB = '0' else
                '1' when muxA = '0' and muxB = '0' and AmaisB = '1' else
                '0';

end behavior;