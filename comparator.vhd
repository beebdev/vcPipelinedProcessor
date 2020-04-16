library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity comparator is
    Port ( data_a   : in STD_LOGIC_VECTOR (31 downto 0);
           data_b   : in STD_LOGIC_VECTOR (31 downto 0);
           eq       : out STD_LOGIC );
end comparator;

architecture Behavioral of comparator is
begin

	process (data_a, data_b)
	begin
        if data_a = data_b then
            eq <= '1';
		end if;
	end process;
	
end Behavioral;