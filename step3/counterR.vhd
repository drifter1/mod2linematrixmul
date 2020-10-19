library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity counterR is Generic(
	count_width : natural := 1
);
port(
	clk: in std_logic;
	reset: in std_logic;
	count_enable: in std_logic;
	count: out std_logic_vector(count_width-1 downto 0)
);
end counterR;

architecture arch of counterR is
	signal temp_count : std_logic_vector(count_width-1 downto 0);
begin

process(clk)
	begin
	if(rising_edge(clk)) then
		if(reset = '1') then
			temp_count <= (others => '0');
		elsif (count_enable = '1') then
			temp_count <= temp_count + 1;
		end if;
	end if;
end process;

count <= temp_count;

end arch;
	
	