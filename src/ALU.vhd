library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    port (
        i_A       : in  std_logic_vector(7 downto 0);
        i_B       : in  std_logic_vector(7 downto 0);
        i_op      : in  std_logic_vector(2 downto 0);
        o_result  : out std_logic_vector(7 downto 0);
        o_flags   : out std_logic_vector(3 downto 0)  -- ZNCV: Zero, Negative, Carry, Overflow
    );
end ALU;

architecture behavioral of ALU is
    component ripple_adder is 
        port (
            A    : in  std_logic_vector(3 downto 0);
            B    : in  std_logic_vector(3 downto 0);
            Cin  : in  std_logic;
            S    : out std_logic_vector(3 downto 0);
            Cout : out std_logic
        );
    end component ripple_adder;
    
    signal A_low, A_high    : std_logic_vector(3 downto 0);
    signal B_low, B_high    : std_logic_vector(3 downto 0);
    signal B_mod            : std_logic_vector(7 downto 0);
    signal sum_low, sum_high: std_logic_vector(3 downto 0);
    signal carry_low        : std_logic;
    signal carry_high       : std_logic;
    signal alu_result       : std_logic_vector(7 downto 0);
    signal Cin              : std_logic;
    signal sum_final        : std_logic_vector(7 downto 0);
    signal xnor_s           : std_logic;
    signal xor_s            : std_logic;
    signal alu_not          : std_logic;
    signal x_and            : std_logic;
begin 
    A_high <= i_A(7 downto 4);
    A_low  <= i_A(3 downto 0);
    B_mod  <= i_B when i_op /= "001" else (not i_B);
    B_high <= B_mod(7 downto 4);
    B_low  <= B_mod(3 downto 0);
    Cin    <= '1' when i_op = "001" else '0';
    
    ripple_adder_1: ripple_adder
        port map (
            A    => A_low,
            B    => B_low,
            Cin  => Cin,
            S    => sum_low,
            Cout => carry_low
        );
    
    ripple_adder_2: ripple_adder
        port map (
            A    => A_high,
            B    => B_high,
            Cin  => carry_low,
            S    => sum_high,
            Cout => carry_high
        );
        
    sum_final(7 downto 4) <= sum_high;
    sum_final(3 downto 0) <= sum_low;
     
    with i_op select
        alu_result <= sum_final when "000",           -- Addition
                      sum_final when "001",           -- Subtraction
                      (B_mod and i_A) when "010",     -- AND
                      (B_mod or i_A) when "011",      -- OR
                      (others => '0') when others;    -- Default
              
    o_result <= alu_result;
    o_flags(3) <= alu_result(7);                                    -- Negative flag
    o_flags(2) <= '1' when alu_result = "00000000" else '0';        -- Zero flag
    o_flags(1) <= carry_high and (not i_op(1));                     -- Carry flag
    alu_not <= not i_op(1);
    xnor_s  <= not (i_A(7) xor i_B(7) xor i_op(0));
    xor_s   <= i_A(7) xor alu_result(7);
    x_and   <= xnor_s and xor_s;
    o_flags(0) <= x_and and alu_not;                                -- Overflow flag
end behavioral;
