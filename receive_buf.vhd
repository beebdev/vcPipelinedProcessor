-----------------------------------------------------------------------
--  COMP3211 Computer Architecture 20T1                              --
--  Final Project: Real-time Vote Counting System                    --
--  Student: Po Jui Shih (z5187581)                                  --
-----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity receive_buf is
    Port ( reset            : in  STD_LOGIC;
           clk              : in  STD_LOGIC;
           network_data_in  : in  STD_LOGIC_VECTOR (15 downto 0);
           receive_data     : out STD_LOGIC_VECTOR (15 downto 0) );
end receive_buf;

architecture Behavioral of receive_buf is
begin
    process (reset, clk)
    begin
        if (reset = '1') then
            receive_data <= (others => '0');
        elsif (rising_edge(clk)) then
            receive_data <= network_data_in;
        end if;
    end process;
end Behavioral;