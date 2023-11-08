library ieee;
use ieee.std_logic_1164.all;
LIBRARY lpm;
USE lpm.lpm_components.all;

entity jump_controller is
	port (
		flags: in std_logic_vector(15 downto 0);
		ir: in std_logic_vector(3 downto 0);
		pcin, pcinun: in std_logic;
		jump_enable: out std_logic
	);
end jump_controller;

architecture jc of jump_controller is
	signal data: std_logic_2d(15 downto 0, 0 downto 0);
	signal carry, parity, zero, sign, overflow: std_logic;
	signal result: std_logic_vector(0 downto 0);
begin
	carry <= flags(0);
	parity <= flags(2);
	zero <= flags(6);
	sign <= flags(7);
	overflow <= flags(11);
	

	data(0, 0) <= overflow;
	data(1, 0) <= not(overflow);
	data(2, 0) <= carry;
	data(3, 0) <= not(carry);
	data(4, 0) <= sign;
	data(5, 0) <= not(sign);
	data(6, 0) <= carry or zero;
	data(7, 0) <= not(carry) and not(zero);
	data(8, 0) <= zero;
	data(9, 0) <= not(zero);
	data(10, 0) <= parity;
	data(11, 0) <= not(parity);
	data(12, 0) <= sign xor overflow;
	data(13, 0) <= sign xnor overflow;
	data(14, 0) <= zero or (sign xor overflow);
	data(15, 0) <= not(zero) and (sign xnor overflow);
	
	
	jumpmux: lpm_mux
		generic map (
			LPM_WIDTH => 1,
			LPM_SIZE => 16,
			LPM_WIDTHS => 4
		)
		port map (
			data => data,
			sel => ir,
			result => result
		);
		
	jump_enable <= (result(0) and pcin) or pcinun;
end jc;