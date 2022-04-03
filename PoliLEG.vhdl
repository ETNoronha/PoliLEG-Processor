library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_bit.all;
use IEEE.math_real.ceil;
use IEEE.math_real.log2;

-------- REG ---------
entity reg is
    generic(wordSize: natural := 64);
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

-------- BANCO REG ---------

library ieee;
use ieee.std_logic_1164.all;
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
        rr1,rr2,wr: in  bit_vector(4 downto 0);
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

-------- SIGNEXT ---------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_bit.all;
use IEEE.math_real.ceil;
use IEEE.math_real.log2;

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
-------- ALU 64 ---------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_bit.all;
use IEEE.math_real.ceil;
use IEEE.math_real.log2;
--MUX 2 -> 1
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

--MUX 4 ->1 
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

--FULL ADDER
entity fulladder is
    Port ( a, b, cin : in bit;
           s, cout : out bit);
    end fulladder;
    


    architecture gate_level of fulladder is
begin
    
    s <= a XOR b XOR cin ;
    cout <= (a AND b) OR (cin AND a) OR (cin AND b) ;
    
end gate_level;

--ALU 1 bit

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

    MUX4 : mux_4to1 port map(operation, AandB, AorB, AmaisB, b, result);

    set <= AmaisB;
    cout <= somaOut;
    overflow <= '1' when muxA = '1' and muxB = '1' and AmaisB = '0' else
                '1' when muxA = '0' and muxB = '0' and AmaisB = '1' else
                '0';

end behavior;

--ALU 64 bit

entity alu is
    generic (
        size : natural := 64
    );
    port (
        A, B : in  bit_vector (size-1 downto 0);
        F    : out bit_vector (size-1 downto 0);
        S    : in  bit_vector (3 downto 0);
        Z    : out bit;
        Ov   : out bit;
        Co   : out bit
    );

end entity alu;

architecture behavior of alu is
    signal results, couts, sets, overflows, lesses, Zero: bit_vector(size-1 downto 0);
    signal isSub : bit;

    component alu1bit is
        port (
        a, b, less, cin: in bit;
        result, cout, set, overflow: out bit;
        ainvert, binvert: in bit;
        operation: in bit_vector(1 downto 0)
    );
    end component;

begin
    isSub <= S(3) or S(2);
    lesses(0) <= sets(size-1);

    ulas: for i in size-1 downto 0 generate

        ula_final: if i = size-1 generate
           
            ulafinal : alu1bit port map (
                A(i), 
                B(i), 
                lesses(i), 
                couts(i-1), 
                results(i), 
                couts(i), 
                sets(i), 
                overflows(i), 
                S(3), 
                S(2), 
                S(1 downto 0)
            );
        end generate;

        ula_meio: if (i > 0 and i < size -1) generate
               
            ulameio: alu1bit port map (
                A(i),
                B(i), 
                lesses(i), 
                couts(i-1), 
                results(i), 
                couts(i), 
                sets(i), 
                overflows(i), 
                S(3), 
                S(2), 
                S(1 downto 0)
            );
        end generate;

        ula_primeira: if i = 0 generate
            ulaprimeira : alu1bit port map (
                A(i), 
                B(i), 
                lesses(i), 
                isSub, 
                results(i), 
                couts(i), 
                sets(i), 
                overflows(i), 
                S(3), 
                S(2), 
                S(1 downto 0)
            );
        end generate;

    end generate;

    Zero(0) <= results(0);
    zeross: for i in 1 to size-1 generate
        Zero(i) <= Zero(i-1) or results(i);
    end generate;

    F <= results;
    Z <= not Zero(size-1);
    Ov <= overflows(size-1);
    Co <= couts(size-1);
end behavior;

-------- <<2 ---------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_bit.all;
use IEEE.math_real.ceil;
use IEEE.math_real.log2;

entity shiftleft2 is
    port(
        i: in bit_vector(63 downto 0);
        o: out bit_vector(63 downto 0)
    );
end shiftleft2;

architecture shift2_arch of shiftleft2 is
begin
    o(63 downto 2) <= i(61 downto 0);
    o(1 downto 0) <= (others => '0');
end architecture;

-------- CTRL UNIT ---------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_bit.all;
use IEEE.math_real.ceil;
use IEEE.math_real.log2;

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

-------- ALUCTRL ----------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_bit.all;
use IEEE.math_real.ceil;
use IEEE.math_real.log2;

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

-------- DATAPATH ---------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_bit.all;
use IEEE.math_real.ceil;
use IEEE.math_real.log2;

entity datapath is
    port(
        clock: in bit;
        reset: in bit;

        reg2loc: in bit;
        pcsrc: in bit;
        memToReg: in bit;
        aluCtrl: in bit_vector(3 downto 0);
        aluSrc: in bit;
        regWrite: in bit;

        opcode: out bit_vector(10 downto 0);
        zero: out bit;
        imAddr: out bit_vector(63 downto 0);
        imOut: in bit_vector(31 downto 0);

        dmAddr: out bit_vector(63 downto 0);
        dmIn: out bit_vector(63 downto 0);
        dmOut: in bit_vector(63 downto 0)
    );
    end entity datapath;

architecture URGHdatapath of datapath is

    component regfile is 
        generic(
            regn: natural := 32;
            wordSize: natural := 64
        );
        port(
            clock:      in  bit;
            reset:      in  bit;
            regWrite:   in  bit;
            rr1,rr2,wr: in  bit_vector(4 downto 0);
            d:          in  bit_vector(wordSize-1 downto 0);
            q1, q2:     out bit_vector(wordSize-1 downto 0)
    );
    end component;

    component signExtend is 
        port (
            i : in  bit_vector(31 downto 0);
            o : out bit_vector(63 downto 0)
    );
    end component;

    component alu is
        generic (
        size : natural := 64
        );
        port (
            A, B : in  bit_vector (size-1 downto 0);
            F    : out bit_vector (size-1 downto 0);
            S    : in  bit_vector (3 downto 0);
            Z    : out bit;
            Ov   : out bit;
            Co   : out bit
        );
    end component;

    component shiftleft2 is
        port(
            i: in bit_vector(63 downto 0);
            o: out bit_vector(63 downto 0)
    );
    end component;

    component reg is
        generic(wordSize: natural := 64);
        port(
            clock: in  bit;
            reset: in  bit;
            load:  in  bit;
            d:     in  bit_vector(wordSize-1 downto 0);
            q:     out bit_vector(wordSize-1 downto 0)
    );
    end component;

    signal rr2 : bit_vector(4 downto 0);
    signal d_reg, alu_result, reg1, reg2, alu_in2, sign_extended, left_shifted: bit_vector(63 downto 0);
    signal PCin, PCout,aluPC_result, aluPC_branch_result : bit_vector(63 downto 0);
    signal four64 : bit_vector(63 downto 0);

begin
    four64(2 downto 0) <= "100";
    opcode <= imOut(31 downto 21);
    rr2 <= imOut(20 downto 16) when reg2loc = '0' else
           imOut(4 downto 0);

    d_reg <= dmOut when memToReg = '1' else
             alu_result;
    
    alu_in2 <= reg2 when aluSrc = '0' else
               sign_extended;

    dmAddr <= alu_result;

    banco_registradorres : regfile 
    generic map(32, 64)
    port map (
        clock,
        reset,
        regWrite,
        imOut(9 downto 5), rr2, imOut(4 downto 0),
        d_reg,
        reg1, reg2
    );

    alu1 : alu 
    generic map(64)
    port map (
        reg1, alu_in2,
        alu_result,
        aluCtrl,
        zero
        --Ov,
        --Co
    );

    sign_extend : signExtend port map (
        imOut,
        sign_extended
    );

    shift_l : shiftleft2 port map(
        sign_extended,
        left_shifted
    );

    alu_branch : alu 
    generic map(64)
    port map (
        PCout, left_shifted,
        aluPC_branch_result,
        "0010"
    );


    alu_notBranch : alu 
    generic map(64)
    port map (
        PCout, four64,
        aluPC_result,
        "0010"
    );

    PC : reg port map(
        clock,
        reset,
        '1',
        PCin,
        PCout
    );

    PCin <= aluPC_result when pcsrc = '0' else
            aluPC_branch_result;

    imAddr <= PCout;
    dmIn <= reg2;


end URGHdatapath;

-------- POLIPERNA---------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_bit.all;
use IEEE.math_real.ceil;
use IEEE.math_real.log2;

entity polilegsc is
    port(
        clock, reset: in bit;
        -- Data Memory
        dmem_addr: out bit_vector(63 downto 0);
        dmem_dati: out bit_vector(63 downto 0);
        dmem_dato: in bit_vector(63 downto 0);
        dmem_we: out bit;
        -- Instruction Memory
        imem_addr: out bit_vector(63 downto 0);
        imem_data: in bit_vector(31 downto 0)
    );
end entity polilegsc;


architecture poliperna of polilegsc is

    --control unit saidas
    signal reg2loc, uncondBranch, branch, memRead, memToReg, memWrite, aluSrc, regWrite : bit;
    signal aluop : bit_vector(1 downto 0);

    --alu control saidas
    signal aluCtrl : bit_vector(3 downto 0);

    --entrada Datapath
    signal pcsrc : bit;

    --saidas Datapath
    signal opcode : bit_vector(10 downto 0);
    signal zero : bit;
    signal imAddr, dmAddr, dmIn : bit_vector(63 downto 0);

    component alucontrol is
        port (
        aluop : in bit_vector(1 downto 0);
        opcode: in bit_vector(10 downto 0);
        aluCtrl: out bit_vector(3 downto 0)
    );
    end component;

    component controlunit is
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
    );
    end component;

    component datapath is 
        port(
            clock: in bit;
            reset: in bit;

            reg2loc: in bit;
            pcsrc: in bit;
            memToReg: in bit;
            aluCtrl: in bit_vector(3 downto 0);
            aluSrc: in bit;
            regWrite: in bit;

            opcode: out bit_vector(10 downto 0);
            zero: out bit;

            imAddr: out bit_vector(63 downto 0);
            imOut: in bit_vector(31 downto 0);

            dmAddr: out bit_vector(63 downto 0);
            dmIn: out bit_vector(63 downto 0);
            dmOut: in bit_vector(63 downto 0)
        );
    end component;

begin
    pcsrc <= uncondBranch or (zero and branch);

    control_unit : controlunit port map (
        reg2loc,
        uncondBranch,
        branch,
        memRead,
        memToReg,
        aluOp,
        memWrite,
        aluSrc,
        regWrite,
        opcode
    );

    alu_control : alucontrol port map (
        aluOp,
        opcode,
        aluCtrl
    );

    data_path : datapath port map (
        clock, 
        reset,

        reg2loc,
        pcsrc,
        memToReg,
        aluCtrl,
        aluSrc,
        regWrite,

        opcode,
        zero,

        imAddr,
        imem_data,

        dmAddr,
        dmIn,
        dmem_dato
    );

dmem_addr <= dmAddr;
dmem_dati <= dmIn;
dmem_we <= memWrite;

imem_addr <= imAddr;

end architecture;