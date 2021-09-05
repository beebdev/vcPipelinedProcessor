-----------------------------------------------------------------------
--  COMP3211 Computer Architecture 20T1                              --
--  Final Project: Real-time Vote Counting System                    --
--  Student: Po Jui Shih (z5187581)                                  --
-----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pipe_ex_mem is
    Port ( reset                : in  STD_LOGIC;
           clk                  : in  STD_LOGIC;
           IDEX_reg_write       : in  STD_LOGIC;
           IDEX_mem_to_reg      : in  STD_LOGIC_VECTOR(1 downto 0);
           IDEX_mem_read        : in  STD_LOGIC;
           IDEX_mem_write       : in  STD_LOGIC;
           IDEX_total           : in  STD_LOGIC;
           valid                : in  STD_LOGIC;
           IDEX_read_data_a     : in  STD_LOGIC_VECTOR(15 downto 0);
           IDEX_read_data_b     : in  STD_LOGIC_VECTOR(15 downto 0);
           alu_data             : in  STD_LOGIC_VECTOR(15 downto 0);
           receive_data         : in  STD_LOGIC_VECTOR(15 downto 0);
           IDEX_rd              : in  STD_LOGIC_VECTOR(3 downto 0);
           EXMEM_reg_write      : out STD_LOGIC;
           EXMEM_mem_to_reg     : out STD_LOGIC_VECTOR(1 downto 0);
           EXMEM_mem_read       : out STD_LOGIC;
           EXMEM_mem_write      : out STD_LOGIC;
           EXMEM_total          : out STD_LOGIC;
           EXMEM_cache_din      : out STD_LOGIC_VECTOR(15 downto 0);
           EXMEM_valid          : out STD_LOGIC;
           EXMEM_addr           : out STD_LOGIC_VECTOR(15 downto 0);
           EXMEM_alu_data       : out STD_LOGIC_VECTOR(15 downto 0);
           EXMEM_receive_data   : out STD_LOGIC_VECTOR(15 downto 0);
           EXMEM_reg_dst        : out STD_LOGIC_VECTOR(3 downto 0) );
end pipe_ex_mem;

architecture Behavioral of pipe_ex_mem is
begin

    process (reset, clk)
    begin
        if (reset = '1') then
            EXMEM_reg_write <= '0';
            EXMEM_mem_to_reg <= (others => '0');
            EXMEM_mem_read <= '0';
            EXMEM_mem_write <= '0';
            EXMEM_total <= '0';
            EXMEM_cache_din <= (others => '0');
            EXMEM_valid <= '0';
            EXMEM_addr <= (others => '0');
            EXMEM_alu_data <= (others => '0');
            EXMEM_receive_data <= (others => '0');
            EXMEM_reg_dst <= (others => '0');
        elsif (rising_edge(clk)) then
            EXMEM_reg_write <= IDEX_reg_write;
            EXMEM_mem_to_reg <= IDEX_mem_to_reg;
            EXMEM_mem_read <= IDEX_mem_read;
            EXMEM_mem_write <= IDEX_mem_write;
            EXMEM_total <= IDEX_total;
            EXMEM_cache_din <= IDEX_read_data_b;
            EXMEM_valid <= valid;
            EXMEM_addr <= IDEX_read_data_a;
            EXMEM_alu_data <= alu_data;
            EXMEM_receive_data <= receive_data;
            EXMEM_reg_dst <= IDEX_rd; 
        end if;
    end process;
    
end Behavioral;