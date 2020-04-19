-----------------------------------------------------------------------
--  COMP3211 Computer Architecture 20T1                              --
--  Final Project: Real-time Vote Counting System                    --
--  Student: Po Jui Shih (z5187581)                                  --
-----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity instruction_memory is
    Port ( reset    : in  STD_LOGIC;
           clk      : in  STD_LOGIC;
           done     : in  STD_LOGIC;
           addr_in  : in  STD_LOGIC_VECTOR (7 downto 0);
           insn_out : out STD_LOGIC_VECTOR (15 downto 0));
end instruction_memory;

architecture Behavioral of instruction_memory is
    type mem_array is array(0 to 15) of std_logic_vector(15 downto 0);
    signal sig_insn_mem : mem_array;
begin
    mem_process: process ( clk, addr_in ) is
        variable var_insn_mem : mem_array;
        variable var_addr     : integer;
    begin
        if (reset = '1') then
            insn_out <= (others => '0');
            var_insn_mem(0)   := X"1001";   -- recv $1
            var_insn_mem(1)   := X"1002";   -- recv $2
            var_insn_mem(2)   := X"1003";   -- recv $3
            var_insn_mem(3)   := X"4124";   -- cad  $4, $1, $2
            var_insn_mem(4)   := X"4434";   -- cad  $4, $4, $3
            var_insn_mem(5)   := X"5105";   -- lt   $5, $1
            var_insn_mem(6)   := X"6106";   -- lc   $6, $1
            var_insn_mem(7)   := X"3565";   -- sub  $5, $5, $6
            var_insn_mem(8)   := X"2525";   -- add  $5, $5, $2
            var_insn_mem(9)   := X"7153";   -- st   $1, $5, $3
            var_insn_mem(10)  := X"8123";   -- sc   $1, $2, $3
            var_insn_mem(11)  := X"0000";
            var_insn_mem(12)  := X"0000";
            var_insn_mem(13)  := X"0000";
            var_insn_mem(14)  := X"0000";
            var_insn_mem(15)  := X"0000";
        elsif (falling_edge(clk)) then
            -- read instructions on the rising clock edge
            var_addr := conv_integer(addr_in);
            if (done = '1') then
                insn_out <= X"0000";
            else
                insn_out <= var_insn_mem(var_addr mod 10);
            end if;
        end if;

        -- the following are probe signals (for simulation purpose)
        sig_insn_mem <= var_insn_mem;
    end process;

end Behavioral;