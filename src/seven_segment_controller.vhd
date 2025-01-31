LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY seven_segment_controller IS
    PORT (
        digit1: IN INTEGER;
        digit2: IN INTEGER;
        segment_out_1: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        segment_out_2: OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END seven_segment_controller;

ARCHITECTURE seven_segment_controller OF seven_segment_controller IS
BEGIN
    
	PROCESS(digit1)
	BEGIN
		CASE digit1 IS
			when 0 => segment_out_1 <= NOT "0111111";
			when 1 => segment_out_1 <= NOT "0000110";
			when 2 => segment_out_1 <= NOT "1011011";
			when 3 => segment_out_1 <= NOT "1001111";
			when 4 => segment_out_1 <= NOT "1100110";
			when 5 => segment_out_1 <= NOT "1101101";
			when 6 => segment_out_1 <= NOT "1111101";
			when 7 => segment_out_1 <= NOT "0000111";
			when 8 => segment_out_1 <= NOT "1111111";
			when 9 => segment_out_1 <= NOT "1101111";
			when others => segment_out_1 <= NOT "0000000"; -- Default: turn off all segments
		END CASE;
	END PROCESS;


	PROCESS(digit2)
	BEGIN
		CASE digit2 IS
			when 0 => segment_out_2 <= NOT "0111111";
			when 1 => segment_out_2 <= NOT "0000110";
			when 2 => segment_out_2 <= NOT "1011011";
			when 3 => segment_out_2 <= NOT "1001111";
			when 4 => segment_out_2 <= NOT "1100110";
			when 5 => segment_out_2 <= NOT "1101101";
			when 6 => segment_out_2 <= NOT "1111101";
			when 7 => segment_out_2 <= NOT "0000111";
			when 8 => segment_out_2 <= NOT "1111111";
			when 9 => segment_out_2 <= NOT "1101111";
			when others => segment_out_2 <= NOT "0000000"; -- Default: turn off all segments
		END CASE;
	END PROCESS;
	 
END seven_segment_controller;

