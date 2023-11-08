library ieee;
use ieee.std_logic_1164.all;
library lpm;
use lpm.lpm_components.all;

-- ODD PARITY

entity parity_bit_calculator is
	port (
		data: in std_logic_vector(15 downto 0);
		pout: out std_logic
	);
end parity_bit_calculator;

architecture pbc of parity_bit_calculator is
	signal sdata: std_logic_2d(15 downto 0, 0 downto 0);
	signal res: std_logic_vector(0 downto 0);
begin
	datamap: for i in 0 to 15 generate
		sdata(i, 0) <= data(i);
	end generate datamap;

	xorg: lpm_xor
		generic map (
			LPM_WIDTH => 1,
			LPM_SIZE => 16
		)
		port map (
			data => sdata,
			result => res
		);
		
	pout <= not(res(0));
end pbc;