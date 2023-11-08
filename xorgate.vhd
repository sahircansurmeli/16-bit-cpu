library ieee;
use ieee.std_logic_1164.all;
LIBRARY lpm;
USE lpm.lpm_components.all;

entity xorgate is
	port (
		dataa, datab: in std_logic_vector(15 downto 0);
		enable: in std_logic;
		result: out std_logic_vector(15 downto 0)
	);
end xorgate;

architecture gate of xorgate is
	signal res: std_logic_vector(15 downto 0);
	signal data: std_logic_2d(1 downto 0, 15 downto 0);
begin
	datamap: for i in 0 to 15 generate
		data(0, i) <= dataa(i);
		data(1, i) <= datab(i);
	end generate datamap;
	
	andg: lpm_xor
		generic map (
			LPM_WIDTH => 16,
			LPM_SIZE => 2
		)
		port map (
			data => data,
			result => res
		);
		
	tristate: for i in 0 to 15 generate
		result(i) <= res(i) when enable = '1' else 'Z';
	end generate tristate;
end gate;