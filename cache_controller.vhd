-----------------------------------------------------------------------
--  COMP3211 Computer Architecture 20T1                              --
--  Final Project: Real-time Vote Counting System                    --
--  Student: Po Jui Shih (z5187581)                                  --
-----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cache_controller is
    Port ( reset        : in STD_LOGIC;
           clk          : in STD_LOGIC;
           mem_read     : in STD_LOGIC;
           mem_write    : in STD_LOGIC;
           addr         : in STD_LOGIC_VECTOR(15 downto 0);
           data_in      : in STD_LOGIC_VECTOR(15 downto 0);
           data_out     : in STD_LOGIC_VECTOR(15 downto 0) );
end cache_controller;

architecture Behavioral of cache_controller is
begin

    result <= ('0'&src_a) + ('0'&src_b);
    sum <= result(7 downto 0);
    carry_out <= result(8);
    
end Behavioral;