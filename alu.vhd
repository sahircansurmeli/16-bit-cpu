library ieee;
use ieee.std_logic_1164.all;
LIBRARY lpm;
USE lpm.lpm_components.all;

entity alu is
	port (
		clock, aclr, yin, zin, zinadd, zout: in std_logic;
		ir: in std_logic_vector(3 downto 0);
		cout, parity, zero, sign, overflow: out std_logic;
		data: inout std_logic_vector(15 downto 0)
	);
end alu;

architecture arith_logic of alu is
	signal add_sub_mux_in: std_logic_2d(1 downto 0, 15 downto 0);
	signal add_sub_mux_sel: std_logic_vector(0 downto 0);
	signal y, result, z, add_sub_datab: std_logic_vector(15 downto 0);
	signal add_sub_dir, add_sub_ena, zinadd_inv, s_zin, pxorout, add_sub_cin: std_logic;
	signal enable: std_logic_vector(15 downto 0);
	
	component add_sub is
		port (
			dataa, datab: in std_logic_vector(15 downto 0);
			cin, dir, enable: in std_logic;
			result: out std_logic_vector(15 downto 0);
			cout, overflow: out std_logic
		);
	end component;
	
	component orgate is
		port (
			dataa, datab: in std_logic_vector(15 downto 0);
			enable: in std_logic;
			result: out std_logic_vector(15 downto 0)
		);
	end component;
	
	component andgate is
		port (
			dataa, datab: in std_logic_vector(15 downto 0);
			enable: in std_logic;
			result: out std_logic_vector(15 downto 0)
		);
	end component;
	
	component xorgate is
		port (
			dataa, datab: in std_logic_vector(15 downto 0);
			enable: in std_logic;
			result: out std_logic_vector(15 downto 0)
		);
	end component;
	
	component parity_bit_calculator is
		port (
			data: in std_logic_vector(15 downto 0);
			pout: out std_logic
		);
	end component;
	
	component zero_controller is
		port (
			data: in std_logic_vector(15 downto 0);
			zrout: out std_logic
		);
	end component;
begin
	yreg: lpm_ff
		generic map (
			LPM_WIDTH => 16
		)
		port map (
			data => data,
			clock => clock,
			enable => yin,
			aclr => aclr,
			q => y
		);
		
	zinadd_inv <= not(zinadd);
		
	decoder: lpm_decode
		generic map (
			LPM_WIDTH => 4,
			LPM_DECODES => 16
		)
		port map (
			data => ir,
			enable => zinadd_inv,
			eq => enable
		);
		
	add_sub_dir <= enable(0) or enable(8) or enable(11) or zinadd;
	add_sub_ena <= enable(0) or enable(5) or enable(7) or enable(8) or enable(9) or enable(10) or enable(11) or zinadd;
	add_sub_cin <= enable(5) or enable(7) or enable(8) or enable(11);
		
	addsub: add_sub
		port map (
			dataa => y,
			datab => data,
			cin => add_sub_cin,
			dir => add_sub_dir,
			enable => add_sub_ena,
			result => result,
			cout => cout,
			overflow => overflow
		);
		
	orgt: orgate
		port map (
			dataa => y,
			datab => data,
			enable => enable(1),
			result => result
		);
		
	andg: andgate
		port map (
			dataa => y,
			datab => data,
			enable => enable(4),
			result => result
		);
		
	xorg: xorgate
		port map (
			dataa => y,
			datab => data,
			enable => enable(6),
			result => result
		);
		
	pbc: parity_bit_calculator
		port map (
			data => result,
			pout => parity
		);
		
	zrc: zero_controller
		port map (
			data => result,
			zrout => zero
		);
		
	sign <= result(15);
		
	s_zin <= zin or zinadd;
		
	zreg: lpm_ff
		generic map (
			LPM_WIDTH => 16
		)
		port map (
			data => result,
			clock => clock,
			enable => s_zin,
			aclr => aclr,
			q => z
		);
		
	tristate: for i in 0 to 15 generate
		data(i) <= z(i) when zout='1' else 'Z';
	end generate tristate;
	
end arith_logic;