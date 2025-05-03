library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    port (
        i_A      : in  std_logic_vector(7 downto 0);
        i_B      : in  std_logic_vector(7 downto 0);
        i_op     : in  std_logic_vector(2 downto 0);
        o_result : out std_logic_vector(7 downto 0);
        o_flags  : out std_logic_vector(3 downto 0)  -- NZCV: Negative, Zero, Carry, Overflow
    );
end ALU;

architecture behavioral of ALU is
    signal v_A        : signed(8 downto 0);
    signal v_B        : signed(8 downto 0);
    signal v_result   : signed(8 downto 0);

    signal is_add     : std_logic;
    signal is_sub     : std_logic;
    signal ovf_add    : std_logic;
    signal ovf_sub    : std_logic;

    signal c_zero     : std_logic;
    signal c_negative : std_logic;
    signal c_carry    : std_logic;
    signal c_overflow : std_logic;
begin

process(i_A, i_B, i_op)
    variable a, b : signed(8 downto 0);
    variable r    : signed(8 downto 0) := (others => '0');
begin
    a := signed(i_A(7) & i_A);
    b := signed(i_B(7) & i_B);

    case i_op is
        when "000" =>  -- ADD
            r := a + b;
        when "001" =>  -- SUB
            r := a - b;
        when "010" =>  -- AND
            r := signed('0' & (i_A and i_B));
        when "011" =>  -- OR
            r := signed('0' & (i_A or i_B));
        when others =>
            r := (others => '0');
    end case;

    v_result <= r;
end process;

    -- Overflow detection using Boolean logic
    is_add  <= '1' when i_op = "000" else '0';
    is_sub  <= '1' when i_op = "001" else '0';

    ovf_add <= '1' when (i_A(7) = i_B(7)) and (v_result(7) /= i_A(7)) else '0';
    ovf_sub <= '1' when (i_A(7) /= i_B(7)) and (v_result(7) /= i_A(7)) else '0';

    c_overflow <= (is_add and ovf_add) or (is_sub and ovf_sub);
    c_carry    <= v_result(8);
    c_negative <= v_result(7);
    c_zero     <= '1' when v_result(7 downto 0) = x"00" else '0';

    o_result <= std_logic_vector(v_result(7 downto 0));
    o_flags  <= c_negative & c_zero & c_carry & c_overflow;  -- NZCV order

end behavioral;
