-----------------------------------------------------------------------
--  COMP3211 Computer Architecture 20T1                              --
--  Final Project: Real-time Vote Counting System                    --
--  Student: Po Jui Shih (z5187581)                                  --
-----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity cache_controller is
    Port ( reset        : in  STD_LOGIC;
           clk          : in  STD_LOGIC;
           valid        : in  STD_LOGIC;
           read         : in  STD_LOGIC;
           write        : in  STD_LOGIC;
           total        : in  STD_LOGIC;
           address      : in  STD_LOGIC_VECTOR(15 downto 0);
           din          : in  STD_LOGIC_VECTOR(15 downto 0);
           m_done       : in  STD_LOGIC;
           address_o    : out STD_LOGIC_VECTOR(15 downto 0);
           c_din        : out STD_LOGIC_VECTOR(15 downto 0);
           c_w_word     : out STD_LOGIC;
           c_w_line     : out STD_LOGIC;
           m_read       : out STD_LOGIC;
           m_write      : out STD_LOGIC;
           cache_done   : out STD_LOGIC );
end cache_controller;

architecture Behavioral of cache_controller is
    type cache_prefix is array(0 to 3) of STD_LOGIC_VECTOR(2 downto 0);    
    signal sig_cache_prefix : cache_prefix;
    
    type state_t is (st_idle, st_ctag, st_wb, st_allocate);
    signal state, next_state : state_t;

    signal sig_address, sig_data : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal sig_D, sig_V, sig_T : STD_LOGIC := '0';
    signal sig_hit : STD_LOGIC := '0';
    
begin
    -----------state register-----------------------------------------
    state_reg : process (reset, clk)
    begin
        if (reset = '1') then
            state <= st_idle;
        elsif (falling_edge(clk)) then
            state <= next_state;
        end if;
    end process;
    ------------------------------------------------------------------
    
    ------------next state logic--------------------------------------
    next_state_logic : process (state, read, write, valid,
                                sig_hit, sig_D, sig_V, m_done)
    begin
        case state is
            when st_idle =>
                if (read = '1' or (write = '1' and valid = '1')) then
                    next_state <= st_ctag;
                else
                    next_state <= st_idle;
                end if;
            when st_ctag =>
                if (sig_V = '1' and sig_hit = '1') then
                    next_state <= st_idle;
                else
                    if (sig_D = '1') then
                        next_state <= st_wb;
                    else
                        next_state <= st_allocate;
                    end if;
                end if;
            when st_wb =>
                if (m_done = '1') then
                    next_state <= st_allocate;
                else
                    next_state <= st_wb;
                end if;
            when st_allocate =>
                if (m_done = '1') then
                    next_state <= st_ctag;
                else
                    next_state <= st_allocate;
                end if;
        end case;
    end process;
    ------------------------------------------------------------------

    ------------state output------------------------------------------
    state_output_p : process (reset, clk, state,
                              total, address, din, write,
                              sig_address, sig_V, sig_hit)
        variable var_cache_prefix : cache_prefix;
        variable var_index : integer;
    begin
        -- index is addresss[0-1]
        var_index := conv_integer(unsigned(sig_address(1 downto 0)));
        sig_D <= var_cache_prefix(var_index)(0);
        sig_V <= var_cache_prefix(var_index)(1);
        sig_T <= var_cache_prefix(var_index)(2);
        
        -- cache_prefix
        if (reset = '1') then
            var_cache_prefix(0) := (others => '0');
            var_cache_prefix(1) := (others => '0');
            var_cache_prefix(2) := (others => '0');
            var_cache_prefix(3) := (others => '0');
        elsif (rising_edge(clk)) then
            -- Init
            cache_done <= '0';
            c_w_word <= '0';
            c_w_line <= '0';
            m_read <= '0';
            m_write <= '0';
            
            -- Update on cases
            case state is
                when st_idle =>
                    -- Update stored address and data
                    if (total = '1') then
                        sig_address <= "00001111"&address(7 downto 0);
                    else
                        sig_address <= address;
                    end if;
--                    cache_done <= '1';
                    sig_address <= address;
                    sig_data <= din;
                when st_ctag =>
                    -- Update sig_hit
                    if (var_cache_prefix(var_index)(2) = sig_address(2)) then
                        sig_hit <= '1';
                    else
                        sig_hit <= '0';
                    end if;

                    -- Valid and hit
                    if (sig_V = '1' and sig_hit = '1') then
                        -- Set cache_done and valid
                        cache_done <= '1';
                        var_cache_prefix(var_index)(1) := '1';

                        if (write = '1') then
                            -- Set dirty bit and c_w_word
                            c_w_word <= '1';
                            var_cache_prefix(var_index)(0) := '1';
                        end if;
                    end if;
                when st_wb =>
                    m_write <= '1';
                when st_allocate =>
                    m_read <= '1';
                    c_w_line <= '1';
                    -- Set not dirty
                    var_cache_prefix(var_index)(0) := '0';
                    -- Set valid
                    var_cache_prefix(var_index)(1) := '1';
                    -- Set tag
                    var_cache_prefix(var_index)(2) := sig_address(2);
            end case;
        end if;
        sig_cache_prefix <= var_cache_prefix;
    end process;
    ------------------------------------------------------------------
    address_o <= sig_address;
    c_din <= sig_data;
    
end Behavioral;