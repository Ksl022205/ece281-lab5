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
    signal s_result    : std_logic_vector(7 downto 0);
    signal s_carry     : std_logic := '0';
    signal s_overflow  : std_logic := '0';
    signal s_zero      : std_logic := '0';
    signal s_negative  : std_logic := '0';
begin

    process(i_A, i_B, i_op)
        variable A_unsigned, B_unsigned : unsigned(7 downto 0);
        variable A_signed, B_signed     : signed(7 downto 0);
        variable R_unsigned             : unsigned(8 downto 0);  -- 9-bit for carry
        variable R_signed               : signed(7 downto 0);    -- 8-bit signed result
        variable result_var             : std_logic_vector(7 downto 0);  -- temporary result
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
                R_unsigned := ("0" & A_unsigned) + ("0" & B_unsigned);
                result_var := std_logic_vector(R_unsigned(7 downto 0));
                R_signed := signed(result_var);
                s_result <= result_var;

                -- Carry
                if R_unsigned(8) = '1' then
                    s_carry <= '1';
                end if;

                -- Overflow
                if (i_A(7) = i_B(7)) and (result_var(7) /= i_A(7)) then
                    s_overflow <= '1';
                end if;

            -- (SUB, AND, OR cases remain unchanged for now)
            -- ...
        end case;

        -- Zero flag
        if result_var = x"00" then
            s_zero <= '1';
        else
            s_zero <= '0';
        end if;

        -- Negative flag
        s_negative <= result_var(7);
    end process;

    o_result <= s_result;
    o_flags  <= s_zero & s_negative & s_carry & s_overflow;
end behavioral;

