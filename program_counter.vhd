-----------------------------------------------------------------------
--  COMP3211 Computer Architecture 20T1                              --
--  Final Project: Real-time Vote Counting System                    --
--  Student: Po Jui Shih (z5187581)                                  --
-----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity program_counter is
    Port ( reset    :  in STD_LOGIC;
           clk      :  in STD_LOGIC;
           pcwrite  :  in STD_LOGIC;
           addr_in  :  in STD_LOGIC_VECTOR (7 downto 0);
           addr_out : out STD_LOGIC_VECTOR (7 downto 0));
end program_counter;

architecture Behavioral of program_counter is
begin

    update_process: process ( reset, clk ) is
    begin
        if (reset = '1') then
            -- Set PC to 0 when reset = '1'
            addr_out <= (others => '0');
        elsif (rising_edge(clk) and pcwrite = '1') then
            -- Update PC when rising_edge and pcwrite = '1'
            addr_out <= addr_in;
        end if;
    end process;

end Behavioral;