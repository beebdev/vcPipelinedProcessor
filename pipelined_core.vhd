library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pipelined_core is
    Port ( reset            : in STD_LOGIC;
           clk              : in STD_LOGIC;
           network_data_in  : in STD_LOGIC_VECTOR(31 downto 0) );
end pipelined_core;

architecture Behavioral of pipelined_core is
    ------------ IF Stage signals ------------------------------
    signal sig_curr_pc : STD_LOGIC_VECTOR(7 downto 0);
    signal sig_next_pc : STD_LOGIC_VECTOR(7 downto 0);
    signal sig_carry_out : STD_LOGIC;
    signal sig_insn : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_one_8b : STD_LOGIC_VECTOR(7 downto 0);

    ------------ ID Stage signals ------------------------------
    signal sig_IFID_insn : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_reg_write : STD_LOGIC;
    signal sig_mem_to_reg : STD_LOGIC_VECTOR(1 downto 0);
    signal sig_mem_read : STD_LOGIC;
    signal sig_mem_write : STD_LOGIC;
    signal sig_alu_op : STD_LOGIC_VECTOR(1 downto 0);
    signal sig_read_data_a : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_read_data_b : STD_LOGIC_VECTOR(15 downto 0);

    ------------ EX Stage signals ------------------------------
    signal sig_IDEX_reg_write : STD_LOGIC;
    signal sig_IDEX_mem_to_reg : STD_LOGIC_VECTOR(1 downto 0);
    signal sig_IDEX_mem_read : STD_LOGIC;
    signal sig_IDEX_mem_write : STD_LOGIC;
    signal sig_IDEX_alu_op : STD_LOGIC_VECTOR(1 downto 0);
    signal sig_IDEX_read_data_a : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_IDEX_read_data_b : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_IDEX_rs : STD_LOGIC_VECTOR(3 downto 0);
    signal sig_IDEX_rt : STD_LOGIC_VECTOR(3 downto 0);
    signal sig_IDEX_rd : STD_LOGIC_VECTOR(3 downto 0);
    signal sig_data_valid : STD_LOGIC;
    signal sig_alu_data : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_receive_data : STD_LOGIC_VECTOR(15 downto 0);

    ------------ MEM Stage signals -----------------------------
    signal sig_EXMEM_reg_write : STD_LOGIC;
    signal sig_EXMEM_mem_to_reg : STD_LOGIC_VECTOR(1 downto 0);
    signal sig_EXMEM_mem_read : STD_LOGIC;
    signal sig_EXMEM_mem_write : STD_LOGIC;
    signal sig_EXMEM_data_valid : STD_LOGIC;
    signal sig_EXMEM_addr : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_EXMEM_store_data : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_EXMEM_alu_data : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_EXMEM_receive_data : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_EXMEM_rd : STD_LOGIC_VECTOR(3 downto 0);
    signal sig_cache_read_data : STD_LOGIC_VECTOR(15 downto 0);
    
    ------------ WB Stage signals ------------------------------
    signal sig_MEMWB_reg_write : STD_LOGIC;
    signal sig_MEMWB_mem_to_reg : STD_LOGIC_VECTOR(1 downto 0);
    signal sig_MEMWB_cache_read_data : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_MEMWB_alu_data : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_MEMWB_receive_data : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_MEMWB_reg_dst : STD_LOGIC_VECTOR(3 downto 0);
    signal sig_WB_write_data : STD_LOGIC_VECTOR(15 downto 0);

    ------------ Hazard control Unit ---------------------------
    signal sig_pcwrite : STD_LOGIC;
    signal sig_IFID_write : STD_LOGIC;

begin
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
               addr_in          => sig_curr_pc,
               insn_out         => sig_insn );

    IFID_reg : pipe_if_id
    Port map ( reset            => reset,
               clk              => clk,
               write            => sig_IFID_write,
               inst_in          => sig_insn,
               inst_out         => sig_IFID_insn );

    Ctrl_unit : control_unit
    Port map ( opcode           => sig_IFID_insn(15 downto 12),
               reg_write        => sig_reg_write,
               mem_to_reg       => sig_mem_to_reg,
               mem_read         => sig_mem_read,
               mem_write        => sig_mem_write,
               alu_op           => sig_alu_op );

    reg_file : register_file
    Port map ( reset            => reset,
               clk              => clk,
               read_register_a  => sig_IFID_insn(11 downto 8);
               read_register_b  => sig_IFID_insn(7 downto 4);
               write_enable     => sig_MEMWB_reg_write,
               write_register   => sig_MEMWB_reg_dst,
               write_data       => sig_WB_write_data,
               read_data_a      => sig_read_data_a,
               read_data_b      => sig_read_data_b );

    IDEX_reg : pipe_id_ex
    Port map ( reset            => reset,
               clk              => clk,
               reg_write        => sig_reg_write,
               mem_to_reg       => sig_mem_to_reg,
               mem_read         => sig_mem_read,
               mem_write        => sig_mem_write,
               alu_op           => sig_alu_op,
               read_data_a      => sig_read_data_a,
               read_data_b      => sig_read_data_b,
               rs               => sig_IFID_insn(11 downto 8),
               rt               => sig_IFID_insn(7 downto 4),
               rd               => sig_IFID_insn(3 downto 0),
               IDEX_reg_write   => sig_IDEX_reg_write
               IDEX_mem_to_reg  => sig_IDEX_mem_to_reg,
               IDEX_mem_read    => sig_IDEX_mem_read,
               IDEX_mem_write   => sig_IDEX_mem_write,
               IDEX_alu_op      => sig_IDEX_alu_op,
               IDEX_read_data_a => sig_IDEX_read_data_a,
               IDEX_read_data_b => sig_IDEX_read_data_b,
               IDEX_rs          => sig_IDEX_rs,
               IDEX_rt          => sig_IDEX_rt,
               IDEX_rd          => sig_IDEX_rd );

    comparator_c : comparator
    Port map ( data_a           => sig_IDEX_read_data_a,
               data_b           => (others => '0');
               eq               => sig_data_valid );

    alu_c : alu
    Port map ( data_a           => sig_IDEX_read_data_a,
               data_b           => sig_IDEX_read_data_b,
               alu_op           => sig_IDEX_alu_op,
               result           => sig_alu_data );

    recv_buf : receive_buf
    Port map ( reset            => reset,
               clk              => clk,
               network_data_in  => network_data_in,
               receive_data     => sig_receive_data );

    EXMEM_reg : pipe_ex_mem
    Port map ( reset                => reset,
               clk                  => clk,
               IDEX_reg_write       => sig_IDEX_reg_write,
               IDEX_mem_to_reg      => sig_IDEX_mem_to_reg,
               IDEX_mem_read        => sig_IDEX_mem_read,
               IDEX_mem_write       => sig_IDEX_mem_write,
               data_valid           => sig_data_valid,
               IDEX_read_data_a     => sig_IDEX_read_data_a,
               IDEX_read_data_b     => sig_IDEX_read_data_b,
               alu_data             => sig_alu_data,
               receive_data         => sig_receive_data,
               IDEX_rd              => sig_IDEX_rd,
               EXMEM_reg_write      => sig_EXMEM_reg_write,
               EXMEM_mem_to_reg     => sig_EXMEM_mem_to_reg,
               EXMEM_mem_read       => sig_EXMEM_mem_read,
               EXMEM_mem_write      => sig_EXMEM_mem_write,
               EXMEM_data_valid     => sig_EXMEM_data_valid,
               EXMEM_addr           => sig_EXMEM_addr,
               EXMEM_store_data     => sig_EXMEM_store_data,
               EXMEM_alu_data       => sig_EXMEM_alu_data,
               EXMEM_receive_data   => sig_EXMEM_receive_data,
               EXMEM_rd             => sig_EXMEM_rd );

    -- cache

    MEMWB_reg : pipe_mem_wb
    Port map ( reset                    => reset,
               clk                      => clk,
               EXMEM_reg_write          => sig_EXMEM_reg_write,
               EXMEM_mem_to_reg         => sig_EXMEM_mem_to_reg,
               cache_read_data          => sig_cache_read_data,
               EXMEM_alu_data           => sig_EXMEM_alu_data,
               EXMEM_receive_data       => sig_EXMEM_receive_data,
               EXMEM_rd                 => sig_EXMEM_rd,
               MEMWB_reg_write          => sig_MEMWB_reg_write,
               MEMWB_mem_to_reg         => sig_MEMWB_mem_to_reg,
               MEMWB_cache_read_data    => sig_MEMWB_cache_read_data,
               MEMWB_alu_data           => sig_MEMWB_alu_data,
               MEMWB_receive_data       => sig_MEMWB_receive_data,
               MEMWB_reg_dst            => sig_MEMWB_reg_dst );
    
    WB_src : mux_3to1_Nb
    generic map (N => 16)
    Port map ( mux_select   => sig_MEMWB_mem_to_reg,
               data_a       => sig_MEMWB_cache_read_data,
               data_b       => sig_MEMWB_alu_data,
               data_c       => sig_MEMWB_receive_data,
               data_out     => sig_WB_write_data );

end Behavioral;