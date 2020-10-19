library ieee;
use ieee.std_logic_1164.all;

entity vector_mul_tb is
end vector_mul_tb;

architecture arch of vector_mul_tb is

-- declare circuit as component
component vector_mul is
port(
	clk: in std_logic;
	areset: in std_logic;
	valid: in std_logic;
	input: in std_logic;
	output: out std_logic
);
end component;

-- declaring input signals
signal clk : std_logic := '0';
signal areset: std_logic := '0';
signal valid:  std_logic := '0';
signal input: std_logic := '0';

-- declaring output signals
signal output: std_logic;

-- declare time constant
constant clk_period : time := 100 ps;

begin

-- port mapping of component
uut : vector_mul port map(
	clk => clk,
	areset => areset,
	valid => valid,
	input => input,
	output => output
); 

-- clock process
clk_process: process
	begin
	clk <= '0';
	wait for clk_period/2;
	clk <= '1';
	wait for clk_period/2;
end process;

-- testing process
test_process: process
	begin
	-- reset circuit
	areset <= '1';
	wait for clk_period/2;
	areset <= '0';
	wait for clk_period/2;
	
	-- insert 4 inputs for A with some valid testing in-between (non-generic!)
	
	-- 1. insert valid '1'
	valid <= '1';
	input <= '1';
	wait for clk_period;
	
	-- insert non-valid '0'
	valid <= '0';
	input <= '0';
	wait for clk_period;
	
	-- 2. insert valid '1'
	valid <= '1';
	input <= '1';
	wait for clk_period;
	
	-- 3. insert valid '1'
	valid <= '1';
	input <= '1';
	wait for clk_period;
	
	-- 4. insert valid '1'
	valid <= '1';
	input <= '1';
	wait for clk_period;
	
	-- ramA should now contain: "1 1 1 1 "!
	
	-- result in ramR needs to be "1 0"!
	wait;
end process;

end arch;