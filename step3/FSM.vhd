library ieee;
use ieee.std_logic_1164.all;

entity FSM is
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
end FSM;

architecture arch of FSM is

-- declaring states
-- RESET -> startup state and resetting
-- WRITEA -> writing the vector A
-- CALC -> calculating state (reading A and H, calculating result and writing result into R)
-- READR -> reading the result of vector R
type state_type is (RESET, WRITEA, CALC, READR);
signal state: state_type;

begin

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