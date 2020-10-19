library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity romH is
generic(
	address_length: natural := 3
);
port(
	clk: in std_logic;
	rom_enable: in std_logic;
	address: in std_logic_vector((address_length - 1) downto 0);
	data_output: out std_logic
);
end romH;

architecture arch of romH is
	type rom_type is array (0 to (2**(address_length) -1)) of std_logic;
	
	-- set the data on each adress to some value
	constant mem: rom_type:=
	(
		'1', '0', '1', '1',
		'0', '1', '0', '1'
	);
begin

process(clk) is
begin
	if(rising_edge(clk) and rom_enable = '1') then
		data_output <= mem(conv_integer(unsigned(address)));
	end if;
end process;

end arch;