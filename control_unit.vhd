library ieee;
use ieee.std_logic_1164.all;
LIBRARY lpm;
USE lpm.lpm_components.all;

entity control_unit is
	port (
		clock, aclr, busy: in std_logic;
		ir: in std_logic_vector(15 downto 0);
		control: out std_logic_vector(47 downto 0);
		ucounterrst: out std_logic
	);
end control_unit;

architecture controller of control_unit is
	component rom_8 IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END component;

	signal ucount: std_logic_vector(3 downto 0);
	signal romaddr: std_logic_vector(13 downto 0);
	signal clockinv, regoutenable, reginenable, rst, cnt_en, dec_en: std_logic;
	signal romout: std_logic_vector(7 downto 0);
	signal s_control_out, s_control_in: std_logic_vector(15 downto 0);
	signal reg_out, reg_in: std_logic_vector(7 downto 0);
	signal s_regmap: std_logic_2d(1 downto 0, 2 downto 0);
	signal regmuxout, regmuxin: std_logic_vector(2 downto 0);
	signal rom_out_or: std_logic_2d(7 downto 0, 0 downto 0);
begin
	clockinv <= not(clock);
	
	romoutormap: for i in 0 to 7 generate
		rom_out_or(i, 0) <= romout(i);
	end generate romoutormap;
	
	valid: lpm_or
		generic map (
			LPM_WIDTH => 1,
			LPM_SIZE => 8
		)
		port map (
			data => rom_out_or,
			result(0) => dec_en
		);
	
	rst <= not(dec_en);
		
	cnt_en <= s_control_in(9) nand busy;

	ucounter: lpm_counter
		generic map (
			LPM_WIDTH => 4,
			LPM_DIRECTION => "UP"
		)
		port map (
			clock => clock,
			cnt_en => cnt_en,
			sclr => rst,
			aclr => aclr,
			q => ucount
		);
		
	romaddr(13 downto 4) <= ir(15 downto 6);
	romaddr(3 downto 0) <= ucount;
		
	combinational: rom_8
		port map (
			address => romaddr,
			clock => clockinv,
			q => romout
		);
		
	outdecoder: lpm_decode
		generic map (
			LPM_WIDTH => 4,
			LPM_DECODES => 16
		)
		port map (
			data => romout(7 downto 4),
			enable => dec_en,
			eq => s_control_out
		);
		
	indecoder: lpm_decode
		generic map (
			LPM_WIDTH => 4,
			LPM_DECODES => 16
		)
		port map (
			data => romout(3 downto 0),
			enable => dec_en,
			eq => s_control_in
		);
		
	regoutmap: for i in 0 to 2 generate
		s_regmap(0, i) <= ir(3+i);
		s_regmap(1, i) <= ir(i);
	end generate regoutmap;
		
	regoutmux: lpm_mux
		generic map (
			LPM_WIDTH => 3,
			LPM_SIZE => 2,
			LPM_WIDTHS => 1
		)
		port map (
			data => s_regmap,
			sel => romout(4 downto 4),
			result => regmuxout
		);
		
	regoutenable <= romout(7) and romout(6) and romout(5);
		
	regoutdecoder: lpm_decode
		generic map (
			LPM_WIDTH => 3,
			LPM_DECODES => 8
		)
		port map (
			data => regmuxout,
			enable => regoutenable,
			eq => reg_out
		);
		
	reginmux: lpm_mux
		generic map (
			LPM_WIDTH => 3,
			LPM_SIZE => 2,
			LPM_WIDTHS => 1
		)
		port map (
			data => s_regmap,
			sel => romout(0 downto 0),
			result => regmuxin
		);
		
	reginenable <= romout(3) and romout(2) and romout(1);
	
	regindecoder: lpm_decode
		generic map (
			LPM_WIDTH => 3,
			LPM_DECODES => 8
		)
		port map (
			data => regmuxin,
			enable => reginenable,
			eq => reg_in
		);
		
	control(47 downto 40) <= reg_out;
	control(39 downto 32) <= reg_in;
	control(31 downto 16) <= s_control_out;
	control(15 downto 0) <= s_control_in;
	ucounterrst <= rst;
end controller;