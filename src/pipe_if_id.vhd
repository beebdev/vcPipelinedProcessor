-----------------------------------------------------------------------
--  COMP3211 Computer Architecture 20T1                              --
--  Final Project: Real-time Vote Counting System                    --
--  Student: Po Jui Shih (z5187581)                                  --
-----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pipe_if_id is
    Port ( reset        : in  STD_LOGIC;
           clk          : in  STD_LOGIC;
           write        : in  STD_LOGIC;
           inst_in      : in  STD_LOGIC_VECTOR (15 downto 0);
           inst_out     : out STD_LOGIC_VECTOR (15 downto 0) );
end pipe_if_id;

architecture Behavioral of pipe_if_id is
begin

    process (reset, clk) is
    begin
        if (reset = '1') then
            inst_out <= (others => '0');
        elsif (rising_edge(clk) and write = '1') then
            inst_out <= inst_in;
        end if;
    end process;

end Behavioral;