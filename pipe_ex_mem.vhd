library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pipe_ex_mem is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           IDEX_reg_write : in STD_LOGIC;
           IDEX_write_sel : in STD_LOGIC;
           IDEX_cache_en : in STD_LOGIC;
           IDEX_store_data : in STD_LOGIC_VECTOR(31 downto 0);
           checksum_data : in STD_LOGIC_VECTOR(31 downto 0);
           receive_data : in STD_LOGIC_VECTOR(31 downto 0);
           IDEX_rd : in STD_LOGIC_VECTOR(3 downto 0);
           EXMEM_reg_write : out STD_LOGIC;
           EXMEM_write_src : out STD_LOGIC;
           EXMEM_cache_en : out STD_LOGIC_VECTOR(31 downto 0);
           EXMEM_store_data : out STD_LOGIC_VECTOR(31 downto 0);
           EXMEM_checksum_data : out STD_LOGIC_VECTOR(31 downto 0);
           EXMEM_receive_data : out STD_LOGIC_VECTOR(31 downto 0);
           EXMEM_rd : out STD_LOGIC_VECTOR(3 downto 0) );
end pipe_ex_mem;

architecture Behavioral of pipe_ex_mem is
begin

    process (reset, clk)
    begin
        if (reset = '1') then
            EXMEM_reg_write <= '0';
            EXMEM_write_src <= '0';
            EXMEM_cache_en <= '0';
            EXMEM_store_data <= (others => '0');
            EXMEM_checksum_data <= (others => '0');
            EXMEM_receive_data <= (others => '0');
            EXMEM_rd <= (others => '0');
        elsif (rising_edge(clk)) then
            EXMEM_reg_write <= IDEX_reg_write;
            EXMEM_write_src <= IDEX_write_src;
            EXMEM_cache_en <= IDEX_cache_en;
            EXMEM_store_data <= IDEX_store_data;
            EXMEM_checksum_data <= checksum_data;
            EXMEM_receive_data <= receive_data;
            EXMEM_rd <= IDEX_rd;
        end if;
    end process;
    
end Behavioral;