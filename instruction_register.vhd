library ieee;
use ieee.std_logic_1164.all;
LIBRARY lpm;
USE lpm.lpm_components.all;

entity flags_register is
	port (
		clock, aclr, zin, flagsin, flagsout: in std_logic;
		flags: in std_logic_vector(15 downto 0);
		q: out std_logic_vector(15 downto 0);
		data: inout std_logic_vector(15 downto 0)
	);
end instruction_register;

architecture flipflop of instruction_register is
	signal muxdata: std_logic_2d(1 downto 0, 15 downto 0);
	signal muxresult, sq: std_logic_vector(15 downto 0);
	signal enable: std_logic;
begin
	enable <= zin or flagsin;
	
	muxmap: for i in 0 to 15 generate
		muxdata(0, i) <= flags(i);
		muxdata(1, i) <= data(i);
	end generate muxmap;
	
	mux: lpm_mux
		generic map (
			LPM_WIDTH => 16,
			LPM_SIZE => 2,
			LPM_WIDTHS => 1
		)
		port map (
			data => muxdata,
			sel(0) => flagsin,
			result => muxresult
		);
	
	ff: lpm_ff
		generic map (
			LPM_WIDTH => 16
		)
		port map (
			data => muxresult,
			clock => clock,
			enable => enable,
			aclr => aclr,
			q => sq
		);
		
	q <= sq;
		
	tristate: for i in 0 to 15 generate
		data(i) <= sq(i) when flagsout='1' else 'Z';
	end generate tristate;
end flipflop;