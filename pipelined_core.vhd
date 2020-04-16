library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pipelined_core is
    Port ( reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           network_data_in : in STD_LOGIC_VECTOR(31 downto 0) );
end pipelined_core;

architecture Behavioral of pipelined_core is
    
begin
    
end Behavioral;