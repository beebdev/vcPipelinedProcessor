library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pipe_ex_mem is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           EXMEM_reg_write : in STD_LOGIC;
           EXMEM_write_sel : in STD_LOGIC;
           EXMEM_checksum_data : in STD_LOGIC_VECTOR(31 downto 0);
           EXMEM_receive_data : in STD_LOGIC_VECTOR(31 downto 0);
           EXMEM_rd : in STD_LOGIC_VECTOR(3 downto 0);
           MEMWB_reg_write : out STD_LOGIC;
           MEMWB_write_sel : out STD_LOGIC;
           MEMWB_checksum_data : out STD_LOGIC_VECTOR(31 downto 0);
           MEMWB_receive_data : out STD_LOGIC_VECTOR(31 downto 0);
           MEMWB_reg_dst : out STD_LOGIC_VECTOR(3 downto 0) );
end pipe_ex_mem;

architecture Behavioral of pipe_ex_mem is
begin

    process (reset, clk)
    begin
        if (reset = '1') then
            MEMWB_reg_write <= '0';
            MEMWB_write_sel <= '0';
            MEMWB_checksum_data <= (others => '0');
            MEMWB_receive_data <= (others => '0');
            MEMWB_reg_dst <= (others => '0');
        elsif (rising_edge(clk)) then
            MEMWB_reg_write <= EXMEM_reg_write;
            MEMWB_write_sel <= EXMEM_write_sel;
            MEMWB_checksum_data <= EXMEM_checksum_data;
            MEMWB_receive_data <= EXMEM_receive_data;
            MEMWB_reg_dst <= EXMEM_rd;
        end if;
    end process;
    
end Behavioral;