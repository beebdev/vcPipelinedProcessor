-----------------------------------------------------------------------
--  COMP3211 Computer Architecture 20T1                              --
--  Final Project: Real-time Vote Counting System                    --
--  Student: Po Jui Shih (z5187581)                                  --
-----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity data_memory is
    Port ( reset        : in  STD_LOGIC;
           clk          : in  STD_LOGIC;
           write_enable : in  STD_LOGIC;
           write_data   : in  STD_LOGIC_VECTOR(15 downto 0);
           addr_in      : in  STD_LOGIC_VECTOR(15 downto 0);
           data_out     : out STD_LOGIC_VECTOR(15 downto 0) );
end data_memory;

architecture Behavioral of data_memory is
    type mem_array is array(0 to 15) of STD_LOGIC_VECTOR(15 downto 0);
begin
    mem_process: process ( clk, write_enable, write_data, addr_in ) is
        variable var_data_mem : mem_array;
        variable var_addr     : integer;
    begin
        var_addr := conv_integer(addr_in);
        
        if (reset = '1') then
            -- initial values of the data memory : reset to zero 
            var_data_mem(0)  := X"0002";
            var_data_mem(1)  := X"0003";
            var_data_mem(2)  := X"0000";
            var_data_mem(3)  := X"0000";
            var_data_mem(4)  := X"0000";
            var_data_mem(5)  := X"0000";
            var_data_mem(6)  := X"0000";
            var_data_mem(7)  := X"0000";
            var_data_mem(8)  := X"0000";
            var_data_mem(9)  := X"0000";
            var_data_mem(10) := X"0000";
            var_data_mem(11) := X"0000";
            var_data_mem(12) := X"0000";
            var_data_mem(13) := X"0000";
            var_data_mem(14) := X"0000";
            var_data_mem(15) := X"0000";

        elsif (falling_edge(clk) and write_enable = '1') then
            -- memory writes on the falling clock edge
            var_data_mem(var_addr) := write_data;
        end if;
       
        -- continuous read of the memory location given by var_addr 
        data_out <= var_data_mem(var_addr);
 
        -- the following are probe signals (for simulation purpose) 
        sig_data_mem <= var_data_mem;

    end process;
end Behavioral;