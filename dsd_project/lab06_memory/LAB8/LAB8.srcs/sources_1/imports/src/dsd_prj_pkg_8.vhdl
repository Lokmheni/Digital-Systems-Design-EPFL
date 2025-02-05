
--=============================================================================
-- @file dsd_prj_pkg.vhdl
--=============================================================================
-- Standard library
library ieee;
-- Standard packages
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--=============================================================================
--
-- dsd_prj_pkg
--
-- @brief This file specifies the parameters used for the VGA controller, pong and mandelbrot circuits
--
-- The parameters are given here http://tinyvga.com/vga-timing/1024x768@70Hz
-- with a more elaborate explanation at https://projectf.io/posts/video-timings-vga-720p-1080p/
--=============================================================================

package dsd_prj_pkg is

-------------------------------------------------------------------------------
-- Lab 5 parameters
-------------------------------------------------------------------------------

  -- Bitwidths for screen coordinate and colors
  constant COLOR_BW : natural := 4;
  constant COORD_BW : natural := 12;

  -- Horizontal timing parameters
  constant HS_DISPLAY     : natural   := 1024;
  constant HS_FRONT_PORCH : natural   := 24;
  constant HS_PULSE       : natural   := 136;
  constant HS_BACK_PORCH  : natural   := 144;
  constant HS_POLARITY    : std_logic := '0';

  -- Vertical timing parameters
  constant VS_DISPLAY     : natural   := 768;
  constant VS_FRONT_PORCH : natural   := 3;
  constant VS_PULSE       : natural   := 6;
  constant VS_BACK_PORCH  : natural   := 29;
  constant VS_POLARITY    : std_logic := '0';

-------------------------------------------------------------------------------
-- Lab 6 parameters
-------------------------------------------------------------------------------

  -- Memory parameters
  constant MEM_ADDR_BW : natural := 16;
  constant MEM_DATA_BW : natural := 12; -- 3 * COLOR_BW

-------------------------------------------------------------------------------
-- Lab 7 parameters
-------------------------------------------------------------------------------

  -- Pong parameters (in pixels)
  constant BALL_WIDTH   : natural := 10;
  constant BALL_HEIGHT  : natural := 10;
  constant BALL_STEP_X  : natural := 2;
  constant BALL_STEP_Y  : natural := 2;
  constant PLATE_WIDTH  : natural := 70;
  constant PLATE_HEIGHT : natural := 10;
  constant PLATE_STEP_X : natural := 40;

-------------------------------------------------------------------------------
-- Lab 8 parameters
-------------------------------------------------------------------------------

  -- Mandelbrot parameters
  constant N_INT  : natural := 2;   -- # Integer bits (minus sig-bit)
  constant N_FRAC : natural := 15;  -- # Fractional bits
  constant N_BITS : natural := N_INT + N_FRAC;

  constant ITER_LIM : natural := 2**(2 + N_FRAC); -- Represents 2^2 in Q3.15
  constant MAX_ITER : natural := 100;             -- Maximum iteration bumber before stopping

  constant C_RE_0 : signed(N_BITS + 1 - 1 downto 0) := to_signed(-2 * (2**N_FRAC), N_BITS + 1); -- Q3.15
  constant C_IM_0 : signed(N_BITS + 1 - 1 downto 0) := to_signed(-1 * (2**N_FRAC), N_BITS + 1); -- Q3.15

  -- REVISIT: What is the starting point supposed to be?
  constant C_RE_INC : signed(N_BITS + 1 - 1 downto 0) := to_signed(3 * 2**(-10 + N_FRAC), N_BITS + 1); -- Q3.15
  constant C_IM_INC : signed(N_BITS + 1 - 1 downto 0) := to_signed(5 * 2**(-11 + N_FRAC), N_BITS + 1); -- Q3.15

end package dsd_prj_pkg;
