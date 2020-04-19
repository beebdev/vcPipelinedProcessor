-----------------------------------------------------------------------
--  COMP3211 Computer Architecture 20T1                              --
--  Final Project: Real-time Vote Counting System                    --
--  Student: Po Jui Shih (z5187581)                                  --
-----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity data_memory is
    Port ( reset        : in  STD_LOGIC;
           clk          : in  STD_LOGIC;
           read         : in  STD_LOGIC;
           write        : in  STD_LOGIC;
           address      : in  STD_LOGIC_VECTOR(15 downto 0);
           data_in      : in  STD_LOGIC_VECTOR(15 downto 0);
           penalty      : in  STD_LOGIC_VECTOR(3 downto 0);
           data_out     : out STD_LOGIC_VECTOR(255 downto 0);
           mem_done     : out STD_LOGIC );
end data_memory;

architecture Behavioral of data_memory is
    -- mem_line consists of 16 16-bit cells
    type mem_line is array(0 to 15) of STD_LOGIC_VECTOR(15 downto 0);
    -- mem_block consists of 8 mem_line
    type mem_block is array(0 to 7) of mem_line;
    
    -- stalling states
    type state_t is (st_start, st_stall, st_done);
    signal state, next_state : state_t;
    signal sig_stall_count : integer;
    
    -- Probe signal for simulation purposes
    signal sig_mem_block : mem_block;
begin
    ----------stage register-------------------------------------
    state_reg : process (reset, clk)
    begin
        if (reset = '1') then
            state <= st_start;
        elsif (falling_edge(clk)) then
            state <= next_state;
        end if;
    end process;
    -------------------------------------------------------------
    
    ----------next state logic-----------------------------------
    next_s_logic : process (state, read, write, sig_stall_count)
    begin
        case state is
            when st_start =>
                if (read = '1' or write = '1') then
                    next_state <= st_stall;
                else
                    next_state <= st_start;
                end if;
            when st_stall =>
                if (sig_stall_count /= 0) then
                    next_state <= st_done;
                else
                    next_state <= st_stall;
                end if;
            when st_done =>
                next_state <= state;
        end case;
    end process;
    -------------------------------------------------------------
    
    ------------state output-------------------------------------
    state_output : process (state, penalty, clk)
    begin
        mem_done <= '0';
        case state is
            when st_start =>
                sig_stall_count <= conv_integer(unsigned(penalty)) - 1;
            when st_stall =>
                if (falling_edge(clk)) then
                    sig_stall_count <= sig_stall_count - 1;
                end if;
            when st_done =>
                mem_done <= '1';
        end case;
    end process;
    -------------------------------------------------------------

    
    ------------memory instance----------------------------------
    mem_process: process ( clk ) is
        variable var_mem_block : mem_block;
        variable var_index : integer;
        variable var_wsel : integer;
    begin
        -- Init index and wsel from address
        var_index := conv_integer(unsigned(address(2 downto 0)));
        var_wsel := conv_integer(unsigned(address(11 downto 8)));
        
        -- update on falling edge
        if (reset = '1') then
            var_mem_block(0) := (others => X"0000");
            var_mem_block(1) := (others => X"0000");
            var_mem_block(2) := (others => X"0000");
            var_mem_block(3) := (others => X"0000");
            var_mem_block(4) := (others => X"0000");
            var_mem_block(5) := (others => X"0000");
            var_mem_block(6) := (others => X"0000");
            var_mem_block(7) := (others => X"0000");
        elsif (falling_edge(clk) and write = '1') then
            var_mem_block(var_index)(var_wsel) := data_in;
        end if;
 
        -- Continuous read to location specified by var_index
        for ii in 0 to 15 loop
            data_out(((ii*16)+15) downto (ii*16)) <= var_mem_block(var_index)(ii);
        end loop;
        
        -- probe signal for simulation purposes
        sig_mem_block <= var_mem_block;
    end process;
    -------------------------------------------------------------
    
end Behavioral;