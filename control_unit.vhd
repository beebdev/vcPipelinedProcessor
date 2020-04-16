library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
    Port ( opcode       : in STD_LOGIC_VECTOR (3 downto 0);
           reg_write    : out STD_LOGIC;
           write_sel    : out STD_LOGIC );
end control_unit;

architecture Behavioral of control_unit is
	constant OP_RECV    : std_logic_vector(3 downto 0) := "0001";
	constant OP_CS      : std_logic_vector(3 downto 0) := "0010";
	constant OP_DS      : std_logic_vector(3 downto 0) := "0011";
begin

    -- Write to register when instruction is recv or checksum
    -- DS (data_store) does not write back.
    reg_write <= '1' when (opcode = OP_RECV
                           or opcode = OP_CS) else
                 '0';

    -- write back data mux select: 0->checksum, 1->receive
    write_sel <= '1' when (opcode = OP_RECV) else
                 '0';
               
end Behavioral;