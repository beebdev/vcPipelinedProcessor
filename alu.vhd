library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity alu is
    Port ( data_a   : in STD_LOGIC_VECTOR (15 downto 0);
           data_b   : in STD_LOGIC_VECTOR (15 downto 0);
           alu_op   : in STD_LOGIC_VECTOR (2 downto 0);
           result   : out STD_LOGIC_VECTOR (15 downto 0) );
end alu;

architecture Behavioral of alu is
    signal result_t : STD_LOGIC_VECTOR(16 downto 0);
    constant ALU_OP_ADD : STD_LOGIC_VECTOR(2 downto 0) := "000";
    constant ALU_OP_SUB : STD_LOGIC_VECTOR(2 downto 0) := "001";
    constant ALU_OP_CAD : STD_LOGIC_VECTOR(2 downto 0) := "010";
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
                result <= result_t(15 downto 0) + conv_std_logic_vector(unsigned(result_t(16)), 15);
    end process;
	
end Behavioral;