LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY work;
USE work.constants.ALL;

-- Shape Generator Entity
ENTITY shape_generator IS
    GENERIC (
		  	constant defined_shapes : defined_shapes_type := (
				((0, 4), (0, 5), (1, 4), (1, 5)),  -- O - Square
				((0, 3), (0, 4), (0, 5), (0, 6)),  -- I
				((0, 3), (1, 3), (1, 4), (1, 5)),  -- J
				((1, 3), (1, 4), (1, 5), (0, 5)),  -- L reversed
				((1, 3), (0, 4), (1, 4), (0, 5)),  -- Z
				((0, 3), (0, 4), (1, 4), (1, 5)),  -- S
				((1, 3), (0, 4), (1, 4), (1, 5))   -- T
			);
			
			constant defined_shapes_number : integer := 7
    );
    PORT (
        game_clk: IN STD_LOGIC;
        active_shape: OUT shape_type;
        shape_counter: BUFFER INTEGER RANGE 0 TO 6
    );
END shape_generator;

architecture shape_generator of shape_generator is
begin
	process(game_clk)
		variable temp_active_shape : shape_type := (others => (others => 0));
		variable temp_shape_counter : integer range 0 to 6 := 0;
	begin

		if game_clk'EVENT AND game_clk='1' then
		
			temp_shape_counter := shape_counter;
			temp_active_shape := defined_shapes(temp_shape_counter);
			
			if temp_shape_counter = defined_shapes_number - 1 then
				temp_shape_counter := 0;  -- Reset to 0 after the last shape
			else
				temp_shape_counter := temp_shape_counter + 1;  -- Increment shape_counter
			end if;
			
			active_shape <= temp_active_shape;
			shape_counter <= temp_shape_counter;

		end if;
	end process;
	 
end shape_generator;