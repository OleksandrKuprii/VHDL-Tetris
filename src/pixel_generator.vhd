LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
LIBRARY work;
use work.constants.all;

-- Pixel Generator Entity
ENTITY pixel_generator IS
	 GENERIC (
		Hc: INTEGER := 784;
		Vc: INTEGER := 515
	);
    PORT (
		  pixel_clk: IN STD_LOGIC;
        dena: IN STD_LOGIC;
        Hactive: IN STD_LOGIC;
        Vactive: IN STD_LOGIC;
		Vsync : IN STD_LOGIC;
        visible_grid: IN array_2d_type;
        R: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        G: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        B: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END pixel_generator;

architecture pixel_generator of pixel_generator is
	signal pixel_counter: INTEGER RANGE 0 TO 262143;
	signal flag : std_logic;
begin	

	PROCESS(pixel_clk, Vsync)
	BEGIN
		IF (Vsync='0') THEN
			  pixel_counter <= 0;
			  flag <= '0';
		 ELSIF (pixel_clk'EVENT AND pixel_clk = '1') THEN
		 
		   IF (dena='1' AND flag='1') THEN
				pixel_counter <= pixel_counter + 1;
			END IF;
			
			flag <= NOT flag;
		END IF;
	END PROCESS;
	
	
	PROCESS (dena, Vactive, Hactive, pixel_counter)
		 VARIABLE line_counter: INTEGER RANGE 0 TO Vc; 
		 VARIABLE x: integer range 0 to Vc;
		 variable y: integer range 0 to Hc;
		 
		 variable grid_row : row_type;
		 variable grid_item : std_logic;
	BEGIN 

		y := pixel_counter / 640;
		x := pixel_counter mod 320;
		
		R <= (OTHERS => '0');
		G <= (OTHERS => '0');
		B <= (OTHERS => '0');
		
		-- OUTLINE BORDERS
		IF ((((x >= 110 AND x <= 111) OR (x >= 204 AND x <= 205)) AND (y >= 21 AND y <= 206)) OR (((y >= 21 AND y <= 22) OR (y >= 205 AND y <= 206)) AND (x >= 110 AND x <= 205))) THEN
			R <= (OTHERS => '1');
			G <= (OTHERS => '1');
			B <= (OTHERS => '1');
		else
			for j in visible_grid'range loop
				grid_row := visible_grid(j);
				
				if y >= 24 + j * 9 and y <= 31 + j * 9 then
				
					for i in grid_row'range loop
						grid_item := grid_row(i);
						
						if grid_item = '1' then
							if x >= 113 + i * 9 and x <= 120 + i * 9 then
								R <= (OTHERS => '1');
								G <= (OTHERS => '1');
								B <= (OTHERS => '1');
							end if;
						end if;
					end loop;
				end if;
			end loop;
		END IF;
	END PROCESS;

end pixel_generator;