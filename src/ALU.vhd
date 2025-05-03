library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    port (
        i_A       : in  std_logic_vector(7 downto 0);
        i_B       : in  std_logic_vector(7 downto 0);
        i_op      : in  std_logic_vector(2 downto 0);
        o_result  : out std_logic_vector(7 downto 0);
        o_flags   : out std_logic_vector(3 downto 0)  -- NZCV: Negative, Zero, Carry, Overflow
    );
end ALU;

architecture behavioral of ALU is
    signal s_result    : std_logic_vector(7 downto 0);
    signal s_carry     : std_logic := '0';
    signal s_overflow  : std_logic := '0';
    signal s_zero      : std_logic := '0';
    signal s_negative  : std_logic := '0';
begin

    process(i_A, i_B, i_op)
        variable A_unsigned, B_unsigned : unsigned(7 downto 0);
        variable A_signed, B_signed     : signed(7 downto 0);
        variable R_unsigned             : unsigned(8 downto 0);  -- for carry
        variable R_signed               : signed(7 downto 0);    -- for overflow
    begin
        A_unsigned := unsigned(i_A);
        B_unsigned := unsigned(i_B);
        A_signed   := signed(i_A);
        B_signed   := signed(i_B);

        s_carry    <= '0';
        s_overflow <= '0';
        s_zero     <= '0';
        s_negative <= '0';

        case i_op is
            when "000" =>  -- ADD
                R_unsigned := ("0" & AUnsigned) + ("0" & B_unsigned);  -- 9-bit addition for carry
                s_result   <= std_logic_vector(R_unsigned(7 downto 0));
                R_signed   := signed(R_unsigned(7 downto 0));            -- Store result as signed

                -- Carry flag
                s_carry <= R_unsigned(8);

                -- Overflow flag (signed)
                s_overflow <= '1' when (A_signed(7) = B_signed(7) and R_signed(7) /= A_signed(7)) else '0';

            when "001" =>  -- SUB
                R_unsigned := ("0" & A_unsigned) - ("0" & B_unsigned);
                R_signed   := signed(R_unsigned(7 downto 0));
                s_result   <= std_logic_vector(R_signed);

                -- Carry flag (borrow in subtraction)
                if A_unsigned < B_unsigned then
                    s_carry <= '1';
                end if;

                -- Overflow flag (signed)
                if (A_signed(7) /= B_signed(7)) and (R_signed(7) /= A_signed(7)) then
                    s_overflow <= '1';
                end if;

            when "010" =>  -- AND
                s_result   <= i_A and i_B;
                s_carry    <= '0';
                s_overflow <= '0';

            when "011" =>  -- OR
                s_result   <= i_A or i_B;
                s_carry    <= '0';
                s_overflow <= '0';

            when others =>
                s_result   <= (others => '0');
                s_carry    <= '0';
                s_overflow <= '0';
        end case;

        -- Zero flag
        if s_result = x"00" then
            s_zero <= '1';
        else
            s_zero <= '0';
        end if;

        -- Negative flag (MSB of the result)
        s_negative <= s_result(7);
    end process;

    -- Output result and flags
    o_result <= s_result;
    o_flags <= s_negative & s_zero & s_carry & s_overflow;  -- NZCV order

end behavioral;
