library ieee;
use ieee.std_logic_1164.all;
LIBRARY altera;
USE altera.altera_primitives_components.all;

entity memory is
	port (
		clock, aclr, marin, ramin, ramout: in std_logic;
		data: inout std_logic_vector(15 downto 0)
	);
end memory;

architecture mem of memory is
	-- 00
	component rom_16 IS
		PORT
		(
			aclr		: IN STD_LOGIC  := '0';
			address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
			addressstall_a		: IN STD_LOGIC  := '0';
			clken		: IN STD_LOGIC  := '1';
			clock		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END component;
	
	-- 01
	component ram IS
		PORT
		(
			aclr		: IN STD_LOGIC  := '0';
			address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
			addressstall_a		: IN STD_LOGIC  := '0';
			clken		: IN STD_LOGIC  := '1';
			clock		: IN STD_LOGIC  := '1';
			data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			wren		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END component;
	
	-- 1
	component vram IS
		PORT
		(
			aclr		: IN STD_LOGIC  := '0';
			address		: IN STD_LOGIC_VECTOR (14 DOWNTO 0);
			addressstall_a		: IN STD_LOGIC  := '0';
			clken		: IN STD_LOGIC  := '1';
			clock		: IN STD_LOGIC  := '1';
			data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			wren		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END component;
	
	signal marin_inv, aclr_inv, romen, ramen, vramen: std_logic;
	signal s_romen, s_ramen, s_vramen, sorromen, sorramen, sorvramen: std_logic;
	signal s_rom, s_ram, s_vram: std_logic_vector(15 downto 0);
begin
	marin_inv <= not(marin);
	aclr_inv <= not(aclr);
	
	romen <= data(15) nor data(14);
	romenff: dffe
		port map (
			prn => '1',
			clrn => aclr_inv,
			ena => marin,
			clk => clock,
			d => romen,
			q => s_romen
		);
	sorromen <= romen or s_romen;
	program_memory: rom_16
		port map (
			aclr => aclr,
			address => data(13 downto 0),
			addressstall_a => marin_inv,
			clken => sorromen,
			clock => clock,
			q => s_rom
		);
	
	ramen <= not(data(15)) and data(14);
	ramenff: dffe
		port map (
			prn => '1',
			clrn => aclr_inv,
			ena => marin,
			clk => clock,
			d => ramen,
			q => s_ramen
		);
	sorramen <= ramen or s_ramen;
	system_memory: ram
		port map (
			aclr => aclr,
			address => data(13 downto 0),
			addressstall_a => marin_inv,
			clken => sorramen,
			clock => clock,
			data => data,
			wren => ramin,
			q => s_ram
		);
		
	vramen <= data(15);
	vramenff: dffe
		port map (
			prn => '1',
			clrn => aclr_inv,
			ena => marin,
			clk => clock,
			d => vramen,
			q => s_vramen
		);
	sorvramen <= vramen or s_vramen;
	video_memory: vram
		port map (
			aclr => aclr,
			address => data(14 downto 0),
			addressstall_a => marin_inv,
			clken => sorvramen,
			clock => clock,
			data => data,
			wren => ramin,
			q => s_vram
		);
		
	tristate: for i in 0 to 15 generate
		data(i) <= s_rom(i) when ramout='1' and s_romen='1' else 'Z';
		data(i) <= s_ram(i) when ramout='1' and s_ramen='1' else 'Z';
		data(i) <= s_vram(i) when ramout='1' and s_vramen='1' else 'Z';
	end generate tristate;
end mem;