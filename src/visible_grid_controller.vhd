LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
LIBRARY work;
USE work.constants.all;

-- Visible Grid Controller Entity
ENTITY visible_grid_controller IS
    PORT (
        grid: IN array_2d_type;
        active_shape: IN shape_type;
        visible_grid: OUT array_2d_type
    );
END visible_grid_controller;

architecture visible_grid_controller of visible_grid_controller is
begin

	process(grid, active_shape)
	begin
	
		visible_grid <= grid;
		
		-- Check if the active shape is not empty
		if active_shape(0)(0) /= active_shape(1)(0) or active_shape(0)(1) /= active_shape(1)(1) then
		
			for i in 0 to active_shape'length - 1 loop
				visible_grid(active_shape(i)(0))(active_shape(i)(1)) <= '1';
			end loop;
		
		end if;
	
	end process;

end visible_grid_controller;