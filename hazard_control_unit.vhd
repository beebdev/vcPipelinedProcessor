library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hazard_detection is
    Port ( IDEX_write_dsrc  : in  STD_LOGIC_VECTOR (1 downto 0);
           IDEX_rt          : in  STD_LOGIC_VECTOR (3 downto 0);
           EXMEM_write_dsrc : in  STD_LOGIC_VECTOR (1 downto 0);
           EXMEM_rt         : in  STD_LOGIC_VECTOR (3 downto 0);
           IFID_rs          : in  STD_LOGIC_VECTOR (3 downto 0);
           IFID_rt          : in  STD_LOGIC_VECTOR (3 downto 0);
           IFID_write       : out STD_LOGIC;
           pc_write         : out STD_LOGIC;
           stall            : out STD_LOGIC );
end hazard_detection;

architecture Behavioral of hazard_detection is
begin

	process (IDEX_write_dsrc, IDEX_rt,
	         EXMEM_write_dsrc, EXMEM_rt,
	         IFID_rs, IFID_rt)
	begin
        -- Stalling algorithm:
        -- if id/ex or ex/mem reads memory and rt not 0 and rt equals to
        -- one of rs or rt in if/id register, then we stall
        
        -- Note:
        -- IDEX_write_dsrc = 2 -> access data memory (LOAD)
        if ((IDEX_write_dsrc = "10") and (IDEX_rt /= "0000")
                and ( (IDEX_rt = IFID_rs) or (IDEX_rt = IFID_rt) ))
            or ((EXMEM_write_dsrc = "10") and (EXMEM_rt /= "0000")
                and ( (EXMEM_rt = IFID_rs) or (EXMEM_rt = IFID_rt) )) then
            stall <= '1';
            pc_write <= '0';
            IFID_write <= '0';
        else
            stall <= '0';
            pc_write <= '1';
            IFID_write <= '1';
        end if;
    end process;

end Behavioral;