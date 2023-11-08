library ieee;
use ieee.std_logic_1164.all;

entity constants is
	port (
		zeroout, intinstout, intaddrout: in std_logic;
		data: inout std_logic_vector(15 downto 0)
	);
end constants;

architecture const of constants is
	constant intr_address: std_logic_vector(15 downto 0) := x"3f00";
begin
	data <= (others => '0') when zeroout = '1' else (others => 'Z');
	data <= "1101011100100000" when intinstout = '1' else (others => 'Z');
	data <= intr_address when intaddrout = '1' else (others => 'Z');
end const;