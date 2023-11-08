library ieee;
use ieee.std_logic_1164.all;

entity topblock_tb is
end topblock_tb;

architecture test of topblock_tb is
	component topblock is
		port (
			clock, aclr, busy, intr: in std_logic;
			inta, counterrst: out std_logic;
			axo, bxo, cxo, dxo, flags: out std_logic_vector(15 downto 0);
			pcoutq, irout: out std_logic_vector(15 downto 0)
		);
	end component;
	
	constant clk_period : time := 10 ns;
	
	signal clock, aclr, busy, intr, inta, counterrst: std_logic;
	signal axo, bxo, cxo, dxo, flags, pcoutq, irout: std_logic_vector(15 downto 0);
	signal intrreg: std_logic;
begin
	UUT: topblock
		port map (
			clock, aclr, busy, intrreg,
			inta, counterrst,
			axo, bxo, cxo, dxo, flags,
			pcoutq, irout
		);
		
	clk_process : process
	begin
		clock <= '0';
      wait for clk_period/2;
      clock <= '1';
      wait for clk_period/2;
   end process;
	
	test_process: process
	begin
		busy <= '0';
		intr <= '0';
		
		aclr <= '1';
		wait for clk_period;
		
		aclr <= '0';
		wait for clk_period;
		
		wait for clk_period * 20;
		intr <= '1';
		
		wait until intrreg='1';
		wait until intrreg='0';
		intr <= '0';
		
		wait;
	end process;
	
	
	reg: process (clock)
	begin
		if (rising_edge(clock)) then
			intrreg <= intr and not(inta);
		end if;
	end process;
end test;