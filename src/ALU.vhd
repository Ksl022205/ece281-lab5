library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity ALU is
    port (
        i_op1     : in  std_logic_vector(7 downto 0);
        i_op2     : in  std_logic_vector(7 downto 0);
        i_opcode  : in  std_logic_vector(2 downto 0);
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
    alu_proc : process(i_op1, i_op2, i_opcode)
        variable v_op1     : signed(8 downto 0);
        variable v_op2     : signed(8 downto 0);
        variable v_result  : signed(8 downto 0);
    begin
        -- Sign-extend inputs
        v_op1 := signed(i_op1(7) & i_op1);
        v_op2 := signed(i_op2(7) & i_op2);

        case i_opcode is
            when "000" =>  -- ADD
                v_result := v_op1 + v_op2;
            when "001" =>  -- SUB
                v_result := v_op1 - v_op2;
            when "010" =>  -- AND
                v_result := signed('0' & (i_op1 and i_op2));
            when "011" =>  -- OR
                v_result := signed('0' & (i_op1 or i_op2));
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
        if i_opcode = "000" or i_opcode = "001" then
            c_overflow <= (i_op1(7) xnor i_op2(7)) and (i_op1(7) xor v_result(7));
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
