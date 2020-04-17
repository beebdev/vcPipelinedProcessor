library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity register_file is
    Port ( reset            : in  STD_LOGIC;
           clk              : in  STD_LOGIC;
           read_register_a  : in  STD_LOGIC_VECTOR (3 downto 0);
           read_register_b  : in  STD_LOGIC_VECTOR (3 downto 0);
           write_enable     : in  STD_LOGIC;
           write_register   : in  STD_LOGIC_VECTOR (3 downto 0);
           write_data       : in  STD_LOGIC_VECTOR (15 downto 0);
           read_data_a      : out STD_LOGIC_VECTOR (15 downto 0);
           read_data_b      : out STD_LOGIC_VECTOR (15 downto 0));
end register_file;

architecture Behavioral of register_file is
    type reg_file is array(0 to 31) of STD_LOGIC_VECTOR(15 downto 0);
    signal sig_regfile : reg_file;
begin

    mem_process : process (reset, clk, read_register_a, read_register_b,
                    write_enable, write_register, write_data) is
        variable var_regfile        : reg_file;
        variable var_read_addr_a    : integer;
        variable var_read_addr_b    : integer;
        variable var_write_addr     : integer;
    begin
        var_read_addr_a := conv_integer(read_register_a);
        var_read_addr_b := conv_integer(read_register_b);
        var_write_addr  := conv_integer(write_register);
        
        if (reset = '1') then
            var_regfile := (others => X"0000");
        elsif (falling_edge(clk) and write_enable = '1') then
            var_regfile(var_write_addr) := write_data;
        end if;
        
        -- enforces value zero for register $0
        var_regfile(0) := X"0000";
        
        -- continuous read of the registers at location read_register_a
        -- and read_register_b
        read_data_a <= var_regfile(var_read_addr_a);
        read_data_b <= var_regfile(var_read_addr_b);
        
        -- the following are probe signals (for simulation purpose)
        sig_regfile <= var_regfile;
    end process;

end Behavioral;