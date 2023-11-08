library ieee;
use ieee.std_logic_1164.all;
library lpm;
use lpm.lpm_components.all;

entity zero_controller is
	port (
		data: in std_logic_vector(15 downto 0);
		zrout: out std_logic
	);
end zero_controller;

architecture zc of zero_controller is
	signal sdata: std_logic_2d(15 downto 0, 0 downto 0);
	signal res: std_logic_vector(0 downto 0);
begin
	datamap: for i in 0 to 15 generate
		sdata(i, 0) <= data(i);
	end generate datamap;

	org: lpm_or
		generic map (
			LPM_WIDTH => 1,
			LPM_SIZE => 16
		)
		port map (
			data => sdata,
			result => res
		);
		
	zrout <= not(res(0));
end zc;