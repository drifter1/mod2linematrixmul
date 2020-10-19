library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity ramA is
generic(
	address_length: natural := 2
);
port(
	clk: in std_logic;
	rw_enable: in std_logic;
	mem_enable: in std_logic;
	address: in std_logic_vector((address_length - 1) downto 0);
	data_input: in std_logic;
	data_output: out std_logic
);
end ramA;

architecture arch of ramA is
	type ram_type is array (0 to (2**(address_length) -1)) of std_logic;
	signal ram: ram_type;
	signal temp_address: std_logic_vector((address_length - 1) downto 0);
begin

process(clk) is
begin
    if rising_edge(clk)and mem_enable = '1' then
		if(rw_enable = '0') then
			temp_address <= address;
	    elsif (rw_enable = '1') then
		    ram(conv_integer(unsigned(address))) <= data_input;
		end if;	
	end if;
	
end process;

data_output <= ram(conv_integer(unsigned(temp_address)));

end arch;