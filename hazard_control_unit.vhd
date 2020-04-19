library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hazard_control_unit is
    Port ( reset            : in  STD_LOGIC;
           clk              : in  STD_LOGIC;
           IFID_rs          : in  STD_LOGIC_VECTOR(3 downto 0);
           IFID_rt          : in  STD_LOGIC_VECTOR(3 downto 0);
           IFID_rd          : in  STD_LOGIC_VECTOR(3 downto 0);
           IDEX_mem_read    : in  STD_LOGIC;
           IDEX_mem_write   : in  STD_LOGIC;
           IDEX_rs          : in  STD_LOGIC_VECTOR(3 downto 0);
           IDEX_rt          : in  STD_LOGIC_VECTOR(3 downto 0);
           IDEX_rd          : in  STD_LOGIC_VECTOR(3 downto 0);
           EXMEM_mem_to_reg : in  STD_LOGIC_VECTOR(1 downto 0);
           EXMEM_reg_write  : in  STD_LOGIC;
           EXMEM_reg_dst    : in  STD_LOGIC_VECTOR(3 downto 0);
           MEMWB_reg_write  : in  STD_LOGIC;
           MEMWB_reg_dst    : in  STD_LOGIC_VECTOR(3 downto 0);
           cache_done       : in  STD_LOGIC;
           pc_write         : out STD_LOGIC;
           IFID_write       : out STD_LOGIC;
           stall            : out STD_LOGIC;
           rdata_a_sel      : out STD_LOGIC_VECTOR(1 downto 0);
           rdata_b_sel      : out STD_LOGIC_VECTOR(1 downto 0);
           rdata_c_sel      : out STD_LOGIC_VECTOR(1 downto 0) );
end hazard_control_unit;

architecture Behavioral of hazard_control_unit is
    type state_t is (st_normal, st_stall);
    signal state, next_state : state_t;

begin
    hcu_state_reg : process (reset, clk)
    begin
        if (reset = '1') then
            next_state <= st_normal;
        elsif (rising_edge(clk)) then
            next_state <= state;
        end if;
    end process;

    hcu_next_state_logic : process(state, cache_done,
                                  IDEX_mem_read, IDEX_mem_write)
    begin
        case state is
            when st_normal =>
                if (IDEX_mem_read = '1' or IDEX_mem_write = '1') then
                    next_state <= st_stall;
                else
                    next_state <= st_normal;    
                end if;
            when st_stall =>
                if (cache_done = '1') then
                    next_state <= st_normal;
                else
                    next_state <= st_stall;
                end if;
        end case;
    end process;

    hcd_output : process (state)
    begin
        case state is
            when st_normal =>
                stall <= '0';
            when st_stall =>
                stall <= '1';
        end case;
    end process;

    forwarding_process : process (MEMWB_reg_write, MEMWB_reg_dst,
                                  EXMEM_reg_write, EXMEM_reg_dst, EXMEM_mem_to_reg,
                                  IDEX_rs, IDEX_rt, IDEX_rd)
    begin
        -- Init all sel to zero (data from regfile)
        rdata_a_sel <= "00";
        rdata_b_sel <= "00";
        rdata_c_sel <= "00";

        -- Check dependency between IDEX and MEMWB
        if ((MEMWB_reg_write = '1') and (MEMWB_reg_dst /= "0000")) then
            if (MEMWB_reg_dst = IDEX_rs) then
                -- MEMWB.Rd == IDEX.Rs
                rdata_a_sel <= "11";
            elsif (MEMWB_reg_dst = IDEX_rt) then
                rdata_b_sel <= "11";
            elsif (MEMWB_reg_dst = IDEX_rd) then
                rdata_c_sel <= "11";
            end if;
        end if;

        -- Check dependency between IDEX and EXMEM
        if ((EXMEM_reg_write = '1') and (EXMEM_reg_dst /= "0000")) then
            if (EXMEM_reg_dst = IDEX_rs) then
                -- EXMEM.Rd == IDEX.Rs
                if (EXMEM_mem_to_reg = "01") then
                    -- EXMEM.mem_to_reg is alu_src
                    rdata_a_sel <= "01";
                elsif (EXMEM_mem_to_reg = "10") then
                    -- EXMEM.mem_to_reg is receive_buf
                    rdata_a_sel <= "10";
                end if;
            elsif (EXMEM_reg_dst = IDEX_rt) then
                -- EXMEM.Rd == IDEX.Rt
                if (EXMEM_mem_to_reg = "01") then
                    -- EXMEM.mem_to_reg is alu_src
                    rdata_b_sel <= "01";
                elsif (EXMEM_mem_to_reg = "10") then
                    -- EXMEM.mem_to_reg is receive_buf
                    rdata_b_sel <= "10";
                end if;
            elsif (EXMEM_reg_dst = IDEX_rd) then
                -- EXMEM.Rd == IDEX.Rd
                if (EXMEM_mem_to_reg = "01") then
                    -- EXMEM.mem_to_reg is alu_src
                    rdata_c_sel <= "01";
                elsif (EXMEM_mem_to_reg = "10") then
                    -- EXMEM.mem_to_reg is receive_buf
                    rdata_c_sel <= "10";
                end if;
            end if;
        end if;
    end process;
end Behavioral;