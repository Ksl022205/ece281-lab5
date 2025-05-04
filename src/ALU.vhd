library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    port (
        i_A      : in  std_logic_vector(7 downto 0);
        i_B      : in  std_logic_vector(7 downto 0);
        i_op     : in  std_logic_vector(2 downto 0);
        o_result : out std_logic_vector(7 downto 0);
        o_flags  : out std_logic_vector(3 downto 0)  -- ZNCV
    );
end ALU;

architecture behavioral of ALU is
    signal s_result    : std_logic_vector(7 downto 0);
    signal s_zero      : std_logic;
    signal s_negative  : std_logic;
    signal s_carry     : std_logic;
    signal s_overflow  : std_logic;
begin
    process(i_A, i_B, i_op)
        variable a_unsigned, b_unsigned : unsigned(7 downto 0);
        variable a_signed, b_signed     : signed(7 downto 0);
        variable r_unsigned             : unsigned(8 downto 0);  -- 9 bits for carry
        variable r_signed               : signed(8 downto 0);    -- 9 bits for overflow detection
        variable result_var             : std_logic_vector(7 downto 0);
    begin
        a_unsigned := unsigned(i_A);
        b_unsigned := unsigned(i_B);
        a_signed := signed(i_A);
        b_signed := signed(i_B);

        s_carry    <= '0';
        s_overflow <= '0';
        s_zero     <= '0';
        s_negative <= '0';

        case i_op is
            when "000" =>  -- ADD
                r_unsigned := ("0" & a_unsigned) + ("0" & b_unsigned);
                r_signed := signed(resize(a_signed, 9)) + signed(resize(b_signed, 9));
                result_var := std_logic_vector(r_unsigned(7 downto 0));
                s_result <= result_var;

                -- Carry
                s_carry <= r_unsigned(8);

                -- Overflow: check if MSB changed improperly
                if (a_signed(7) = b_signed(7)) and (r_signed(7) /= a_signed(7)) then
                    s_overflow <= '1';
                end if;

            when "001" =>  -- SUB
                r_unsigned := ("0" & a_unsigned) - ("0" & b_unsigned);
                r_signed := signed(resize(a_signed, 9)) - signed(resize(b_signed, 9));
                result_var := std_logic_vector(r_unsigned(7 downto 0));
                s_result <= result_var;

                -- Carry (borrow): set if unsigned A < B
                if a_unsigned < b_unsigned then
                    s_carry <= '1';
                end if;

                -- Overflow
                if (a_signed(7) /= b_signed(7)) and (r_signed(7) /= a_signed(7)) then
                    s_overflow <= '1';
                end if;

            when "010" =>  -- AND
                result_var := i_A and i_B;
                s_result <= result_var;
                s_carry <= '0';
                s_overflow <= '0';

            when "011" =>  -- OR
                result_var := i_A or i_B;
                s_result <= result_var;
                s_carry <= '0';
                s_overflow <= '0';

            when others =>
                result_var := (others => '0');
                s_result <= result_var;
                s_carry <= '0';
                s_overflow <= '0';
        end case;

        -- Zero flag
        if result_var = "00000000" then
            s_zero <= '1';
        else
            s_zero <= '0';
        end if;

        -- Negative flag
        s_negative <= result_var(7);
    end process;

    o_result <= s_result;
    o_flags  <= s_zero & s_negative & s_carry & s_overflow;  -- ZNCV
end behavioral;
