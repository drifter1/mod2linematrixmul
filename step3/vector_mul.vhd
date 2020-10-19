library ieee;
use ieee.std_logic_1164.all;

entity vector_mul is
port(
	clk: in std_logic;
	areset: in std_logic;
	valid: in std_logic;
	input: in std_logic;
	output: out std_logic
);
end vector_mul;

architecture arch of vector_mul is

-- components
component ramA is
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
end component;

component counterA is Generic(
	count_width : natural := 2
);
port(
	clk: in std_logic;
	reset: in std_logic;
	count_enable: in std_logic;
	count: out std_logic_vector(count_width-1 downto 0)
);
end component;

component romH is
generic(
	address_length: natural := 3
);
port(
	clk: in std_logic;
	rom_enable: in std_logic;
	address: in std_logic_vector((address_length - 1) downto 0);
	data_output: out std_logic
);
end component;

component counterH is Generic(
	count_width : natural := 3
);
port(
	clk: in std_logic;
	reset: in std_logic;
	count_enable: in std_logic;
	count: out std_logic_vector(count_width-1 downto 0)
);
end component;

component accumulator is
port(
	clk: in std_logic;
	reset: in std_logic;
	input1: in std_logic;
	input2: in std_logic;
	output: out std_logic
);
end component;

component ramR is
generic(
	address_length: natural := 1
);
port(
	clk: in std_logic;
	rw_enable: in std_logic;
	mem_enable: in std_logic;
	address: in std_logic_vector((address_length - 1) downto 0);
	data_input: in std_logic;
	data_output: out std_logic
);
end component;

component counterR is Generic(
	count_width : natural := 1
);
port(
	clk: in std_logic;
	reset: in std_logic;
	count_enable: in std_logic;
	count: out std_logic_vector(count_width-1 downto 0)
);
end component;

component FSM is
port(
	clk: in std_logic;
	areset: in std_logic;
	valid: in std_logic;
	-- addresses
	count_addressA : in std_logic_vector(1 downto 0); --(non-generic!)
	count_addressH : in std_logic_vector(2 downto 0); -- non-generic!)
	count_addressR : in std_logic_vector(0 downto 0); -- non-generic!)	
	-- control signals
	rw_enableA, mem_enableA : out std_logic; -- control signals for ramA
	count_resetA, count_enableA : out std_logic; -- control signals for counterA
	rom_enableH : out std_logic; -- control signal for romH
	count_resetH, count_enableH : out std_logic; -- control signals for counterH
	accumulator_reset : out std_logic; -- control signal for accumulator
	rw_enableR, mem_enableR : out std_logic; -- control signals for ramR
	count_resetR, count_enableR : out std_logic -- control signals for counterR
);
end component;

-- declaring signals
signal count_addressA : std_logic_vector(1 downto 0); -- signal to connect counterA with ramA (non-generic!)
signal count_addressH : std_logic_vector(2 downto 0); -- signal to connect counterH with romH (non-generic!)
signal count_addressR : std_logic_vector(0 downto 0); -- signal to connect counterR with ramR (non-generic!)

signal rw_enableA, mem_enableA,count_resetA, count_enableA : std_logic;
signal rom_enableH, count_resetH, count_enableH, accumulator_reset : std_logic;
signal rw_enableR, mem_enableR,count_resetR, count_enableR : std_logic;

signal output_A, output_H : std_logic; -- outputs of ramA and romH
signal output_accum : std_logic; -- output of accumulator to connect with ramR input

begin

-- port mapping of components
U1: ramA port map(
	clk => clk,
	rw_enable => rw_enableA,
	mem_enable => mem_enableA,
	address => count_addressA,
	data_input => input,
	data_output => output_A
);

U2: counterA port map(
	clk => clk,
	reset => count_resetA,
	count_enable => count_enableA,
	count => count_addressA
);

U3: romH port map(
	clk => clk,
	rom_enable => rom_enableH,
	address => count_addressH,
	data_output => output_H
);

U4: counterH port map(
	clk => clk,
	reset => count_resetH,
	count_enable => count_enableH,
	count => count_addressH
);

U5: accumulator port map(
	clk => clk,
	reset => accumulator_reset,
	input1 => output_A,
	input2 => output_H,
	output => output_accum
);

U6: ramR port map(
	clk => clk,
	rw_enable => rw_enableR,
	mem_enable => mem_enableR,
	address => count_addressR,
	data_input => output_accum,
	data_output => output -- main output of the circuit for testing
);

U7: counterR port map(
	clk => clk,
	reset => count_resetR,
	count_enable => count_enableR,
	count => count_addressR
);

U8: FSM port map(
	clk => clk,
	areset => areset,
	valid => valid,
	-- addresses
	count_addressA => count_addressA,
	count_addressH => count_addressH,
	count_addressR => count_addressR,
	-- control signals
	rw_enableA => rw_enableA,
	mem_enableA => mem_enableA,
	count_resetA => count_resetA,
	count_enableA => count_enableA, 
	rom_enableH => rom_enableH,
	count_resetH => count_resetH,
	count_enableH => count_enableH,
	accumulator_reset => accumulator_reset,
	rw_enableR => rw_enableR,
	mem_enableR => mem_enableR,
	count_resetR => count_resetR,
	count_enableR => count_enableR
);

end arch;