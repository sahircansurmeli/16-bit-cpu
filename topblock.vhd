library ieee;
use ieee.std_logic_1164.all;

entity topblock is
	port (
		clock, aclr, busy, intr: in std_logic;
		inta, counterrst: out std_logic;
		axo, bxo, cxo, dxo, flags: out std_logic_vector(15 downto 0);
		pcoutq, irout: out std_logic_vector(15 downto 0)
	);
end topblock;

architecture top of topblock is
	component cpu is
		port (
			clock, aclr, busy, intr: in std_logic;
			marin, ramin, ramout, inta, counterrst, input: out std_logic;
			data: inout std_logic_vector(15 downto 0);
			axo, bxo, cxo, dxo, flags: out std_logic_vector(15 downto 0);
			pcoutq, irout: out std_logic_vector(15 downto 0)
		);
	end component;
	
	component memory is
		port (
			clock, aclr, marin, ramin, ramout: in std_logic;
			data: inout std_logic_vector(15 downto 0)
		);
	end component;
	
	signal marin, ramin, ramout, input: std_logic;
	signal data: std_logic_vector(15 downto 0);
begin
	processor: cpu
		port map (
			clock => clock,
			aclr => aclr,
			busy => busy,
			intr => intr,
			marin => marin,
			ramin => ramin,
			ramout => ramout,
			inta => inta,
			counterrst => counterrst,
			input => input,
			data => data,
			axo => axo,
			bxo => bxo,
			cxo => cxo,
			dxo => dxo,
			flags => flags,
			pcoutq => pcoutq,
			irout => irout
		);
		
	mem: memory
		port map (
			clock => clock,
			aclr => aclr,
			marin => marin,
			ramin => ramin,
			ramout => ramout,
			data => data
		);
end top;