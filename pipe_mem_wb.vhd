-----------------------------------------------------------------------
--  COMP3211 Computer Architecture 20T1                              --
--  Final Project: Real-time Vote Counting System                    --
--  Student: Po Jui Shih (z5187581)                                  --
-----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pipe_mem_wb is
    Port ( reset                    : in  STD_LOGIC;
           clk                      : in  STD_LOGIC;
           EXMEM_reg_write          : in  STD_LOGIC;
           EXMEM_mem_to_reg         : in  STD_LOGIC_VECTOR(1 downto 0);
           cache_dout               : in  STD_LOGIC_VECTOR(15 downto 0);
           EXMEM_alu_data           : in  STD_LOGIC_VECTOR(15 downto 0);
           EXMEM_receive_data       : in  STD_LOGIC_VECTOR(15 downto 0);
           EXMEM_reg_dst            : in  STD_LOGIC_VECTOR(3 downto 0);
           MEMWB_reg_write          : out STD_LOGIC;
           MEMWB_mem_to_reg         : out STD_LOGIC_VECTOR(1 downto 0);
           MEMWB_cache_dout         : out STD_LOGIC_VECTOR(15 downto 0);
           MEMWB_alu_data           : out STD_LOGIC_VECTOR(15 downto 0);
           MEMWB_receive_data       : out STD_LOGIC_VECTOR(15 downto 0);
           MEMWB_reg_dst            : out STD_LOGIC_VECTOR(3 downto 0) );
end pipe_mem_wb;

architecture Behavioral of pipe_mem_wb is
begin

    process (reset, clk)
    begin
        if (reset = '1') then
            MEMWB_reg_write <= '0';
            MEMWB_mem_to_reg <= (others => '0');
            MEMWB_cache_dout <= (others => '0');
            MEMWB_alu_data <= (others => '0');
            MEMWB_receive_data <= (others => '0');
            MEMWB_reg_dst <= (others => '0');
        elsif (rising_edge(clk)) then
            MEMWB_reg_write <= EXMEM_reg_write;
            MEMWB_mem_to_reg <= EXMEM_mem_to_reg;
            MEMWB_cache_dout <= cache_dout;
            MEMWB_alu_data <= EXMEM_alu_data;
            MEMWB_receive_data <= EXMEM_receive_data;
            MEMWB_reg_dst <= EXMEM_reg_dst;
        end if;
    end process;

end Behavioral;