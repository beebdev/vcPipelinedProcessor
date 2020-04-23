-----------------------------------------------------------------------
--  COMP3211 Computer Architecture 20T1                              --
--  Final Project: Real-time Vote Counting System                    --
--  Student: Po Jui Shih (z5187581)                                  --
-----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pipelined_core is
    Port ( reset            : in STD_LOGIC;
           clk              : in STD_LOGIC;
           done             : in STD_LOGIC;
           penalty          : in STD_LOGIC_VECTOR(3 downto 0);
           network_data_in  : in STD_LOGIC_VECTOR(15 downto 0);
           recv             : out STD_LOGIC );
end pipelined_core;

architecture Behavioral of pipelined_core is
------------------------------------------------------------
-- Components                                             --
------------------------------------------------------------
    -----------IF Components--------------------------------
    component program_counter is
        Port ( reset    : in  STD_LOGIC;
               clk      : in  STD_LOGIC;
               pcwrite  : in  STD_LOGIC;
               addr_in  : in  STD_LOGIC_VECTOR (7 downto 0);
               addr_out : out STD_LOGIC_VECTOR (7 downto 0));
    end component;
    
    component adder_8b is
        Port ( src_a        : in  STD_LOGIC_VECTOR (7 downto 0);
               src_b        : in  STD_LOGIC_VECTOR (7 downto 0);
               sum          : out STD_LOGIC_VECTOR (7 downto 0);
               carry_out    : out STD_LOGIC );
    end component;
    
    component instruction_memory is
        Port ( reset    : in  STD_LOGIC;
               clk      : in  STD_LOGIC;
               done     : in  STD_LOGIC;
               addr_in  : in  STD_LOGIC_VECTOR (7 downto 0);
               insn_out : out STD_LOGIC_VECTOR (15 downto 0));
    end component;
    
    component pipe_if_id is
        Port ( reset        : in  STD_LOGIC;
               clk          : in  STD_LOGIC;
               write        : in  STD_LOGIC;
               inst_in      : in  STD_LOGIC_VECTOR (15 downto 0);
               inst_out     : out STD_LOGIC_VECTOR (15 downto 0) );
    end component;

    -----------ID Components--------------------------------
    component control_unit is
        Port ( opcode       : in  STD_LOGIC_VECTOR (3 downto 0);
               reg_write    : out STD_LOGIC;
               mem_to_reg   : out STD_LOGIC_VECTOR(1 downto 0);
               mem_read     : out STD_LOGIC;
               mem_write    : out STD_LOGIC;
               total        : out STD_LOGIC;
               alu_op       : out STD_LOGIC_VECTOR(1 downto 0) );
    end component;
    
    component register_file is
        Port ( reset            : in  STD_LOGIC;
               clk              : in  STD_LOGIC;
               read_register_a  : in  STD_LOGIC_VECTOR (3 downto 0);
               read_register_b  : in  STD_LOGIC_VECTOR (3 downto 0);
               read_register_c  : in  STD_LOGIC_VECTOR (3 downto 0);
               write_enable     : in  STD_LOGIC;
               write_register   : in  STD_LOGIC_VECTOR (3 downto 0);
               write_data       : in  STD_LOGIC_VECTOR (15 downto 0);
               read_data_a      : out STD_LOGIC_VECTOR (15 downto 0);
               read_data_b      : out STD_LOGIC_VECTOR (15 downto 0);
               read_data_c      : out STD_LOGIC_VECTOR (15 downto 0));
    end component;
    
    component pipe_id_ex is
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
    end component;

    -----------EX Components--------------------------------
    component mux_4to1_Nb is
        generic (N : integer);
        Port ( mux_select   : in  STD_LOGIC_VECTOR(1 downto 0);
               data_a       : in  STD_LOGIC_VECTOR(N-1 downto 0);
               data_b       : in  STD_LOGIC_VECTOR(N-1 downto 0);
               data_c       : in  STD_LOGIC_VECTOR(N-1 downto 0);
               data_d       : in  STD_LOGIC_VECTOR(N-1 downto 0);
               data_out     : out STD_LOGIC_VECTOR(N-1 downto 0) );
    end component;
    
    component comparator is
        Port ( data_a   : in  STD_LOGIC_VECTOR (15 downto 0);
               data_b   : in  STD_LOGIC_VECTOR (15 downto 0);
               eq       : out STD_LOGIC );
    end component;
    
    component alu is
        Port ( data_a   : in  STD_LOGIC_VECTOR (15 downto 0);
               data_b   : in  STD_LOGIC_VECTOR (15 downto 0);
               alu_op   : in  STD_LOGIC_VECTOR (1 downto 0);
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
    end component;
    -----------MEM Components-------------------------------

    -- cache controller
    component cache_controller is
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
    end component;
    
    component cache_memory is
        Port ( reset        : in  STD_LOGIC;
               clk          : in  STD_LOGIC;
               w_word       : in  STD_LOGIC;
               w_line       : in  STD_LOGIC;
               address      : in  STD_LOGIC_VECTOR(15 downto 0);
               data_in      : in  STD_LOGIC_VECTOR(15 downto 0);
               m_data_in    : in  STD_LOGIC_VECTOR(255 downto 0);
               data_out     : out STD_LOGIC_VECTOR(15 downto 0) );
    end component;
    
    component data_memory is
        Port ( reset        : in  STD_LOGIC;
               clk          : in  STD_LOGIC;
               read         : in  STD_LOGIC;
               write        : in  STD_LOGIC;
               address      : in  STD_LOGIC_VECTOR(15 downto 0);
               data_in      : in  STD_LOGIC_VECTOR(15 downto 0);
               penalty      : in  STD_LOGIC_VECTOR(3 downto 0);
               data_out     : out STD_LOGIC_VECTOR(255 downto 0);
               mem_done     : out STD_LOGIC );
    end component;
    
    component pipe_mem_wb is
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
    end component;
    
    -----------WB Components--------------------------------
    component mux_3to1_Nb is
        generic (N : integer);
        Port ( mux_select   : in  STD_LOGIC_VECTOR(1 downto 0);
            data_a       : in  STD_LOGIC_VECTOR(N-1 downto 0);
            data_b       : in  STD_LOGIC_VECTOR(N-1 downto 0);
            data_c       : in  STD_LOGIC_VECTOR(N-1 downto 0);
            data_out     : out STD_LOGIC_VECTOR(N-1 downto 0) );
    end component;

    -----------Hazard control-------------------------------
    component hazard_control_unit is
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
    end component;
    
------------------------------------------------------------
-- Signals                                                --
------------------------------------------------------------
    ------------ IF Stage signals --------------------------
    signal sig_curr_pc              : STD_LOGIC_VECTOR(7 downto 0);
    signal sig_next_pc              : STD_LOGIC_VECTOR(7 downto 0);
    signal sig_carry_out            : STD_LOGIC;
    signal sig_insn                 : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_one_8b               : STD_LOGIC_VECTOR(7 downto 0);

    ------------ ID Stage signals --------------------------
    signal sig_IFID_insn            : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_reg_write            : STD_LOGIC;
    signal sig_mem_to_reg           : STD_LOGIC_VECTOR(1 downto 0);
    signal sig_mem_read             : STD_LOGIC;
    signal sig_mem_write            : STD_LOGIC;
    signal sig_total                : STD_LOGIC;
    signal sig_alu_op               : STD_LOGIC_VECTOR(1 downto 0);
    signal sig_read_data_a          : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_read_data_b          : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_read_data_c          : STD_LOGIC_VECTOR(15 downto 0);

    ------------ EX Stage signals --------------------------
    signal sig_IDEX_reg_write       : STD_LOGIC;
    signal sig_IDEX_mem_to_reg      : STD_LOGIC_VECTOR(1 downto 0);
    signal sig_IDEX_mem_read        : STD_LOGIC;
    signal sig_IDEX_mem_write       : STD_LOGIC;
    signal sig_IDEX_total           : STD_LOGIC;
    signal sig_IDEX_alu_op          : STD_LOGIC_VECTOR(1 downto 0);
    signal sig_IDEX_read_data_a     : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_IDEX_read_data_b     : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_IDEX_read_data_c     : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_rdata_a              : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_rdata_b              : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_rdata_c              : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_IDEX_rs              : STD_LOGIC_VECTOR(3 downto 0);
    signal sig_IDEX_rt              : STD_LOGIC_VECTOR(3 downto 0);
    signal sig_IDEX_rd              : STD_LOGIC_VECTOR(3 downto 0);
    signal sig_valid                : STD_LOGIC;
    signal sig_alu_data             : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_receive_data         : STD_LOGIC_VECTOR(15 downto 0);

    ------------ MEM Stage signals -------------------------
    signal sig_EXMEM_reg_write      : STD_LOGIC;
    signal sig_EXMEM_mem_to_reg     : STD_LOGIC_VECTOR(1 downto 0);
    signal sig_EXMEM_mem_read       : STD_LOGIC;
    signal sig_EXMEM_mem_write      : STD_LOGIC;
    signal sig_EXMEM_total          : STD_LOGIC;
    signal sig_EXMEM_cache_din      : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_EXMEM_valid          : STD_LOGIC;
    signal sig_EXMEM_addr           : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_EXMEM_alu_data       : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_EXMEM_receive_data   : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_EXMEM_reg_dst        : STD_LOGIC_VECTOR(3 downto 0);
    signal sig_m_done               : STD_LOGIC;
    signal sig_m_write              : STD_LOGIC;
    signal sig_m_read               : STD_LOGIC;
    signal sig_m_dout               : STD_LOGIC_VECTOR(255 downto 0);
    signal sig_cm_address           : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_c_din                : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_c_w_word             : STD_LOGIC;
    signal sig_c_w_line             : STD_LOGIC;
    signal sig_cache_done           : STD_LOGIC;
    signal sig_cache_dout           : STD_LOGIC_VECTOR(15 downto 0);
    
    ------------ WB Stage signals --------------------------
    signal sig_MEMWB_reg_write      : STD_LOGIC;
    signal sig_MEMWB_mem_to_reg     : STD_LOGIC_VECTOR(1 downto 0);
    signal sig_MEMWB_cache_dout     : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_MEMWB_alu_data       : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_MEMWB_receive_data   : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_MEMWB_reg_dst        : STD_LOGIC_VECTOR(3 downto 0);
    signal sig_WB_write_data        : STD_LOGIC_VECTOR(15 downto 0);

    ------------ Hazard control Unit -----------------------
    signal sig_pcwrite : STD_LOGIC;
    signal sig_IFID_write : STD_LOGIC;
    signal sig_stall : STD_LOGIC;
    signal sig_rdata_a_sel : STD_LOGIC_VECTOR(1 downto 0);
    signal sig_rdata_b_sel : STD_LOGIC_VECTOR(1 downto 0);
    signal sig_rdata_c_sel : STD_LOGIC_VECTOR(1 downto 0);

begin
    sig_one_8b <= X"01";
    recv <= '1' when sig_IDEX_mem_to_reg = "10" else
            '0';

    ---------IF------------------------------------
    PC : program_counter
    Port map ( reset            => reset,
               clk              => clk,
               pcwrite          => sig_pcwrite,
               addr_in          => sig_next_pc,
               addr_out         => sig_curr_pc );

    Next_PC : adder_8b
    Port map ( src_a            => sig_curr_pc,
               src_b            => sig_one_8b,
               sum              => sig_next_pc,
               carry_out        => sig_carry_out );

    Insn_mem : instruction_memory
    Port map ( reset            => reset,
               clk              => clk,
               done             => done,
               addr_in          => sig_curr_pc,
               insn_out         => sig_insn );
               
    IFID_reg : pipe_if_id
    Port map ( reset            => reset,
               clk              => clk,
               write            => sig_IFID_write,
               inst_in          => sig_insn,
               inst_out         => sig_IFID_insn );
               
    ---------ID------------------------------------
    Ctrl_unit : control_unit
    Port map ( opcode           => sig_IFID_insn(15 downto 12),
               reg_write        => sig_reg_write,
               mem_to_reg       => sig_mem_to_reg,
               mem_read         => sig_mem_read,
               mem_write        => sig_mem_write,
               total            => sig_total,
               alu_op           => sig_alu_op );

    reg_file : register_file
    Port map ( reset            => reset,
               clk              => clk,
               read_register_a  => sig_IFID_insn(11 downto 8),
               read_register_b  => sig_IFID_insn(7 downto 4),
               read_register_c  => sig_IFID_insn(3 downto 0),
               write_enable     => sig_MEMWB_reg_write,
               write_register   => sig_MEMWB_reg_dst,
               write_data       => sig_WB_write_data,
               read_data_a      => sig_read_data_a,
               read_data_b      => sig_read_data_b,
               read_data_c      => sig_read_data_c );

    IDEX_reg : pipe_id_ex
    Port map ( reset            => reset,
               clk              => clk,
               stall            => sig_stall,
               reg_write        => sig_reg_write,
               mem_to_reg       => sig_mem_to_reg,
               mem_read         => sig_mem_read,
               mem_write        => sig_mem_write,
               total            => sig_total,
               alu_op           => sig_alu_op,
               read_data_a      => sig_read_data_a,
               read_data_b      => sig_read_data_b,
               read_data_c      => sig_read_data_c,
               rs               => sig_IFID_insn(11 downto 8),
               rt               => sig_IFID_insn(7 downto 4),
               rd               => sig_IFID_insn(3 downto 0),
               IDEX_reg_write   => sig_IDEX_reg_write,
               IDEX_mem_to_reg  => sig_IDEX_mem_to_reg,
               IDEX_mem_read    => sig_IDEX_mem_read,
               IDEX_mem_write   => sig_IDEX_mem_write,
               IDEX_total       => sig_IDEX_total,
               IDEX_alu_op      => sig_IDEX_alu_op,
               IDEX_read_data_a => sig_IDEX_read_data_a,
               IDEX_read_data_b => sig_IDEX_read_data_b,
               IDEX_read_data_c => sig_IDEX_read_data_c,
               IDEX_rs          => sig_IDEX_rs,
               IDEX_rt          => sig_IDEX_rt,
               IDEX_rd          => sig_IDEX_rd );

    ---------EX------------------------------------
    alu_a_src : mux_4to1_Nb
    generic map (N => 16)
    Port map( mux_select    => sig_rdata_a_sel,
                data_a        => sig_IDEX_read_data_a,
                data_b        => sig_EXMEM_alu_data,
                data_c        => sig_EXMEM_receive_data,
                data_d        => sig_WB_write_data,
                data_out      => sig_rdata_a );
                  
    alu_b_src : mux_4to1_Nb
    generic map (N => 16)
    Port map( mux_select    => sig_rdata_b_sel,
                data_a        => sig_IDEX_read_data_b,
                data_b        => sig_EXMEM_alu_data,
                data_c        => sig_EXMEM_receive_data,
                data_d        => sig_WB_write_data,
                data_out      => sig_rdata_b );
                  
    alu_c_src : mux_4to1_Nb
    generic map (N => 16)
    Port map( mux_select    => sig_rdata_c_sel,
                data_a        => sig_IDEX_read_data_c,
                data_b        => sig_EXMEM_alu_data,
                data_c        => sig_EXMEM_receive_data,
                data_d        => sig_WB_write_data,
                data_out      => sig_rdata_c );
                  
    comparator_c : comparator
    Port map ( data_a           => sig_rdata_c,
               data_b           => (others => '0'),
               eq               => sig_valid );

    alu_c : alu
    Port map ( data_a           => sig_rdata_a,
               data_b           => sig_rdata_b,
               alu_op           => sig_IDEX_alu_op,
               result           => sig_alu_data );

    recv_buf : receive_buf
    Port map ( reset            => reset,
               clk              => clk,
               network_data_in  => network_data_in,
               receive_data     => sig_receive_data );

    EXMEM_reg : pipe_ex_mem
    Port map ( reset            => reset,
               clk              => clk,
               IDEX_reg_write   => sig_IDEX_reg_write,
               IDEX_mem_to_reg  => sig_IDEX_mem_to_reg,
               IDEX_mem_read    => sig_IDEX_mem_read,
               IDEX_mem_write   => sig_IDEX_mem_write,
               IDEX_total       => sig_IDEX_total,
               valid            => sig_valid,
               IDEX_read_data_a => sig_rdata_a,
               IDEX_read_data_b => sig_rdata_b,
               alu_data         => sig_alu_data,
               receive_data     => sig_receive_data,
               IDEX_rd          => sig_IDEX_rd,
               EXMEM_reg_write  => sig_EXMEM_reg_write,
               EXMEM_mem_to_reg => sig_EXMEM_mem_to_reg,
               EXMEM_mem_read   => sig_EXMEM_mem_read,
               EXMEM_mem_write  => sig_EXMEM_mem_write,
               EXMEM_total      => sig_EXMEM_total,
               EXMEM_cache_din  => sig_EXMEM_cache_din,
               EXMEM_valid      => sig_EXMEM_valid,
               EXMEM_addr       => sig_EXMEM_addr,
               EXMEM_alu_data   => sig_EXMEM_alu_data,
               EXMEM_receive_data => sig_EXMEM_receive_data,
               EXMEM_reg_dst    => sig_EXMEM_reg_dst );

    ---------MEM-----------------------------------
    cache_ctlr : cache_controller
    Port map ( reset            => reset,
               clk              => clk,
               valid            => sig_EXMEM_valid,
               read             => sig_EXMEM_mem_read,
               write            => sig_EXMEM_mem_write,
               total            => sig_EXMEM_total,
               address          => sig_EXMEM_addr,
               din              => sig_EXMEM_cache_din,
               m_done           => sig_m_done,
               address_o        => sig_cm_address,
               c_din            => sig_c_din,
               c_w_word         => sig_c_w_word,
               c_w_line         => sig_c_w_line,
               m_read           => sig_m_read,
               m_write          => sig_m_write,
               cache_done       => sig_cache_done );
               
    cache_mem : cache_memory
    Port map ( reset            => reset,
               clk              => clk,
               w_word           => sig_c_w_word,
               w_line           => sig_c_w_line,
               address          => sig_cm_address,
               data_in          => sig_c_din,
               m_data_in        => sig_m_dout,
               data_out         => sig_cache_dout );
               
    data_mem : data_memory
    Port map ( reset            => reset,
               clk              => clk,
               read             => sig_m_read,
               write            => sig_m_write,
               address          => sig_cm_address,
               data_in          => sig_cache_dout,
               penalty          => penalty,
               data_out         => sig_m_dout,
               mem_done         => sig_m_done );
               
    ---------MEMWB------------------------------------
    MEMWB_reg : pipe_mem_wb
    Port map ( reset            => reset,
               clk              => clk,
               EXMEM_reg_write  => sig_EXMEM_reg_write,
               EXMEM_mem_to_reg => sig_EXMEM_mem_to_reg,
               cache_dout       => sig_cache_dout,
               EXMEM_alu_data   => sig_EXMEM_alu_data,
               EXMEM_receive_data => sig_EXMEM_receive_data,
               EXMEM_reg_dst    => sig_EXMEM_reg_dst,
               MEMWB_reg_write  => sig_MEMWB_reg_write,
               MEMWB_mem_to_reg => sig_MEMWB_mem_to_reg,
               MEMWB_cache_dout => sig_MEMWB_cache_dout,
               MEMWB_alu_data   => sig_MEMWB_alu_data,
               MEMWB_receive_data => sig_MEMWB_receive_data,
               MEMWB_reg_dst    => sig_MEMWB_reg_dst );
    
    ---------WB------------------------------------
    WB_src : mux_3to1_Nb
    generic map (N => 16)
    Port map ( mux_select       => sig_MEMWB_mem_to_reg,
               data_a           => sig_MEMWB_cache_dout,
               data_b           => sig_MEMWB_alu_data,
               data_c           => sig_MEMWB_receive_data,
               data_out         => sig_WB_write_data );
               
    ---------Hazard Control Unit------------------
    HCU : hazard_control_unit
    Port map ( reset            => reset,
               clk              => clk,
               IFID_rs          => sig_IFID_insn(11 downto 8),
               IFID_rt          => sig_IFID_insn(7 downto 4),
               IFID_rd          => sig_IFID_insn(3 downto 0),
               IDEX_mem_read    => sig_IDEX_mem_read,
               IDEX_mem_write   => sig_IDEX_mem_write,
               IDEX_rs          => sig_IDEX_rs,
               IDEX_rt          => sig_IDEX_rt,
               IDEX_rd          => sig_IDEX_rd,
               EXMEM_mem_to_reg => sig_EXMEM_mem_to_reg,
               EXMEM_reg_write  => sig_EXMEM_reg_write,
               EXMEM_reg_dst    => sig_EXMEM_reg_dst,
               MEMWB_reg_write  => sig_MEMWB_reg_write,
               MEMWB_reg_dst    => sig_MEMWB_reg_dst,
               cache_done       => sig_cache_done,
               pc_write         => sig_pcwrite,
               IFID_write       => sig_IFID_write,
               stall            => sig_stall,
               rdata_a_sel      => sig_rdata_a_sel,
               rdata_b_sel      => sig_rdata_b_sel,
               rdata_c_sel      => sig_rdata_c_sel );

end Behavioral;