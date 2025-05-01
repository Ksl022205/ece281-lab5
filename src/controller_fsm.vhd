library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controller_fsm is
    port (
        i_reset   : in  std_logic;
        i_adv     : in  std_logic;
        o_cycle   : out std_logic_vector(3 downto 0)
    );
end controller_fsm;

architecture FSM of controller_fsm is
    type sm_cycle is (S_CLEAR, S_OP1, S_OP2, S_RESULT);
    signal f_state, f_next_state : sm_cycle;

begin
    -- State register
    state_reg : process(i_reset, i_adv)
    begin
        if i_reset = '1' then
            f_state <= S_CLEAR;
        elsif rising_edge(i_adv) then
            f_state <= f_next_state;
        end if;
    end process;

    -- Next state logic
    next_state : process(f_state)
    begin
        case f_state is
            when S_CLEAR =>
                f_next_state <= S_OP1;
            when S_OP1 =>
                f_next_state <= S_OP2;
            when S_OP2 =>
                f_next_state <= S_RESULT;
            when S_RESULT =>
                f_next_state <= S_CLEAR;
        end case;
    end process;

    -- Output logic (one-hot)
    output_logic : process(f_state)
    begin
        case f_state is
            when S_CLEAR  => o_cycle <= "0001";
            when S_OP1    => o_cycle <= "0010";
            when S_OP2    => o_cycle <= "0100";
            when S_RESULT => o_cycle <= "1000";
        end case;
    end process;

end FSM;
