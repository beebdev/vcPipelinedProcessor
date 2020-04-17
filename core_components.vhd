library IEEE;
use IEEE.STD_LOGIC_1164.all;

package core_components is

    -----------IF Components--------------------------------
    component program_counter is
        Port ( reset    : in STD_LOGIC;
               clk      : in STD_LOGIC;
               pcwrite  : in STD_LOGIC;
               addr_in  : in STD_LOGIC_VECTOR (7 downto 0);
               addr_out : out STD_LOGIC_VECTOR (7 downto 0) );
    end component;

    component adder_8b is
        Port ( src_a        : in STD_LOGIC_VECTOR (7 downto 0);
               src_b        : in STD_LOGIC_VECTOR (7 downto 0);
               sum          : out STD_LOGIC_VECTOR (7 downto 0);
               carry_out    : out STD_LOGIC );
    end component;

    component instruction_memory is
        Port ( reset    : in STD_LOGIC;
               clk      : in STD_LOGIC;
               addr_in  : in STD_LOGIC_VECTOR (7 downto 0);
               insn_out : out STD_LOGIC_VECTOR (15 downto 0) );
    end component;

    component pipe_if_id is
        Port ( reset        : in STD_LOGIC;
               clk          : in STD_LOGIC;
               write        : in STD_LOGIC;
               inst_in      : in STD_LOGIC_VECTOR (15 downto 0);
               inst_out     : out STD_LOGIC_VECTOR (15 downto 0) );
    end component;

    -----------ID Components--------------------------------
    component control_unit is
        Port ( opcode       : in  STD_LOGIC_VECTOR (3 downto 0);
               reg_write    : out STD_LOGIC;
               mem_to_reg   : out STD_LOGIC_VECTOR(1 downto 0);
               mem_read     : out STD_LOGIC;
               mem_write    : out STD_LOGIC;
               alu_op       : out STD_LOGIC_VECTOR(1 downto 0) );
    end component;

    component register_file is
        Port ( reset            : in  STD_LOGIC;
               clk              : in  STD_LOGIC;
               read_register_a  : in  STD_LOGIC_VECTOR (3 downto 0);
               read_register_b  : in  STD_LOGIC_VECTOR (3 downto 0);
               write_enable     : in  STD_LOGIC;
               write_register   : in  STD_LOGIC_VECTOR (3 downto 0);
               write_data       : in  STD_LOGIC_VECTOR (15 downto 0);
               read_data_a      : out STD_LOGIC_VECTOR (15 downto 0);
               read_data_b      : out STD_LOGIC_VECTOR (15 downto 0) );
    end component;

    component pipe_id_ex is
        Port ( reset            : in  STD_LOGIC;
               clk              : in  STD_LOGIC;
               reg_write        : in  STD_LOGIC;
               mem_to_reg       : in  STD_LOGIC_VECTOR(1 downto 0);
               mem_read         : in  STD_LOGIC;
               mem_write        : in  STD_LOGIC;
               alu_op           : in  STD_LOGIC_VECTOR(1 downto 0);
               read_data_a      : in  STD_LOGIC_VECTOR(31 downto 0);
               read_data_b      : in  STD_LOGIC_VECTOR(31 downto 0);
               rs               : in  STD_LOGIC_VECTOR(3 downto 0);
               rt               : in  STD_LOGIC_VECTOR(3 downto 0);
               rd               : in  STD_LOGIC_VECTOR(3 downto 0);
               IDEX_reg_write   : in  STD_LOGIC;
               IDEX_mem_to_reg  : in  STD_LOGIC_VECTOR(1 downto 0);
               IDEX_mem_read    : in  STD_LOGIC;
               IDEX_mem_write   : in  STD_LOGIC;
               IDEX_alu_op      : in  STD_LOGIC_VECTOR(1 downto 0);
               IDEX_read_data_a : in  STD_LOGIC_VECTOR(31 downto 0);
               IDEX_read_data_b : in  STD_LOGIC_VECTOR(31 downto 0);
               IDEX_rs          : in  STD_LOGIC_VECTOR(3 downto 0);
               IDEX_rt          : in  STD_LOGIC_VECTOR(3 downto 0);
               IDEX_rd          : in  STD_LOGIC_VECTOR(3 downto 0) );
    end component;

    -----------EX Components--------------------------------
    component comparator is
        Port ( data_a   : in  STD_LOGIC_VECTOR (15 downto 0);
               data_b   : in  STD_LOGIC_VECTOR (15 downto 0);
               eq       : out STD_LOGIC );
    end component;

    component alu is
        Port ( data_a   : in  STD_LOGIC_VECTOR (15 downto 0);
               data_b   : in  STD_LOGIC_VECTOR (15 downto 0);
               alu_op   : in  STD_LOGIC_VECTOR (2 downto 0);
               result   : out STD_LOGIC_VECTOR (15 downto 0) );
    end component;

    component receive_buf is
        Port ( reset            : in  STD_LOGIC;
               clk              : in  STD_LOGIC;
               network_data_in  : in  STD_LOGIC_VECTOR (15 downto 0);
               receive_data     : out STD_LOGIC_VECTOR (15 downto 0) );
    end component;

    component pipe_ex_mem is
        Port ( reset                : in  STD_LOGIC;
               clk                  : in  STD_LOGIC;
               IDEX_reg_write       : in  STD_LOGIC;
               IDEX_mem_to_reg      : in  STD_LOGIC_VECTOR(1 downto 0);
               IDEX_mem_read        : in  STD_LOGIC;
               IDEX_mem_write       : in  STD_LOGIC;
               data_valid           : in  STD_LOGIC;
               IDEX_read_data_a     : in  STD_LOGIC_VECTOR(15 downto 0);
               IDEX_read_data_b     : in  STD_LOGIC_VECTOR(15 downto 0);
               alu_data             : in  STD_LOGIC_VECTOR(15 downto 0);
               receive_data         : in  STD_LOGIC_VECTOR(15 downto 0);
               IDEX_rd              : in  STD_LOGIC_VECTOR(3 downto 0);
               EXMEM_reg_write      : out STD_LOGIC;
               EXMEM_mem_to_reg     : out STD_LOGIC_VECTOR(1 downto 0);
               EXMEM_mem_read       : out STD_LOGIC;
               EXMEM_mem_write      : out STD_LOGIC;
               EXMEM_data_valid     : out STD_LOGIC;
               EXMEM_addr           : out STD_LOGIC_VECTOR(15 downto 0);
               EXMEM_store_data     : out STD_LOGIC_VECTOR(15 downto 0);
               EXMEM_alu_data       : out STD_LOGIC_VECTOR(15 downto 0);
               EXMEM_receive_data   : out STD_LOGIC_VECTOR(15 downto 0);
               EXMEM_rd             : out STD_LOGIC_VECTOR(3 downto 0) );
    end component;

    -----------MEM Components-------------------------------

    -- cache controller
    
    component pipe_mem_wb is
        Port ( reset                    : in  STD_LOGIC;
               clk                      : in  STD_LOGIC;
               EXMEM_reg_write          : in  STD_LOGIC;
               EXMEM_mem_to_reg         : in  STD_LOGIC_VECTOR(1 downto 0);
               cache_read_data          : in  STD_LOGIC_VECTOR(15 downto 0);
               EXMEM_alu_data           : in  STD_LOGIC_VECTOR(15 downto 0);
               EXMEM_receive_data       : in  STD_LOGIC_VECTOR(15 downto 0);
               EXMEM_rd                 : in  STD_LOGIC_VECTOR(3 downto 0);
               MEMWB_reg_write          : out STD_LOGIC;
               MEMWB_mem_to_reg         : out STD_LOGIC_VECTOR(1 downto 0);
               MEMWB_cache_read_data    : out STD_LOGIC_VECTOR(15 downto 0);
               MEMWB_alu_data           : out STD_LOGIC_VECTOR(15 downto 0);
               MEMWB_receive_data       : out STD_LOGIC_VECTOR(15 downto 0);
               MEMWB_reg_dst            : out STD_LOGIC_VECTOR(3 downto 0) );
    end component;

    component mux_3to1_Nb is
        generic (N : integer);
        Port ( mux_select   : in  STD_LOGIC_VECTOR(1 downto 0);
               data_a       : in  STD_LOGIC_VECTOR(N-1 downto 0);
               data_b       : in  STD_LOGIC_VECTOR(N-1 downto 0);
               data_c       : in  STD_LOGIC_VECTOR(N-1 downto 0);
               data_out     : out STD_LOGIC_VECTOR(N-1 downto 0) );
    end component;
end core_components;
