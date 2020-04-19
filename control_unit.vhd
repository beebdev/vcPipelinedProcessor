-----------------------------------------------------------------------
--  COMP3211 Computer Architecture 20T1                              --
--  Final Project: Real-time Vote Counting System                    --
--  Student: Po Jui Shih (z5187581)                                  --
-----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
    Port ( opcode       : in  STD_LOGIC_VECTOR (3 downto 0);
           reg_write    : out STD_LOGIC;
           mem_to_reg   : out STD_LOGIC_VECTOR(1 downto 0);
           mem_read     : out STD_LOGIC;
           mem_write    : out STD_LOGIC;
           alu_op       : out STD_LOGIC_VECTOR(1 downto 0) );
end control_unit;

architecture Behavioral of control_unit is
	constant OP_RECV    : STD_LOGIC_VECTOR(3 downto 0) := "0001";
    constant OP_ADD     : STD_LOGIC_VECTOR(3 downto 0) := "0010";
    constant OP_SUB     : STD_LOGIC_VECTOR(3 downto 0) := "0011";
    constant OP_CAD     : STD_LOGIC_VECTOR(3 downto 0) := "0100";
    constant OP_LT      : STD_LOGIC_VECTOR(3 downto 0) := "0101";
    constant OP_LC      : STD_LOGIC_VECTOR(3 downto 0) := "0110";
    constant OP_ST      : STD_LOGIC_VECTOR(3 downto 0) := "0111";
    constant OP_SC      : STD_LOGIC_VECTOR(3 downto 0) := "1000";
begin

    reg_write   <= '1' when (opcode = OP_RECV)
                         or (opcode = OP_ADD)
                         or (opcode = OP_SUB)
                         or (opcode = OP_CAD)
                         or (opcode = OP_LT)
                         or (opcode = OP_LC) else
                   '0';
                
    mem_to_reg  <= "00" when (opcode = OP_LT)
                          or (opcode = OP_LC) else
                   "01" when (opcode = OP_ADD)
                          or (opcode = OP_SUB)
                          or (opcode = OP_CAD) else
                   "10" when (opcode = OP_RECV) else
                   "11";

    mem_read    <= '1' when (opcode = OP_LT)
                         or (opcode = OP_LC) else
                   '0';

    mem_write   <= '1' when (opcode = OP_ST)
                         or (opcode = OP_SC) else
                   '0';

    alu_op      <= "00" when (opcode = OP_ADD) else
                   "01" when (opcode = OP_SUB) else
                   "10" when (opcode = OP_CAD) else
                   "11";
               
end Behavioral;