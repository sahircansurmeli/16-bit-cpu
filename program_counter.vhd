library ieee;
use ieee.std_logic_1164.all;
LIBRARY lpm;
USE lpm.lpm_components.all;

entity program_counter is
	port (
		clock, aclr, cnt_en, pcin, pcout: in std_logic;
		data: inout std_logic_vector(15 downto 0);
		q: out std_logic_vector(15 downto 0)
	);
end program_counter;

architecture pc of program_counter is
	signal sq: std_logic_vector(15 downto 0);
begin
	counter: lpm_counter
		generic map (
			LPM_WIDTH => 16,
			LPM_DIRECTION => "UP"
		)
		port map (
			data => data,
			clock => clock,
			cnt_en => cnt_en,
			aclr => aclr,
			sload => pcin,
			q => sq
		);
		
	q <= sq;
		
	tristate: for i in 0 to 15 generate
		data(i) <= sq(i) when pcout='1' else 'Z';
	end generate tristate;
end pc;