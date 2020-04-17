library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_3to1_Nb is
    generic (N : integer);
    Port ( mux_select   : in  STD_LOGIC_VECTOR(1 downto 0);
           data_a       : in  STD_LOGIC_VECTOR(N-1 downto 0);
           data_b       : in  STD_LOGIC_VECTOR(N-1 downto 0);
           data_c       : in  STD_LOGIC_VECTOR(N-1 downto 0);
           data_out     : out STD_LOGIC_VECTOR(N-1 downto 0) );
end mux_3to1_Nb;

architecture Behavioral of mux_3to1_Nb is
begin

    data_out <= data_a when mux_select = "00" else
                data_b when mux_select = "01" else
                data_c when mux_select = "10" else
                (others => 'X');

end Behavioral;