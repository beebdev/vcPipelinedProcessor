-----------------------------------------------------------------------
--  COMP3211 Computer Architecture 20T1                              --
--  Final Project: Real-time Vote Counting System                    --
--  Student: Po Jui Shih (z5187581)                                  --
-----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity alu is
    Port ( data_a   : in  STD_LOGIC_VECTOR (15 downto 0);
           data_b   : in  STD_LOGIC_VECTOR (15 downto 0);
           alu_op   : in  STD_LOGIC_VECTOR (1 downto 0);
           result   : out STD_LOGIC_VECTOR (15 downto 0) );
end alu;

architecture Behavioral of alu is
    signal result_t : STD_LOGIC_VECTOR(16 downto 0);
    constant ALU_OP_ADD : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant ALU_OP_SUB : STD_LOGIC_VECTOR(1 downto 0) := "01";
    constant ALU_OP_CAD : STD_LOGIC_VECTOR(1 downto 0) := "10";
begin

    process (alu_op, data_a, data_b, result_t)
    begin
        case alu_op is
            when ALU_OP_ADD =>
                result_t <= ('0'&data_a) + ('0'&data_b);
                result <= result_t(15 downto 0);
            when ALU_OP_SUB =>
                result_t <= ('0'&data_a) - ('0'&data_b);
                result <= result_t(15 downto 0);
            when ALU_OP_CAD =>
                result_t <= ('0'&data_a) + ('0'&data_b);
                if (result_t(16) = '1') then
                    result <= result_t(15 downto 0) + 1;
                end if;
        end case;
    end process;
	
end Behavioral;