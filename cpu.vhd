library ieee;
use ieee.std_logic_1164.all;
LIBRARY lpm;
USE lpm.lpm_components.all;

entity cpu is
	port (
		clock, aclr, busy, intr: in std_logic;
		marin, ramin, ramout, inta, counterrst, input: out std_logic;
		data: inout std_logic_vector(15 downto 0);
		axo, bxo, cxo, dxo, flags: out std_logic_vector(15 downto 0);
		pcoutq, irout: out std_logic_vector(15 downto 0)
	);
end cpu;

architecture processor of cpu is
	component control_unit is
		port (
			clock, aclr, busy: in std_logic;
			ir: in std_logic_vector(15 downto 0);
			control: out std_logic_vector(47 downto 0);
			ucounterrst: out std_logic
		);
	end component;
	
	component program_counter is
		port (
			clock, aclr, cnt_en, pcin, pcout: in std_logic;
			data: inout std_logic_vector(15 downto 0);
			q: out std_logic_vector(15 downto 0)
		);
	end component;
	
	component reg is
		port (
			clock, aclr, regin, regout: in std_logic;
			q: out std_logic_vector(15 downto 0);
			data: inout std_logic_vector(15 downto 0)
		);
	end component;
	
	component alu is
		port (
			clock, aclr, yin, zin, zinadd, zout: in std_logic;
			ir: in std_logic_vector(3 downto 0);
			cout, parity, zero, sign, overflow: out std_logic;
			data: inout std_logic_vector(15 downto 0)
		);
	end component;
	
	component jump_controller is
		port (
			flags: in std_logic_vector(15 downto 0);
			ir: in std_logic_vector(3 downto 0);
			pcin, pcinun: in std_logic;
			jump_enable: out std_logic
		);
	end component;
	
	component flags_register is
		port (
			clock, aclr, zin, flagsin, flagsout: in std_logic;
			flags: in std_logic_vector(15 downto 0);
			q: out std_logic_vector(15 downto 0);
			data: inout std_logic_vector(15 downto 0)
		);
	end component;
	
	component constants is
		port (
			zeroout, intinstout, intaddrout: in std_logic;
			data: inout std_logic_vector(15 downto 0)
		);
	end component;
	
	signal control: std_logic_vector(47 downto 0);
	signal cnt_en, jump_enable, ucounterrst, intinstout: std_logic;
	signal ir, sflagsin, sflagsout: std_logic_vector(15 downto 0) := "0000000000000000";
	
	signal pcout, ir1out, ir2out, ir3out, s_ramout, zout, zeroout, tempout, portout, flagsout, reg0out, reg1out, intaddrout: std_logic;
	signal pcin, ir1in, ir2in, ir3in, s_marin, s_ramin, yin, zin, zinadd, tempin, pcinun, flagsin, reg0in, reg1in, halt: std_logic;
	signal regin, regout: std_logic_vector(7 downto 0);
begin
	intinstout <= ucounterrst and intr;
	
	pcin <= control(0);
	ir1in <= control(1) or intinstout;
	ir2in <= control(2);
	ir3in <= control(3);
	s_marin <= control(4);
	s_ramin <= control(5);
	yin <= control(6);
	zin <= control(7);
	zinadd <= control(8);
	halt <= control(9);
	tempin <= control(10);
	pcinun <= control(11);
	flagsin <= control(12);
	reg0in <= control(14);
	reg1in <= control(15);
	
	pcout <= control(16);
	ir1out <= control(17);
	ir2out <= control(18);
	ir3out <= control(19);
	intaddrout <= control(20);
	s_ramout <= control(21);
	zout <= control(23);
	zeroout <= control(25);
	tempout <= control(26);
	portout <= control(27);
	flagsout <= control(28);
	reg0out <= control(30);
	reg1out <= control(31);
	
	regctrlmap: for i in 0 to 7 generate
		regin(i) <= control(32 + i);
		regout(i) <= control(40 + i);
	end generate regctrlmap;
	
	cu: control_unit
		port map (
			clock => clock,
			aclr => aclr,
			busy => busy,
			ir => ir,
			control => control,
			ucounterrst => ucounterrst
		);

	cnt_en <= s_ramout and (ir1in or ir2in or ir3in);
	
	jc: jump_controller
		port map (
			flags => sflagsout,
			ir => ir(11 downto 8),
			pcin => pcin,
			pcinun => pcinun,
			jump_enable => jump_enable
		);
	
	pc: program_counter
		port map (
			clock => clock,
			aclr => aclr,
			cnt_en => cnt_en,
			pcin => jump_enable,
			pcout => pcout,
			data => data,
			q => pcoutq
		);
		
	ir1: reg
		port map (
			clock => clock,
			aclr => aclr,
			regin => ir1in,
			regout => ir1out,
			data => data,
			q => ir
		);
	
	ir2: reg
		port map (
			clock => clock,
			aclr => aclr,
			regin => ir2in,
			regout => ir2out,
			data => data
		);
		
	ir3: reg
		port map (
			clock => clock,
			aclr => aclr,
			regin => ir3in,
			regout => ir3out,
			data => data
		);
		
	arith_logic: alu
		port map (
			clock => clock,
			aclr => aclr,
			yin => yin,
			zin => zin,
			zinadd => zinadd,
			zout => zout,
			ir => ir(14 downto 11),
			data => data,
			cout => sflagsin(0),
			parity => sflagsin(2),
			zero => sflagsin(6),
			sign => sflagsin(7),
			overflow => sflagsin(11)
		);
		
	ax: reg
		port map (
			clock => clock,
			aclr => aclr,
			regin => regin(0),
			regout => regout(0),
			data => data,
			q => axo
		);
		
	cx: reg
		port map (
			clock => clock,
			aclr => aclr,
			regin => regin(1),
			regout => regout(1),
			data => data,
			q => cxo
		);
		
	dx: reg
		port map (
			clock => clock,
			aclr => aclr,
			regin => regin(2),
			regout => regout(2),
			data => data
		);
		
	bx: reg
		port map (
			clock => clock,
			aclr => aclr,
			regin => regin(3),
			regout => regout(3),
			data => data,
			q => bxo
		);
		
	sp: reg
		port map (
			clock => clock,
			aclr => aclr,
			regin => regin(4),
			regout => regout(4),
			data => data,
			q => dxo
		);
		
	bp: reg
		port map (
			clock => clock,
			aclr => aclr,
			regin => regin(5),
			regout => regout(5),
			data => data
		);
		
	si: reg
		port map (
			clock => clock,
			aclr => aclr,
			regin => regin(6),
			regout => regout(6),
			data => data
		);
		
	di: reg
		port map (
			clock => clock,
			aclr => aclr,
			regin => regin(7),
			regout => regout(7),
			data => data
		);
		
	tempreg: reg
		port map (
			clock => clock,
			aclr => aclr,
			regin => tempin,
			regout => tempout,
			data => data
		);
		
	flagsreg: flags_register
		port map (
			clock => clock,
			aclr => aclr,
			zin => zin,
			flagsin => flagsin,
			flagsout => flagsout,
			flags => sflagsin,
			q => sflagsout,
			data => data
		);
		
	const: constants
		port map (
			zeroout => zeroout,
			intinstout => intinstout,
			intaddrout => intaddrout,
			data => data
		);

	marin <= s_marin;
	ramin <= s_ramin;
	ramout <= s_ramout;
	inta <= intinstout;
	input <= portout;
	counterrst <= ucounterrst;
	
	flags <= sflagsout;
	irout <= ir;
end processor;