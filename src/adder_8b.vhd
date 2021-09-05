-----------------------------------------------------------------------
--  COMP3211 Computer Architecture 20T1                              --
--  Final Project: Real-time Vote Counting System                    --
--  Student: Po Jui Shih (z5187581)                                  --
-----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity adder_8b is
    Port ( src_a        : in  STD_LOGIC_VECTOR (7 downto 0);
           src_b        : in  STD_LOGIC_VECTOR (7 downto 0);
           sum          : out STD_LOGIC_VECTOR (7 downto 0);
           carry_out    : out STD_LOGIC );
end adder_8b;

architecture Behavioral of adder_8b is
    -- intermediate result with extra bit for carry
    signal result : STD_LOGIC_VECTOR(8 downto 0);
begin

    result <= ('0'&src_a) + ('0'&src_b);
    sum <= result(7 downto 0);
    carry_out <= result(8);
    
end Behavioral;