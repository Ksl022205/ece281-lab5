library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity top_basys3 is
    port (
        xi_sw       : in  std_logic_vector(15 downto 0);  -- switches
        xi_btnU     : in  std_logic;                      -- master reset
        xi_btnL     : in  std_logic;                      -- clock divider reset
        xi_btnC     : in  std_logic;                      -- cycle advance
        xi_clk      : in  std_logic;                      -- master clock
        xo_seg      : out std_logic_vector(6 downto 0);    -- seven-segment cathodes
        xo_an       : out std_logic_vector(3 downto 0);    -- seven-segment anodes
        xo_dp       : out std_logic;                      -- decimal point
        xo_led      : out std_logic_vector(15 downto 0)    -- LEDs
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
    -- Component declarations
    component ALU is
        port (
            i_op1     : in  std_logic_vector(7 downto 0);
            i_op2     : in  std_logic_vector(7 downto 0);
            i_opcode  : in  std_logic_vector(2 downto 0);
            o_result  : out std_logic_vector(7 downto 0);
            o_flags   : out std_logic_vector(3 downto 0)
        );
    end component;

    component controller_fsm is
        port (
            i_reset   : in  std_logic;
            i_adv     : in  std_logic;
            o_cycle   : out std_logic_vector(3 downto 0)
        );
    end component;

    component clk_div is
        port (
            i_clk     : in  std_logic;
            i_rst     : in  std_logic;
            o_clk     : out std_logic
        );
    end component;

    component seven_segment is
        port (
            i_reset   : in  std_logic;
            i_clk     : in  std_logic;
            i_data    : in  std_logic_vector(7 downto 0);
            o_seg     : out std_logic_vector(6 downto 0);
            o_an      : out std_logic_vector(3 downto 0);
            o_dp      : out std_logic
        );
    end component;

    -- Signal declarations
    signal w_cycle       : std_logic_vector(3 downto 0);
    signal w_alu_result  : std_logic_vector(7 downto 0);
    signal w_alu_flags   : std_logic_vector(3 downto 0);
    signal w_op1         : std_logic_vector(7 downto 0);
    signal w_op2         : std_logic_vector(7 downto 0);
    signal w_opcode      : std_logic_vector(2 downto 0);
    signal w_display     : std_logic_vector(7 downto 0);
    signal w_slow_clk    : std_logic;
    signal w_btnC_db     : std_logic;

    -- Debouncer signals (simple debouncer)
    signal f_btnC_sync   : std_logic_vector(1 downto 0);
    signal c_btnC_edge   : std_logic;

begin
    -- PORT MAPS
    alu_inst : ALU
        port map (
            i_op1     => w_op1,
            i_op2     => w_op2,
            i_opcode  => w_opcode,
            o_result  => w_alu_result,
            o_flags   => w_alu_flags
        );

    fsm_inst : controller_fsm
        port map (
            i_reset   => xi_btnU,
            i_adv     => w_btnC_db,
            o_cycle   => w_cycle
        );

    clk_div_inst : clk_div
        port map (
            i_clk     => xi_clk,
            i_rst     => xi_btnL,
            o_clk     => w_slow_clk
        );

    seven_seg_inst : seven_segment
        port map (
            i_reset   => xi_btnU,
            i_clk     => w_slow_clk,
            i_data    => w_display,
            o_seg     => xo_seg,
            o_an      => xo_an,
            o_dp      => xo_dp
        );

    -- Debouncer process for btnC
    debounce_proc : process(xi_clk)
    begin
        if rising_edge(xi_clk) then
            f_btnC_sync <= f_btnC_sync(0) & xi_btnC;
            if f_btnC_sync = "01" then
                w_btnC_db <= '1';
            else
                w_btnC_db <= '0';
            end if;
        end if;
    end process;

    -- Register process for operands and opcode
    reg_proc : process(xi_clk, xi_btnU)
    begin
        if xi_btnU = '1' then
            w_op1    <= (others => '0');
            w_op2    <= (others => '0');
            w_opcode <= (others => '0');
        elsif rising_edge(xi_clk) then
            if w_cycle = "0001" then
                w_op1 <= xi_sw(7 downto 0);
            elsif w_cycle = "0010" then
                w_op2 <= xi_sw(7 downto 0);
                w_opcode <= xi_sw(2 downto 0);
            end if;
        end if;
    end process;

    -- Display mux
    display_mux : process(w_cycle, w_op1, w_op2, w_alu_result)
    begin
        case w_cycle is
            when "0001" => w_display <= w_op1;
            when "0010" => w_display <= w_op2;
            when "0100" => w_display <= w_alu_result;
            when others => w_display <= (others => '0');
        end case;
    end process;

    -- LED assignments
    xo_led(3 downto 0)  <= w_cycle;
    xo_led(15 downto 12) <= w_alu_flags;
    xo_led(11 downto 4) <= (others => '0');

end top_basys3_arch;
