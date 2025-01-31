LIBRARY ieee;
USE ieee.std_logic_1164.all;
library work;
use work.constants.all;

-- Define the top-level entity
ENTITY top_level IS
    PORT (
        clk: IN STD_LOGIC;
        left_move_button: IN STD_LOGIC;
        right_move_button: IN STD_LOGIC;
        rotate_button: IN STD_LOGIC;
        pause_switch : IN STD_LOGIC;
        reset_button : IN STD_LOGIC
        pixel_clk: BUFFER STD_LOGIC;
        R: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        G: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        B: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        Hsync, Vsync: BUFFER STD_LOGIC;
        segment_out_1: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        segment_out_2: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        nblanck, nsync : OUT STD_LOGIC;
        game_over : OUT STD_LOGIC;
        pause_active : OUT STD_LOGIC
    );
END top_level;

ARCHITECTURE structure OF top_level IS

    -- Signals for interconnection
    SIGNAL game_clk: STD_LOGIC;
    SIGNAL Hactive, Vactive, dena: STD_LOGIC;
    SIGNAL active_shape: SHAPE_TYPE;  -- Assuming you have defined SHAPE_TYPE somewhere
	SIGNAL grid: ARRAY_2D_TYPE := (others => (others => '0')) ;
	SIGNAL updated_grid: ARRAY_2D_TYPE;
    SIGNAL visible_grid: ARRAY_2D_TYPE;
	SIGNAL update_grid: std_logic;
	 
	SIGNAL score : INTEGER;
	 
	SIGNAL digit1 : INTEGER;
	SIGNAL digit2 : INTEGER;

BEGIN
    -- Instantiate VGA Controller
    vga_ctrl: ENTITY work.vga_controller
        GENERIC MAP (
            Ha => 96, Hb => 144, Hc => 784, Hd => 800,
            Va => 2, Vb => 35, Vc => 515, Vd => 525
        )
        PORT MAP (
            clk => clk,
            pixel_clk => pixel_clk,
            Hsync => Hsync,
            Vsync => Vsync,
            Hactive => Hactive,
            Vactive => Vactive,
            dena => dena,
            nblanck => nblanck,
            nsync => nsync
        );

    -- Instantiate Game Clock
    game_clk_gen: ENTITY work.game_clock
        GENERIC MAP (
            CLOCK_FREQ => 25000000
        )
        PORT MAP (
            clk => clk,
            game_clk => game_clk
        );

    -- Instantiate Shape Generator
    game_control: ENTITY work.game_controller
        GENERIC MAP (
            defined_shapes_number => 7
        )
        PORT MAP (
            clk => clk,
            left_move_button => left_move_button,
            right_move_button => right_move_button,
            rotate_button => rotate_button,
            grid => grid,
            updated_grid => updated_grid,
            active_shape => active_shape,
            score => score,
            game_over => game_over,
            pause_switch => pause_switch,
            reset_button => reset_button
        );

    -- Instantiate Visible Grid Controller
    grid_ctrl: ENTITY work.visible_grid_controller
        PORT MAP (
            grid => updated_grid,
            active_shape => active_shape,
            visible_grid => visible_grid
        );

    -- Instantiate Pixel Generator
    pixel_gen: ENTITY work.pixel_generator
        PORT MAP (
			pixel_clk => pixel_clk,
            dena => dena,
            Hactive => Hactive,
            Vactive => Vactive,
			Vsync => Vsync,
            visible_grid => visible_grid,
            R => R,
            G => G,
            B => B
        );

	digit1 <= score mod 10;
	digit2 <= score / 10;

    -- Instantiate Seven Segment Display Controller
    seg_display_ctrl: ENTITY work.seven_segment_controller
        PORT MAP (
            digit1 => digit1,
            digit2 => digit2,
            segment_out_1 => segment_out_1,
            segment_out_2 => segment_out_2
        );
		  
	pause_active <= pause_switch;
END structure;
