
--=============================================================================
-- @file dsd_prj_pkg.vhdl
--=============================================================================
-- Standard library
LIBRARY ieee;
-- Standard packages
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

--=============================================================================
--
-- dsd_prj_pkg
--
-- @brief This file specifies the parameters used for the VGA controller, pong and mandelbrot circuits
--
-- The parameters are given here http://tinyvga.com/vga-timing/1024x768@70Hz
-- with a more elaborate explanation at https://projectf.io/posts/video-timings-vga-720p-1080p/
--=============================================================================

PACKAGE dsd_prj_pkg IS

-------------------------------------------------------------------------------
-- Lab 5 parameters
-------------------------------------------------------------------------------

  -- Bitwidths for screen coordinate and colors
  CONSTANT COLOR_BW : natural := 4;
  CONSTANT COORD_BW : natural := 12;

  -- Horizontal timing parameters
  CONSTANT HS_DISPLAY     : natural   := 1024;
  CONSTANT HS_FRONT_PORCH : natural   := 24;
  CONSTANT HS_PULSE       : natural   := 136;
  CONSTANT HS_BACK_PORCH  : natural   := 144;
  CONSTANT HS_POLARITY    : std_logic := '0';

  -- Vertical timing parameters
  CONSTANT VS_DISPLAY     : natural   := 768;
  CONSTANT VS_FRONT_PORCH : natural   := 3;
  CONSTANT VS_PULSE       : natural   := 6;
  CONSTANT VS_BACK_PORCH  : natural   := 29;
  CONSTANT VS_POLARITY    : std_logic := '0';

-------------------------------------------------------------------------------
-- Lab 6 parameters
-------------------------------------------------------------------------------

  -- Memory parameters
  CONSTANT MEM_ADDR_BW : natural := 16;
  CONSTANT MEM_DATA_BW : natural := 12;  -- 3 * COLOR_BW

-------------------------------------------------------------------------------
-- Lab 7 parameters
-------------------------------------------------------------------------------

  -- Pong parameters (in pixels)
  CONSTANT BALL_WIDTH   : natural := 10;
  CONSTANT BALL_HEIGHT  : natural := 10;
  CONSTANT BALL_STEP_X  : natural := 2;
  CONSTANT BALL_STEP_Y  : natural := 2;
  CONSTANT PLATE_WIDTH  : natural := 70;
  CONSTANT PLATE_HEIGHT : natural := 10;
  CONSTANT PLATE_STEP_X : natural := 40;

-------------------------------------------------------------------------------
-- Lab 8 parameters
-------------------------------------------------------------------------------

  -- Mandelbrot parameters
  CONSTANT N_INT  : natural := 2;       -- # Integer bits (minus sig-bit)
  CONSTANT N_FRAC : natural := 15;      -- # Fractional bits
  CONSTANT N_BITS : natural := N_INT + N_FRAC;

  CONSTANT ITER_LIM : natural := 2**(2 + N_FRAC);  -- Represents 2^2 in Q3.15
  CONSTANT MAX_ITER : natural := 2000;  -- Maximum iteration number before stopping

  CONSTANT C_RE_0 : signed(N_BITS + 1 - 1 DOWNTO 0) := to_signed(-2 * (2**N_FRAC), N_BITS + 1);  -- Q3.15
  CONSTANT C_IM_0 : signed(N_BITS + 1 - 1 DOWNTO 0) := to_signed(-1 * (2**N_FRAC), N_BITS + 1);  -- Q3.15

  -- REVISIT: What is the starting point supposed to be?
  CONSTANT C_RE_INC : signed(N_BITS + 1 - 1 DOWNTO 0) := to_signed(3 * 2**(-10 + N_FRAC)/4, N_BITS + 1);  -- Q3.15
  CONSTANT C_IM_INC : signed(N_BITS + 1 - 1 DOWNTO 0) := to_signed(5 * 2**(-11 + N_FRAC)/4, N_BITS + 1);  -- Q3.15



  --zoom params
  CONSTANT C_RE_0_INCSTEP   : signed(N_BITS DOWNTO 0) := to_signed(0, N_BITS+1);  -- q3.15
  CONSTANT C_IM_0_INCSTEP   : signed(N_BITS DOWNTO 0) := to_signed(0, N_BITS+1);  -- q3.15
  CONSTANT C_RE_INC_INCSTEP : signed(N_BITS DOWNTO 0) := to_signed(-1, N_BITS+1);  -- q3.15
  CONSTANT C_IM_INC_INCSTEP : signed(N_BITS DOWNTO 0) := to_signed(-1, N_BITS+1);  -- Q3.15

END PACKAGE dsd_prj_pkg;
