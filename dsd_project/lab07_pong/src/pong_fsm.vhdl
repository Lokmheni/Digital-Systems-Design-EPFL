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
USE work.dsd_prj_pkg.ALL;

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
  SIGNAL GameActivexSN        : std_logic;  -- Active high,Game in progress='1'
  SIGNAL GameActivexSP        : std_logic;  -- Active high,Game in progress='1'
  SIGNAL BallDirectionUpxSN   : std_logic;  -- '1' if ball is moving up (y coord decreasing)
  SIGNAL BallDirectionUpxSP   : std_logic;  -- '1' if ball is moving up (y coord decreasing)
  SIGNAL BallDirectionLeftxSN : std_logic;  -- '1' if ball is moving left (x coord decreasing)
  SIGNAL BallDirectionLeftxSP : std_logic;  -- '1' if ball is moving left (x coord decreasing)
  SIGNAL BallPosXxD           : unsigned(COORD_BW-1 DOWNTO 0);  -- X position of the ball counter
  SIGNAL BallPosYxD           : unsigned(COORD_BW-1 DOWNTO 0);  -- Y position OF the ball counter
  SIGNAL BarPoxXxD            : unsigned(COORD_BW-1 DOWNTO 0);  -- X position of the bar

  SIGNAL CntBallXEnxS : std_logic;      -- Count enable for ball x coordinate
  SIGNAL CntBallYEnxS : std_logic;      -- Count enable for ball y coordinate
  SIGNAL CntBarEnxS   : std_logic;      -- Count enable for Bar coordinate
  SIGNAL cntBarDirxS  : std_logic;  -- Count direction for Bar ('1' if bar is moving left, x coord decreasing)


  SIGNAL SetCntrs         : std_logic;  -- Enable set counters if '1'
  SIGNAL BallPosXSetValxD : unsigned(COORD_BW-1 DOWNTO 0);  -- Set value (x pos) to be written to counter if SetCntrs is high
  SIGNAL BallPosYSetValxD : unsigned(COORD_BW-1 DOWNTO 0);  -- Set value (y pos) to be written to y counter if SetCntrs is high


--=============================================================================
-- ARCHITECTURE BEGIN
--=============================================================================
BEGIN
--========
--Counters
--========
  -- purpose: Counter for x coordinate of ball (has enable, set, count direction)
  -- type   : sequential
  -- inputs : CLKxCI, RSTxRI, BallDirectionLeftxSP, CntBallXEnxS, SetCntrs
  -- outputs: BallPosXxD
  XCoordCounter : PROCESS (CLKxCI, RSTxRI) IS
  BEGIN  -- PROCESS XCoordCounter
    IF RSTxRI = '1' THEN                -- asynchronous reset (active high)
      BallPosXxD <= (OTHERS => '0');
    ELSIF CLKxCI'event AND CLKxCI = '1' THEN  -- rising clock edge
      IF CntBallXEnxS = '1' THEN        -- enable
        IF BallDirectionLeftxSP = '0' THEN    -- count up
          BallPosXxD <= BallPosXxD+1;
        ELSE
          BallPosXxD <= BallPosXxD-1;   -- count down
        END IF;
      END IF;
      --set cntr
      IF SetCntrs = '1' THEN
        BallPosXxD <= BallPosXSetValxD;
      END IF;
    END IF;
  END PROCESS XCoordCounter;


  -- purpose: Counter for y coordinate of ball
  -- type   : sequential
  -- inputs : CLKxCI, RSTxRI, BallDirectionUpxSP, CntBallYEnxS, SetCntrs
  -- outputs: BallPosYxD
  YcoordCounter : PROCESS (CLKxCI, RSTxRI) IS
  BEGIN  -- PROCESS YcoordCounter
    IF RSTxRI = '1' THEN                -- asynchronous reset (active high)
      BallPosYxD <= (OTHERS => '0');
    ELSIF CLKxCI'event AND CLKxCI = '1' THEN  -- rising clock edge
      IF CntBallYEnxS = '1' THEN
        IF BallDirectionUpxSN = '0' THEN
          BallPosYxD <= BallPosYxD+1;   --count up
        ELSE
          BallPosYxD <= BallPosYxD-1;   --count down
        END IF;
      END IF;
      IF SetCntrs = '1' THEN
        BallPosYxD <= BallPosYSetValxD;
      END IF;
    END IF;
  END PROCESS YcoordCounter;



  -- purpose: Counter for x coordinate of bar ( no set value )
  -- type   : sequential
  -- inputs : CLKxCI, RSTxRI, CntBarEnxS, cntBarDirxS
  -- outputs: BarPoxXxD
  BarPositionCounter : PROCESS (CLKxCI, RSTxRI) IS
  BEGIN  -- PROCESS BarPositionCounter
    IF RSTxRI = '1' THEN                -- asynchronous reset (active high)
      BarPoxXxD <= to_unsigned(HS_DISPLAY/2, COORD_BW);  -- reset to center of screen
    ELSIF CLKxCI'event AND CLKxCI = '1' THEN             -- rising clock edge
      IF CntBarEnxS = '1' THEN
        IF cntBarDirxS = '0' THEN
          BarPoxXxD <= BarPoxXxD+1;     --count up
        ELSE
          BarPoxXxD <= BarPoxXxD-1;     --count down
        END IF;
      END IF;
      -- no set value, bar stays at same position
    END IF;
  END PROCESS BarPositionCounter;


  --=================
  --signals and logic
  --=================
  -- Enable signals:
  CntBallXEnxS <= GameActivexSP;
  CntBallYEnxS <= GameActivexSP;
  CntBarEnxS <= '1' WHEN GameActivexSP='1' AND (LeftxSI='1' XOR RightxSI='1' );
  
                  

  


END rtl;
--=============================================================================
-- ARCHITECTURE END
--=============================================================================
