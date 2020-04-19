library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity cache_memory is
    Port ( reset        : in  STD_LOGIC;
           clk          : in  STD_LOGIC;
           w_word       : in  STD_LOGIC;
           w_line       : in  STD_LOGIC;
           address      : in  STD_LOGIC_VECTOR(15 downto 0);
           data_in      : in  STD_LOGIC_VECTOR(15 downto 0);
           m_data_in    : in  STD_LOGIC_VECTOR(255 downto 0);
           data_out     : out STD_LOGIC_VECTOR(15 downto 0) );
end cache_memory;

architecture Behavioral of cache_memory is
    -- Each cache_line consists of 16 16-bit cells
    type cache_line is array(0 to 15) of STD_LOGIC_VECTOR(15 downto 0);
    -- The cache_block consists of 4 cache)line
    type cache_block is array(0 to 3) of cache_line;
    
    signal m_din_cl : cache_line;
    signal sig_cache_block : cache_block;
begin
    
    cache_mem_process : process (clk)
        variable var_cache_block : cache_block;
        variable var_index : integer;
        variable var_wsel : integer;
    begin
        -- Convert address signals to integer
        var_wsel := conv_integer(unsigned(address(11 downto 8)));
        var_index := conv_integer(unsigned(address(1 downto 0)));
        
        -- Convert m_data_in to type cache_line
        for ii in 0 to 15 loop
            m_din_cl(ii) <= m_data_in(((ii*16)+15) downto ii*16);
        end loop;
        
        -- write values
        if (reset = '1') then
            var_cache_block(0) := (others => X"0000");
            var_cache_block(1) := (others => X"0000");
            var_cache_block(2) := (others => X"0000");
            var_cache_block(3) := (others => X"0000");
        elsif (falling_edge(clk)) then
            if (w_word = '1') then
                var_cache_block(var_index)(var_wsel) := data_in;
            elsif (w_line = '1') then
                Var_cache_block(var_index) := m_din_cl;
            end if;
        end if;
        
        -- Continuous read send to output
        data_out <= var_cache_block(var_index)(var_wsel);
        
        -- probe signal for simulation purposes
        sig_cache_block <= var_cache_block;
    end process;

end Behavioral;
