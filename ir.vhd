library ieee;
use ieee.std_logic_1164.all;
LIBRARY lpm;
USE lpm.lpm_components.all;

entity instruction_register is
	port (
		clock, aclr, regin, regout: in std_logic;
		q: out std_logic_vector(15 downto 0);
		data: inout std_logic_vector(15 downto 0)
	);
end ir;

architecture flipflop of instruction_register is
	signal sq: std_logic_vector(15 downto 0);
begin
	ff: lpm_ff
		generic map (
			LPM_WIDTH => 16
		)
		port map (
			data => data,
			clock => clock,
			enable => regin,
			aclr => aclr,
			q => sq
		);
		
	q <= sq;
		
	tristate: for i in 0 to 15 generate
		data(i) <= sq(i) when regout='1' else 'Z';
	end generate tristate;
end flipflop;