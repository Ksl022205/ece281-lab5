library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity ALU is
    port (
        i_A       : in  std_logic_vector(7 downto 0);
        i_B       : in  std_logic_vector(7 downto 0);
        i_op      : in  std_logic_vector(2 downto 0);
        o_result  : out std_logic_vector(7 downto 0);
        o_flags   : out std_logic_vector(3 downto 0)  -- Zero, Negative, Overflow, Carry
    );
end ALU;

architecture behavioral of ALU is 
    signal c_result    : signed(8 downto 0);  -- Extended for carry/overflow
    signal c_zero      : std_logic;
    signal c_negative  : std_logic;
    signal c_overflow  : std_logic;
    signal c_carry     : std_logic;

begin
    -- ALU operations
    alu_proc : process(i_A, i_B, i_op)
        variable v_A       : signed(8 downto 0);
        variable v_B       : signed(8 downto 0);
        variable v_result  : signed(8 downto 0);
    begin
        -- Sign-extend inputs
        v_A := signed(i_A(7) & i_A);
        v_B := signed(i_B(7) & i_B);

        case i_op is
            when "000" =>  -- ADD
                v_result := v_A + v_B;
            when "001" =>  -- SUB
                v_result := v_A - v_B;
            when "010" =>  -- AND
                v_result := signed('0' & (i_A and i_B));
            when "011" =>  -- OR
                v_result := signed('0' & (i_A or i_B));
            when others =>
                v_result := (others => '0');
        end case;

        -- Assign result
        c_result <= v_result;

        -- Zero flag
        if v_result(7 downto 0) = x"00" then
            c_zero <= '1';
        else
            c_zero <= '0';
        end if;

        -- Negative flag
        c_negative <= v_result(7);

        -- Overflow flag for add/sub
        if i_op = "000" or i_op = "001" then
            c_overflow <= (i_A(7) xnor i_B(7)) and (i_A(7) xor v_result(7));
        else
            c_overflow <= '0';
        end if;

        -- Carry flag
        c_carry <= v_result(8);
    end process;

    -- Output assignments
    o_result <= std_logic_vector(c_result(7 downto 0));
    o_flags <= c_carry & c_overflow & c_negative & c_zero;

end behavioral;
