library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity accumulator is
port(
	clk: in std_logic;
	reset: in std_logic;
	input1: in std_logic;
	input2: in std_logic;
	output: out std_logic
);
end accumulator;

architecture arch of accumulator is

signal reg: std_logic; -- register
signal and_gate: std_logic; -- to make the code clearer

begin

process(clk)
	begin
	if(rising_edge(clk)) then
		if(reset = '1') then
			reg <= '0';
		else
			reg <= and_gate XOR reg;
		end if;
	end if;
end process;

and_gate <= input1 AND input2;
output <= and_gate XOR reg;

end arch;