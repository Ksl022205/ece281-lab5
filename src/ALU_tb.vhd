library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
 
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
 
entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));  -- N Z C V
end ALU;
 
architecture Behavioral of ALU is
begin
    process (i_A, i_B, i_op)
        variable result : std_logic_vector(7 downto 0);
        variable flags  : std_logic_vector(3 downto 0);  -- N Z C V
        variable carry  : std_logic;
    begin
        -- Default outputs
        result := (others => '0');
        flags  := (others => '0');
        carry  := '0';
 
        case i_op is
            when "000" =>  -- ADD: A + B
                -- Simple addition with carry
                result := std_logic_vector(unsigned(i_A) + unsigned(i_B));
                carry := '0';
                if unsigned(i_A) + unsigned(i_B) > 255 then
                    carry := '1';  -- Carry if result > 255
                end if;
                -- Overflow: same sign inputs, different sign result
                if (i_A(7) = i_B(7) and result(7) /= i_A(7)) then
                    flags(0) := '1';  -- V
                end if;
 
            when "001" =>  -- SUB: A - B
                -- Simple subtraction
                result := std_logic_vector(unsigned(i_A) - unsigned(i_B));
                carry := '1';
                if unsigned(i_A) < unsigned(i_B) then
                    carry := '0';  -- No carry if borrow needed
                end if;
                -- Overflow: opposite sign inputs, result sign differs from A
                if (i_A(7) /= i_B(7) and result(7) /= i_A(7)) then
                    flags(0) := '1';  -- V
                end if;
 
            when "010" =>  -- AND: A & B
                result := i_A and i_B;
 
            when "011" =>  -- OR: A | B
                result := i_A or i_B;
 
            when others =>  -- Invalid op-codes
                result := (others => '0');
                flags := (others => '0');
        end case;
 
        -- Set flags
        flags(3) := result(7);  -- N: Negative (MSB)
        if result = "00000000" then
            flags(2) := '1';  -- Z: Zero
        end if;
        flags(1) := carry;  -- C: Carry/Borrow
 
        -- Assign outputs
        o_result <= result;
        o_flags <= flags;
    end process;
end Behavioral;
