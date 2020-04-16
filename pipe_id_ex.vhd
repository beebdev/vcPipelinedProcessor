library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pipe_id_ex is
    Port ( reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           reg_write : in STD_LOGIC;
           write_sel : in STD_LOGIC;
           read_data_a : in STD_LOGIC_VECTOR(31 downto 0);
           read_data_b : in STD_LOGIC_VECTOR(31 downto 0);
           rs : in STD_LOGIC_VECTOR(3 downto 0);
           rt : in STD_LOGIC_VECTOR(3 downto 0);
           rd : in STD_LOGIC_VECTOR(3 downto 0);
           IDEX_reg_write : out STD_LOGIC;
           IDEX_write_sel : out STD_LOGIC;
           IDEX_read_data_a : out STD_LOGIC_VECTOR(31 downto 0);
           IDEX_read_data_b : out STD_LOGIC_VECTOR(31 downto 0);
           IDEX_rs : out STD_LOGIC_VECTOR(3 downto 0);
           IDEX_rt : out STD_LOGIC_VECTOR(3 downto 0);
           IDEX_rd : out STD_LOGIC_VECTOR(3 downto 0) );
end pipe_id_ex;

architecture Behavioral of pipe_id_ex is
begin
    store_proc : process (reset, clk) is
    begin
        if (reset = '1') then
            IDEX_reg_write <= '0';
            IDEX_write_sel <= '0';
            IDEX_read_data_a <= (others => '0');
            IDEX_read_data_b <= (others => '0');
            IDEX_rs <= (others => '0');
            IDEX_rt <= (others => '0');
            IDEX_rd <= (others => '0'); 
        elsif (rising_edge(clk)) then
            IDEX_reg_write <= reg_write;
            IDEX_write_sel <= write_sel;
            IDEX_read_data_a <= read_data_a;
            IDEX_read_data_b <= read_data_b;
            IDEX_rs <= rs;
            IDEX_rt <= rt;
            IDEX_rd <= rd;
        end if;
    end process;
end Behavioral;