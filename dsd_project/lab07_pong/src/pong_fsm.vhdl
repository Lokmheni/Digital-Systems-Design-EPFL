--=============================================================================
-- @file pong_fsm.vhdl
--=============================================================================
-- Standard library
LIBRARY ieee;
-- Standard packages
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
-- Packages
LIBRARY work;
USE work.pong_pkg.ALL;

--=============================================================================
--
-- pong_fsm
--
-- @brief This file specifies a basic circuit for the pong game. Note that coordinates are counted
-- from the upper left corner of the screen.
--
--=============================================================================

--=============================================================================
-- ENTITY DECLARATION FOR PONG_FSM
--=============================================================================
ENTITY pong_fsm IS
  PORT (
    CLKxCI : IN std_logic;
    RSTxRI : IN std_logic;

    -- Controls from push buttons
    LeftxSI  : IN std_logic;
    RightxSI : IN std_logic;

    -- Coordinate from VGA
    VgaXxDI : IN unsigned(COORD_BW - 1 DOWNTO 0);
    VgaYxDI : IN unsigned(COORD_BW - 1 DOWNTO 0);

    -- Signals from video interface to synchronize (HIGH for 1 CC, when vertical sync starts)
    VSEdgexSI : IN std_logic;

    -- Ball and plate coordinates
    BallXxDO  : OUT unsigned(COORD_BW - 1 DOWNTO 0);
    BallYxDO  : OUT unsigned(COORD_BW - 1 DOWNTO 0);
    PlateXxDO : OUT unsigned(COORD_BW - 1 DOWNTO 0)
    );
END pong_fsm;

--=============================================================================
-- ARCHITECTURE DECLARATION
--=============================================================================
ARCHITECTURE rtl OF pong_fsm IS

-- TODO: Implement your code here

--=============================================================================
-- ARCHITECTURE BEGIN
--=============================================================================
BEGIN

-- TODO: Implement your code here

END rtl;
--=============================================================================
-- ARCHITECTURE END
--=============================================================================
