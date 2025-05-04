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
    signal s_result    : std_logic_vector(7 downto 0) := (others => '0');
    signal s_carry     : std_logic := '0';
    signal s_overflow  : std_logic := '0';
    signal s_zero      : std_logic := '0';
    signal s_negative  : std_logic := '0';
begin

    process(i_A, i_B, i_op)
        variable A_unsigned, B_unsigned : unsigned(7 downto 0);
        variable A_signed, B_signed     : signed(7 downto 0);
        variable R_unsigned             : unsigned(8 downto 0);  -- for carry
        variable R_signed               : signed(8 downto 0);    -- for overflow (with extra sign bit)
        variable result_var             : std_logic_vector(7 downto 0);
    begin
        A_unsigned := unsigned(i_A);
        B_unsigned := unsigned(i_B);
        A_signed   := signed(i_A);
        B_signed   := signed(i_B);

        s_carry    <= '0';
        s_overflow <= '0';
        s_zero     <= '0';
        s_negative <= '0';
        result_var := (others => '0');

        case i_op is
            when "000" =>  -- ADD
                R_unsigned := ("0" & A_unsigned) + ("0" & B_unsigned);  -- 9-bit result
                R_signed   := resize(A_signed, 9) + resize(B_signed, 9);
                result_var := std_logic_vector(R_unsigned(7 downto 0));
                s_result   <= result_var;

                -- Carry
                s_carry <= R_unsigned(8);

                -- Overflow
                if (A_signed(7) = B_signed(7)) and (R_signed(7) /= A_signed(7)) then
                    s_overflow <= '1';
                end if;

            when "001" =>  -- SUB
                R_unsigned := ("0" & A_unsigned) - ("0" & B_unsigned);
                R_signed   := resize(A_signed, 9) - resize(B_signed, 9);
                result_var := std_logic_vector(R_unsigned(7 downto 0));
                s_result   <= result_var;

                -- Carry (borrow)
                if A_unsigned < B_unsigned then
                    s_carry <= '1';
                end if;

                -- Overflow
                if (A_signed(7) /= B_signed(7)) and (R_signed(7) /= A_signed(7)) then
                    s_overflow <= '1';
                end if;

            when "010" =>  -- AND
                result_var := i_A and i_B;
                s_result   <= result_var;
                s_carry    <= '0';
                s_overflow <= '0';

            when "011" =>  -- OR
                result_var := i_A or i_B;
                s_result   <= result_var;
                s_carry    <= '0';
                s_overflow <= '0';

            when others =>
                result_var := (others => '0');
                s_result   <= result_var;
                s_carry    <= '0';
                s_overflow <= '0';
        end case;

        -- Zero flag
        if result_var = "00000000" then
            s_zero <= '1';
        else
            s_zero <= '0';
        end if;

        -- Negative flag (MSB of the result)
        s_negative <= result_var(7);
    end process;

    o_result <= s_result;
    o_flags  <= s_zero & s_negative & s_carry & s_overflow;  -- ZNCV

end behavioral;
