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
type state_type is (RESET, WRITEA);
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

-- declaring signals
signal count_addressA : std_logic_vector(1 downto 0); -- signal to connect counterA with ramA (non-generic!)

signal rw_enableA, mem_enableA, count_resetA, count_enableA : std_logic; --control signals for ramA and counterA

begin

-- port mapping of components
U1: ramA port map(
	clk => clk,
	rw_enable => rw_enableA,
	mem_enable => mem_enableA,
	address => count_addressA,
	data_input => input,
	data_output => output -- main output of system
);

U2: counterA port map(
	clk => clk,
	reset => count_resetA,
	count_enable => count_enableA,
	count => count_addressA
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
					state <= RESET; -- will be changed
				end if;
			
		end case;
	end if;

end process;

output_process: process(state, valid) -- the valid signal changes the behavior of the 'WRITEA' state
begin
	case state is
		when RESET =>
		    -- disable ramA
			rw_enableA <= '1';
			mem_enableA <= '0';
			
			-- reset counterA
			count_resetA <= '1';
			count_enableA <= '0';
			
		when WRITEA =>
			-- set ramA into reading mode
			rw_enableA <= '1';
			
			-- make sure that nothing is in reset anymore
			count_resetA <= '0';
			
			-- input depends on the valid signal
			if(valid = '1') then -- valid input
				mem_enableA <= '1';
				count_enableA <= '1';
			else -- non-valid input
				mem_enableA <= '0';
				count_enableA <= '0';
			end if;		
	end case;
end process;

end arch;