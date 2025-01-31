LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

package constants is 

	constant ROWS : integer := 20;
	constant COLS : integer := 10;

	type row_type is array (0 to COLS-1) of std_logic;
	type array_2d_type is array (0 to ROWS-1) of row_type;
		
	type coor_type is array (0 to 1) of integer;
	type shape_type is array (0 to 3) of coor_type;
	type defined_shapes_type is array (0 to 6) of shape_type; 
	
--	constant defined_shapes : defined_shapes_type := (
--		((0, 4), (0, 5), (1, 4), (1, 5)),  -- O - Square
--		((0, 3), (0, 4), (0, 5), (0, 6)),  -- I
--		((0, 3), (1, 3), (1, 4), (1, 5)),  -- J
--		((1, 3), (1, 4), (1, 5), (0, 5)),  -- L reversed
--		((1, 3), (0, 4), (1, 4), (0, 5)),  -- Z
--		((0, 3), (0, 4), (1, 4), (1, 5)),  -- S
--		((1, 3), (0, 4), (1, 4), (1, 5))   -- T
--	);
--	
--	constant defined_shapes_number : integer := 7;
	
end package;