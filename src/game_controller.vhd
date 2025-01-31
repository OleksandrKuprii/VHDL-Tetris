LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY work;
USE work.constants.ALL;

-- Shape Generator Entity
ENTITY game_controller IS
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
		clk: IN STD_LOGIC;
		left_move_button: IN STD_LOGIC;
		right_move_button: IN STD_LOGIC;
		rotate_button: IN STD_LOGIC;
		active_shape: BUFFER shape_type;
		grid: BUFFER array_2d_type;
		updated_grid: BUFFER array_2d_type;
		score: BUFFER INTEGER;
		game_over: BUFFER STD_LOGIC;
		pause_switch: IN STD_LOGIC;
		reset_button : IN STD_LOGIC
    );
END game_controller;

architecture game_controller of game_controller is
	signal game_clk: std_logic;
	constant CLOCK_FREQ: INTEGER := 8500000; -- 12500000
	signal counter : integer range 0 to CLOCK_FREQ - 1 := 0;
	
	constant FULL_ROW : row_type := (others => '1');

	SIGNAL shape_counter: INTEGER RANGE 0 TO 6;

	signal last_left_button_state : std_logic := '0';
	signal last_right_button_state: std_logic := '0';
	signal reset_button_state: std_logic := '0';
	signal reset_state: std_logic := '0';
	
	function move_shape(shape: shape_type; direction: integer) return shape_type is
		variable new_shape: shape_type;
	begin
		new_shape := shape;

		for i in shape'range loop
			if direction = 0 then  -- DOWN
				new_shape(i)(0) := new_shape(i)(0) + 1;
			elsif direction = 1 then  -- LEFT
				new_shape(i)(1) := new_shape(i)(1) - 1;
			elsif direction = 2 then -- RIGHT
				new_shape(i)(1) := new_shape(i)(1) + 1;
			end if;
		end loop;
		
		return new_shape;
	end function move_shape;
	
	function rotate_shape(shape: shape_type) return shape_type is
		variable new_shape: shape_type;
		variable pivot_x, pivot_y : integer;
	begin
		new_shape := shape;
		pivot_x := shape(0)(0);
		pivot_y := shape(0)(1);
		
		for i in shape'range loop
			new_shape(i)(0) := pivot_x + (new_shape(i)(1) - pivot_y);
			new_shape(i)(1) := pivot_y - (new_shape(i)(0) - pivot_x);
		end loop;
		
		return new_shape;
	end function rotate_shape;
	
	function check_borders(shape: shape_type) return std_logic is
	begin
		for i in shape'range loop
			if grid(shape(i)(0))(shape(i)(1)) = '1' or shape(i)(1) = -1 or shape(i)(1) = 10 or shape(i)(0) = 20 then
				return '0';
			end if;
		end loop;
		
		return '1';
	end function check_borders;
	
begin

	process(clk, pause_switch)
		variable new_shape: shape_type;
		variable shape_moved: std_logic := '0';
		variable drop_levels_number : integer := 0;
	begin 
	
		if clk'EVENT AND clk='1' then
		
			if pause_switch = '0' and game_over = '0' then
				
				if counter = CLOCK_FREQ - 1 then
					counter <= 0;
					game_clk <= not game_clk;  -- Toggle the signal

					if game_clk = '1' then 
						if reset_state = '1' then
							reset_state <= '0';
						end if;
						if reset_state = '0' then
						
							-- Check if the grid line is complete
							for i in 19 downto 1 loop					
								if updated_grid(i) = FULL_ROW then
									drop_levels_number := drop_levels_number + 1;
								end if;
								
								-- Overwrite each line of the grid
								if (drop_levels_number > 0) then
									updated_grid(i) <= updated_grid(i - drop_levels_number);
								end if;
							end loop;
							
							if drop_levels_number > 0 then
								-- Update the score
								score <= score + drop_levels_number;
								drop_levels_number := 0;
								
							else
					
								updated_grid <= grid;
							
								-- Check if the active shape is empty
								if active_shape(0)(0) = active_shape(1)(0) and active_shape(0)(1) = active_shape(1)(1) then
									new_shape := defined_shapes(shape_counter);
									
									for i in new_shape'range loop
										if grid(new_shape(i)(0))(new_shape(i)(1)) = '1' then
											game_over <= '1';
										end if;
									end loop;
									
									active_shape <= new_shape;
									
									if shape_counter = defined_shapes_number - 1 then
										 shape_counter <= 0;  -- Reset to 0 after the last shape
									else
										 shape_counter <= shape_counter + 1;  -- Increment shape_counter
									end if;
									
								else
								-- Active shape is not empty
								
									-- Calculate the new shape when the active moves down
									new_shape := move_shape(active_shape, 0);
									
									-- Check if the shape overlaps with the grid or reached the bottom
									if check_borders(new_shape) = '1' then
										-- Change the value of the active shape to be moved down
										active_shape <= new_shape;
										shape_moved := '1';
										
									else
										-- Attach the currently active shape to the grid
										for i in active_shape'range loop
											updated_grid(active_shape(i)(0))(active_shape(i)(1)) <= '1';
											 
											-- Reset the active shape
											active_shape(i) <= (others => 0);
										end loop;
									end if;

								end if;
								
							end if;
						end if;
--					else 
--						reset_state <= '0';
					end if;
					
				else
					
					counter <= counter + 1;
				end if;
			end if;
		end if;
		
		
		if (clk'event and clk = '1') then
			if pause_switch = '0' then
				if (shape_moved = '0') then
					if (left_move_button = '1' and last_left_button_state = '0') then
					
						new_shape := move_shape(active_shape, 1);
						
						-- Check if we can move left
						if check_borders(new_shape) = '1' then
							active_shape <= new_shape;
						end if;
						
					elsif (right_move_button = '1' and last_right_button_state = '0') then
					
						new_shape := move_shape(active_shape, 2);
						
						if check_borders(new_shape) = '1' then
							active_shape <= new_shape;
						end if;

					end if;
					
					last_right_button_state <= right_move_button;
					last_left_button_state <= left_move_button;
				else 
					shape_moved := '0';
				end if;
				
				if (reset_button = '1' and reset_button_state = '0') then
					updated_grid <= (others => (others => '0'));
					active_shape <= (others => (others => 0));
					score <= 0;
					reset_state <= '1';
					game_over <= '0';
				end if;
				reset_button_state <= reset_button;
			end if;
		end if;
		
	end process;
	
	
	process(game_clk) 
	begin
		if game_clk'event and game_clk = '0' then
			grid <= updated_grid;
		end if;
	end process;

end game_controller;