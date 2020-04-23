-----------------------------------------------------------------------
--  COMP3211 Computer Architecture 20T1                              --
--  Final Project: Real-time Vote Counting System                    --
--  Student: Po Jui Shih (z5187581)                                  --
-----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pipe_id_ex is
    Port ( reset            : in  STD_LOGIC;
           clk              : in  STD_LOGIC;
           stall            : in  STD_LOGIC;
           reg_write        : in  STD_LOGIC;
           mem_to_reg       : in  STD_LOGIC_VECTOR(1 downto 0);
           mem_read         : in  STD_LOGIC;
           mem_write        : in  STD_LOGIC;
           total            : in  STD_LOGIC;
           alu_op           : in  STD_LOGIC_VECTOR(1 downto 0);
           read_data_a      : in  STD_LOGIC_VECTOR(15 downto 0);
           read_data_b      : in  STD_LOGIC_VECTOR(15 downto 0);
           read_data_c      : in  STD_LOGIC_VECTOR(15 downto 0);
           rs               : in  STD_LOGIC_VECTOR(3 downto 0);
           rt               : in  STD_LOGIC_VECTOR(3 downto 0);
           rd               : in  STD_LOGIC_VECTOR(3 downto 0);
           IDEX_reg_write   : out STD_LOGIC;
           IDEX_mem_to_reg  : out STD_LOGIC_VECTOR(1 downto 0);
           IDEX_mem_read    : out STD_LOGIC;
           IDEX_mem_write   : out STD_LOGIC;
           IDEX_total       : out STD_LOGIC;
           IDEX_alu_op      : out STD_LOGIC_VECTOR(1 downto 0);
           IDEX_read_data_a : out STD_LOGIC_VECTOR(15 downto 0);
           IDEX_read_data_b : out STD_LOGIC_VECTOR(15 downto 0);
           IDEX_read_data_c : out STD_LOGIC_VECTOR(15 downto 0);
           IDEX_rs          : out STD_LOGIC_VECTOR(3 downto 0);
           IDEX_rt          : out STD_LOGIC_VECTOR(3 downto 0);
           IDEX_rd          : out STD_LOGIC_VECTOR(3 downto 0) );
end pipe_id_ex;

architecture Behavioral of pipe_id_ex is
begin
    store_proc : process (reset, clk) is
    begin
        if (reset = '1') then
            IDEX_reg_write <= '0';
            IDEX_mem_to_reg <= (others => '0');
            IDEX_mem_read <= '0';
            IDEX_mem_write <= '0';
            IDEX_total <= '0';
            IDEX_alu_op <= (others => '0');
            IDEX_read_data_a <= (others => '0');
            IDEX_read_data_b <= (others => '0');
            IDEX_read_data_c <= (others => '0');
            IDEX_rs <= (others => '0');
            IDEX_rt <= (others => '0');
            IDEX_rd <= (others => '0');
        elsif (rising_edge(clk)) then
            -- Store zeros (nop) if stall = '1' for control signals
            if (stall = '1') then
                IDEX_reg_write <= '0';
                IDEX_mem_to_reg <= (others => '0');
                IDEX_mem_read <= '0';
                IDEX_mem_write <= '0';
                IDEX_total <= '0';
                IDEX_alu_op <= (others => '0');
            else
                IDEX_reg_write <= reg_write;
                IDEX_mem_to_reg <= mem_to_reg;
                IDEX_mem_read <= mem_read;
                IDEX_mem_write <= mem_write;
                IDEX_total <= total;
                IDEX_alu_op <= alu_op;
            end if;
            
            IDEX_read_data_a <= read_data_a;
            IDEX_read_data_b <= read_data_b;
            IDEX_read_data_c <= read_data_c;
            IDEX_rs <= rs;
            IDEX_rt <= rt;
            IDEX_rd <= rd;
        end if;
    end process;
end Behavioral;