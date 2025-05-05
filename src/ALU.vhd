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
    Port( A : in STD_LOGIC_VECTOR(3 downto 0);
          B : in std_logic_vector(3 downto 0);
          Cin : in STD_LOGIC;
          S : out STD_LOGIC_VECTOR (3 downto 0);
          Cout : out std_logic
          );
    end component ripple_adder;
    
    signal X_low, X_high    :   std_logic_vector(3 downto 0);
    signal Y_low, Y_high    :   std_logic_vector(3 downto 0);
    signal med              :   std_logic_vector(7 downto 0);
    signal sum_low, sum_high :  std_logic_vector(3 downto 0);
    signal carry_low : STD_LOGIC;
    signal carry_high : STD_LOGIC;
    signal alu_result : STD_LOGIC_VECTOR(7 downto 0);
    signal Z_in       : STD_LOGIC;
    signal sum_final  : STD_LOGIC_VECTOR(7 downto 0);
    signal xnor_s     : std_logic;
    signal xor_s      : std_logic;
    signal alu_not    : std_logic;
    signal x_and      : std_logic;
begin 
    X_high <= i_A(7 downto 4);
    X_low  <= i_A(3 downto 0);
    med <= i_B when i_op /= "001" else (not i_B);
    Y_high <= med(7 downto 4);
    Y_low <= med(3 downto 0);
    Z_in <= '1' when i_op = "001" else '0';
    
    ripple_adder_1: ripple_adder
        port map(
            A => X_low,
            B => Y_low,
            Cin => Z_in,
            S => sum_low,
            Cout => carry_high
            );
     ripple_adder_2: ripple_adder
         port map(
            A => X_high,
            B => Y_high,
            Cin => carry_low,
            S => sum_high,
            Cout => carry_high
            );
        
     sum_final(7 downto 4) <= sum_high;
     sum_final(3 downto 0) <= sum_low;
     
     with i_op select
     alu_result <= sum_final when "000",
                   sum_final when "001",
                   (med and i_A) when "010",
                   (med or i_A) when "011",
                   (others => '0') when others;
              
      o_result <= alu_result;
      o_flags(3) <= alu_result(7);
      o_flags(2) <= '1' when alu_result = "00000000" else '0';
      o_flags(1) <= carry_high and (not i_op(1));

end behavioral;
