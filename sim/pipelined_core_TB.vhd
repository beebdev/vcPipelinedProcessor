-----------------------------------------------------------------------
--  COMP3211 Computer Architecture 20T1                              --
--  Final Project: Real-time Vote Counting System                    --
--  Student: Po Jui Shih (z5187581)                                  --
-----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity pipelined_core_TB is
end pipelined_core_TB;

architecture Behavioral of pipelined_core_TB is
    component pipelined_core is
    Port ( reset            : in STD_LOGIC;
           clk              : in STD_LOGIC;
           done             : in STD_LOGIC;
           penalty          : in STD_LOGIC_VECTOR(3 downto 0);
           network_data_in  : in STD_LOGIC_VECTOR(15 downto 0);
           recv             : out STD_LOGIC );
    end component;
    
    -- Files
    file file_network : text;

    -- Inputs
    signal reset            : STD_LOGIC := '0';
    signal clk              : STD_LOGIC := '1';
    signal done             : STD_LOGIC := '0';
    signal penalty          : STD_LOGIC_VECTOR(3 downto 0) := "0010";
    signal network_data_in  : STD_LOGIC_VECTOR(15 downto 0);
    signal recv             : STD_LOGIC;
    
    -- Clock period definition
    constant clk_period : time := 10 ns;
    
begin
    
    ----------------------------------------------------------------
    UTT : pipelined_core
    port map ( reset            => reset,
               clk              => clk,
               done             => done,
               penalty          => penalty,
               network_data_in  => network_data_in,
               recv             => recv );
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    file_process : process
        variable v_line : line;
        variable v_network_data_in : STD_LOGIC_VECTOR(15 downto 0);
        variable v_space : character;
        variable v_start : STD_LOGIC := '1';
    begin
        -- Open file
        file_open(file_network, "network_traffic.txt", read_mode);

        -- Contiuously read file
        while not endfile(file_network) loop
--            wait until (falling_edge(clk) and recv = '1');
        
            readline(file_network, v_line);
            hread(v_line, v_network_data_in);
            read(v_line, v_space);
            network_data_in <= v_network_data_in;
            wait until (falling_edge(clk) and recv = '1');
            hread(v_line, v_network_data_in);
            read(v_line, v_space);
            network_data_in <= v_network_data_in;
            wait until (falling_edge(clk) and recv = '1');
            hread(v_line, v_network_data_in);
            network_data_in <= v_network_data_in;
            wait until (falling_edge(clk) and recv = '1');
        end loop;

        -- Mark done
        done <= '1';
        -- CLose file
        file_close(file_network);
        wait;
    end process;
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    stim_process : process
    begin
        reset <= '1';
        wait for 10ns;
        reset <= '0';
        wait for clk_period*80;
    end process;
    ----------------------------------------------------------------

end Behavioral;
