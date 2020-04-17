library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_2to1_1b is
    generic (N : integer);
    Port ( mux_select   : in  STD_LOGIC;
           data_a       : in  STD_LOGIC_VECTOR(N-1 downto 0);
           data_b       : in  STD_LOGIC_VECTOR(N-1 downto 0);
           data_out     : out STD_LOGIC_VECTOR(N-1 downto 0) );
end mux_2to1_1b;

architecture Behavioral of mux_2to1_1b is
begin

    data_out <= data_a when mux_select = '0' else
                data_b when mux_select = '1' else
                'X';

end Behavioral;