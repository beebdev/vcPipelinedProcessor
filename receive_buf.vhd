library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity receive_buf is
    Port ( reset            : in STD_LOGIC;
           clk              : in STD_LOGIC;
           network_data_in  : in  STD_LOGIC_VECTOR (15 downto 0);
           sig_receive_data : out STD_LOGIC_VECTOR (15 downto 0) );
end receive_buf;

architecture Behavioral of receive_buf is
    -- more that one slot?
begin
    process (reset, clk)
    begin
        if (reset = '1') then
            sig_receive_data <= (others => '0');
        elsif (rising_edge(clk)) then
            sig_receive_data <= network_data_in;
        end if;
    end process;
end Behavioral;