library ieee;
use ieee.std_logic_1164.all;

entity FSM is
port(
	clk: in std_logic;
	areset: in std_logic;
	valid: in std_logic;
	input: in std_logic;
	output: out std_logic
);
end FSM;

architecture arch of FSM is

-- declaring states
-- RESET -> startup state and resetting
-- WRITEA -> writing the vector A
-- CALC -> calculating state (reading A and H, calculating result and writing result into R)
-- READR -> reading the result from vector R
type state_type is (RESET, WRITEA, CALC, READR);
signal state: state_type;

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


-- declaring signals
signal count_addressA : std_logic_vector(2-1 downto 0); -- signal to connect counterA with ramA (non-generic!)
signal count_addressH : std_logic_vector(3-1 downto 0); -- signal to connect counterH with romH (non-generic!)
signal count_addressR : std_logic_vector(1-1 downto 0); -- signal to connect counterR with ramR (non-generic!)

signal rw_enableA, mem_enableA, count_resetA, count_enableA : std_logic; --control signals for ramA and counterA
signal rom_enableH, count_resetH, count_enableH : std_logic; -- control signals for romH and counterH
signal accumulator_reset : std_logic; -- control signal of accumulator
signal rw_enableR, mem_enableR, count_resetR, count_enableR : std_logic; --control signals for ramR and counterR

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
	data_output => output -- main output of the circuit
);

U7: counterR port map(
	clk => clk,
	reset => count_resetR,
	count_enable => count_enableR,
	count => count_addressR
);

-- processes
state_transition: process(clk, areset)
begin
	-- asynchronous reset
	if(areset = '1') then
		state <= RESET;
	-- state transitioning
	elsif(rising_edge(clk)) then
		case state is
			when RESET =>
				if(areset = '0') then
					state <= WRITEA;
				end if;
			
			when WRITEA =>
				if(count_addressA = "11") then -- after the last item of A!
					state <= CALC;
				end if;
			
			when CALC =>
				if(count_addressH = "111") then -- after the last item of H!
					state <= READR;	
				end if;
			
			when READR =>
				if(count_addressR = "1") then -- after the last item of R!
					state <= RESET;
				end if;
		end case;
	end if;

end process;

output_process: process(state, valid, count_addressA)
-- the valid signal changes the behavior of the 'WRITEA' state
-- the count_addressA signal changes the behavior of the 'CALC' state
begin
	case state is
		when RESET =>
		    -- disable ramA
			rw_enableA <= '1';
			mem_enableA <= '0';
			
			-- reset counterA
			count_resetA <= '1';
			count_enableA <= '0';
			
			-- disable romH
			rom_enableH <= '0';
			
			-- reset counterH
			count_resetH <= '1';
			count_enableH <= '0';
			
			-- reset accumulator
			accumulator_reset <= '1';
			
			-- disable ramR
			rw_enableR <= '1';
			mem_enableR <= '0';
			
			-- reset counterR
			count_resetR <= '1';
			count_enableR <= '0';
		
		when WRITEA =>
			-- set ramA into reading mode
			rw_enableA <= '1';
			
			-- make sure that the counters are not in reset anymore
			count_resetA <= '0';
			count_resetH <= '0';
			count_resetR <= '0';
			
			-- keep accumulator in reset to not get 'U' signal
			accumulator_reset <= '1';
			
			-- H and R are not needed (romH managed separately)
			count_enableH <= '0';
			count_enableR <= '0';
			rw_enableR <= '1';
			mem_enableR <= '0';
			
			-- input depends on the valid signal
			if(valid = '1') then -- valid input
				mem_enableA <= '1';
				count_enableA <= '1';
			else -- non-valid input
				mem_enableA <= '0';
				count_enableA <= '0';
			end if;
			
			if(count_addressA /= "11") then -- manage romH
				rom_enableH <= '1';
			else
				rom_enableH <= '0';
			end if;
		
		when CALC =>
			if(count_addressA /= "11") then -- only calculating
				-- enable ramA for reading
				rw_enableA <= '0';
				mem_enableA <= '1';
				
				-- enable counterA
				count_enableA <= '1';
				count_resetA <= '0';
				
				--enable romH for reading
				rom_enableH <= '1';
							
				-- enable counterH
				count_enableH <= '1';
				count_resetH <= '0';
				
				-- make sure accumulator is not in reset anymore
				accumulator_reset <= '0';
				
				-- make sure  ramR and counterR are disabled
				rw_enableR <= '1';
				mem_enableR <= '0';
				count_resetR <= '0';
				count_enableR <= '0';
				
			else -- calculating storing result
				-- keep ramA reading
				rw_enableA <= '0';
				mem_enableA <= '1';
				
				-- keep counterA active
				count_enableA <= '1';
				count_resetA <= '0';
				
				--keep romH reading
				rom_enableH <= '1';
				
				-- keep counterH active
				count_enableH <= '1';
				count_resetH <= '0';
				
				-- reset accumulator (that will happen in the next cycle)
				accumulator_reset <= '1';
				
				-- enable ramR for writing (so that it writes in the next cycle)
				rw_enableR <= '1';
				mem_enableR <= '1';
				
				-- enable counterR (so that it increments in the next cycle)
				count_resetR <= '0';
				count_enableR <= '1';
			end if;
		
		when READR =>
			-- disable ramA
			mem_enableA <= '0';
			rw_enableA <= '0';
			
			-- disable counterA
			count_enableA <= '0';
			count_resetA <= '0';
			
			-- disable romH
			rom_enableH <= '0';
			
			-- disable counterH
			count_enableH <= '0';
			count_resetH <= '0';

			-- reset accumulator
			accumulator_reset <= '1';
			
			-- enable ramR for reading
			rw_enableR <= '0';
			mem_enableR <= '1';
			
			-- enable counterR
			count_resetR <= '0';
			count_enableR <= '1';	
			
	end case;
end process;

end arch;