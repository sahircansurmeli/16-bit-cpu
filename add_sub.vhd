library ieee;
use ieee.std_logic_1164.all;
LIBRARY lpm;
USE lpm.lpm_components.all;

entity add_sub is
	port (
		dataa, datab: in std_logic_vector(15 downto 0);
		cin, dir, enable: in std_logic;
		result: out std_logic_vector(15 downto 0);
		cout, overflow: out std_logic
	);
end add_sub;

architecture as of add_sub is
	signal res: std_logic_vector(15 downto 0);
begin
	addsub: lpm_add_sub
		generic map (
			LPM_WIDTH => 16
		)
		port map (
			cin => cin,
			dataa => dataa,
			datab => datab,
			add_sub => dir,
			cout => cout,
			overflow => overflow,
			result => res
		);
		
	tristate: for i in 0 to 15 generate
		result(i) <= res(i) when enable = '1' else 'Z';
	end generate tristate;
end as;