LIBRARY ieee;
USE ieee.std_logic_1164.all;

----------------------------------------------------------
-- ENTITY DECLARATIONS
----------------------------------------------------------

-- VGA Controller Entity
ENTITY vga_controller IS
    GENERIC (
        Ha: INTEGER := 96;
        Hb: INTEGER := 144;
        Hc: INTEGER := 784;
        Hd: INTEGER := 800;
        Va: INTEGER := 2;
        Vb: INTEGER := 35;
        Vc: INTEGER := 515;
        Vd: INTEGER := 525
    );
    PORT (
        clk: IN STD_LOGIC;
        pixel_clk: BUFFER STD_LOGIC;
        Hsync: BUFFER STD_LOGIC;
        Vsync: BUFFER STD_LOGIC;
        Hactive: BUFFER STD_LOGIC;
        Vactive: BUFFER STD_LOGIC;
        dena: OUT STD_LOGIC;
		nblanck, nsync : OUT STD_LOGIC
    );
END vga_controller;


architecture vga_controller of vga_controller is
begin

	-------------------------------------------------------
	--Part 1: CONTROL GENERATOR
	-------------------------------------------------------
	--Static signals for DACs:
	nblanck <= '1'; --no direct blanking
	nsync <= '0'; --no sync on green
	
	--Create pixel clock (50MHz->25MHz):
	PROCESS (clk)
	BEGIN
		IF (clk'EVENT AND clk='1') THEN
			pixel_clk <= NOT pixel_clk;
		END IF;
	END PROCESS;
	
	--Horizontal signals generation:
	PROCESS (pixel_clk)
		VARIABLE Hcount: INTEGER RANGE 0 TO Hd;
	BEGIN
		IF (pixel_clk'EVENT AND pixel_clk='1') THEN
			
			Hcount := Hcount + 1;
			IF (Hcount=Ha) THEN
				Hsync <= '1';
			ELSIF (Hcount=Hb) THEN
				Hactive <= '1';
			ELSIF (Hcount=Hc) THEN
				Hactive <= '0';
			ELSIF (Hcount=Hd) THEN
				Hsync <= '0';
				Hcount := 0;
			END IF;
		END IF;
	END PROCESS;
	
	--Vertical signals generation:
	PROCESS (Hsync)
		VARIABLE Vcount: INTEGER RANGE 0 TO Vd;
	BEGIN
		IF (Hsync'EVENT AND Hsync='0') THEN
			Vcount := Vcount + 1;
			IF (Vcount=Va) THEN
				Vsync <= '1';
			ELSIF (Vcount=Vb) THEN
				Vactive <= '1';
			ELSIF (Vcount=Vc) THEN
				Vactive <= '0';
			ELSIF (Vcount=Vd) THEN
				Vsync <= '0';
				Vcount := 0;
			END IF;
		END IF;
	END PROCESS;
	
	
	---Display enable generation:
	dena <= Hactive AND Vactive;

end vga_controller;