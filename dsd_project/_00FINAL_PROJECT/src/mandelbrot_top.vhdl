--=============================================================================
-- @file mandelbrot_top.vhdl
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
-- mandelbrot_top
--
-- @brief This file specifies the toplevel of the pong game with the Mandelbrot
-- to generate the background. For lab 8, the final lab.
--
--=============================================================================

--=============================================================================
-- ENTITY DECLARATION FOR MANDELBROT_TOP
--=============================================================================
ENTITY mandelbrot_top IS
  PORT (
    CLK125xCI : IN std_logic;
    RSTxRI    : IN std_logic;

    -- Button inputs
    LeftxSI  : IN std_logic;
    RightxSI : IN std_logic;

    -- Timing outputs
    HSxSO : OUT std_logic;
    VSxSO : OUT std_logic;

    -- Data/color output
    RedxSO   : OUT std_logic_vector(COLOR_BW - 1 DOWNTO 0);
    GreenxSO : OUT std_logic_vector(COLOR_BW - 1 DOWNTO 0);
    BluexSO  : OUT std_logic_vector(COLOR_BW - 1 DOWNTO 0)
    );
END mandelbrot_top;


--=============================================================================
-- ARCHITECTURE DECLARATION
--=============================================================================
ARCHITECTURE rtl OF mandelbrot_top IS

--=============================================================================
-- SIGNAL (COMBINATIONAL) DECLARATIONS
--=============================================================================;

  -- clk_wiz_0
  SIGNAL CLK75xC : std_logic;

  -- blk_mem_gen_0
  SIGNAL WrAddrAxD : std_logic_vector(MEM_ADDR_BW - 1 DOWNTO 0);
  SIGNAL RdAddrBxD : std_logic_vector(MEM_ADDR_BW - 1 DOWNTO 0);
  SIGNAL ENAxS     : std_logic;
  SIGNAL WEAxS     : std_logic_vector(0 DOWNTO 0);
  SIGNAL ENBxS     : std_logic;
  SIGNAL DINAxD    : std_logic_vector(MEM_DATA_BW - 1 DOWNTO 0);
  SIGNAL DOUTBxD   : std_logic_vector(MEM_DATA_BW - 1 DOWNTO 0);

  SIGNAL BGRedxS   : std_logic_vector(COLOR_BW - 1 DOWNTO 0);  -- Background colors from the memory
  SIGNAL BGGreenxS : std_logic_vector(COLOR_BW - 1 DOWNTO 0);
  SIGNAL BGBluexS  : std_logic_vector(COLOR_BW - 1 DOWNTO 0);

  -- vga_controller
  SIGNAL RedxS   : std_logic_vector(COLOR_BW - 1 DOWNTO 0);  -- Color to VGA controller
  SIGNAL GreenxS : std_logic_vector(COLOR_BW - 1 DOWNTO 0);
  SIGNAL BluexS  : std_logic_vector(COLOR_BW - 1 DOWNTO 0);

  SIGNAL XCoordxD : unsigned(COORD_BW - 1 DOWNTO 0);  -- Coordinates from VGA controller
  SIGNAL YCoordxD : unsigned(COORD_BW - 1 DOWNTO 0);

  SIGNAL VSEdgexS : std_logic;  -- If 1, row counter resets (new frame). HIGH for 1 CC, when vertical sync starts)

  -- pong_fsm
  SIGNAL BallXxD  : unsigned(COORD_BW - 1 DOWNTO 0);  -- Coordinates of ball and plate
  SIGNAL BallYxD  : unsigned(COORD_BW - 1 DOWNTO 0);
  SIGNAL PlateXxD : unsigned(COORD_BW - 1 DOWNTO 0);

  -- mandelbrot
  SIGNAL MandelbrotWExS             : std_logic;  -- If 1, Mandelbrot writes
  SIGNAL MandelbrotXxD              : unsigned(COORD_BW - 1 DOWNTO 0);
  SIGNAL MandelbrotYxD              : unsigned(COORD_BW - 1 DOWNTO 0);
  SIGNAL MandelbrotITERxD           : unsigned(MEM_DATA_BW - 1 DOWNTO 0);  -- Iteration number from Mandelbrot (chooses colour)
  --SIGNAL XCoordxD             : unsigned(COORD_BW - 1 DOWNTO 0);
  --SIGNAL YCoordxD             : unsigned(COORD_BW - 1 DOWNTO 0);
  SIGNAL YCoordxDMultipliedxD       : unsigned(MEM_ADDR_BW -1 DOWNTO 0);  -- YCoordxD * HS_DISPLAY
  SIGNAL YCoordShrunkxD             : unsigned(COORD_BW-1 DOWNTO 0);  -- divided by four
  SIGNAL XCoordShrunk               : unsigned(COORD_BW -1 DOWNTO 0);  -- divided by four
  SIGNAL YMandelCoordxDMultipliedxD : unsigned(MEM_ADDR_BW -1 DOWNTO 0);  -- YCoordxD * HS_DISPLAY

  SIGNAL ResetFramexS  : std_logic;
  SIGNAL NextFramexS   : std_logic;
  SIGNAL FramCounterxD : unsigned(8-1 DOWNTO 0);  -- frame counter
--=============================================================================
-- COMPONENT DECLARATIONS
--=============================================================================
  COMPONENT clk_wiz_0 IS
    PORT (
      clk_out1 : OUT std_logic;
      reset    : IN  std_logic;
      locked   : OUT std_logic;
      clk_in1  : IN  std_logic
      );
  END COMPONENT clk_wiz_0;

  COMPONENT blk_mem_gen_0
    PORT (
      clka  : IN std_logic;
      ena   : IN std_logic;
      wea   : IN std_logic_vector(0 DOWNTO 0);
      addra : IN std_logic_vector(15 DOWNTO 0);
      dina  : IN std_logic_vector(11 DOWNTO 0);

      clkb  : IN  std_logic;
      enb   : IN  std_logic;
      addrb : IN  std_logic_vector(15 DOWNTO 0);
      doutb : OUT std_logic_vector(11 DOWNTO 0)
      );
  END COMPONENT;

  COMPONENT vga_controller IS
    PORT (
      CLKxCI : IN std_logic;
      RSTxRI : IN std_logic;

      -- Data/color input
      RedxSI   : IN std_logic_vector(COLOR_BW - 1 DOWNTO 0);
      GreenxSI : IN std_logic_vector(COLOR_BW - 1 DOWNTO 0);
      BluexSI  : IN std_logic_vector(COLOR_BW - 1 DOWNTO 0);

      -- Coordinate output
      XCoordxDO : OUT unsigned(COORD_BW - 1 DOWNTO 0);
      YCoordxDO : OUT unsigned(COORD_BW - 1 DOWNTO 0);

      -- Timing output
      HSxSO : OUT std_logic;
      VSxSO : OUT std_logic;

      VSEdgexSO : OUT std_logic;

      -- Data/color output
      RedxSO   : OUT std_logic_vector(COLOR_BW - 1 DOWNTO 0);
      GreenxSO : OUT std_logic_vector(COLOR_BW - 1 DOWNTO 0);
      BluexSO  : OUT std_logic_vector(COLOR_BW - 1 DOWNTO 0)
      );
  END COMPONENT vga_controller;

  COMPONENT pong_fsm IS
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
  END COMPONENT pong_fsm;

  COMPONENT mandelbrot IS
    PORT (
      CLKxCI        : IN std_logic;
      RSTxRI        : IN std_logic;
      ResetFramexSI : IN std_logic;
      NextFramexSI  : IN std_logic;

      WExSO   : OUT std_logic;
      XxDO    : OUT unsigned(COORD_BW - 1 DOWNTO 0);
      YxDO    : OUT unsigned(COORD_BW - 1 DOWNTO 0);
      ITERxDO : OUT unsigned(MEM_DATA_BW - 1 DOWNTO 0)
      );
  END COMPONENT mandelbrot;

--=============================================================================
-- ARCHITECTURE BEGIN
--=============================================================================
BEGIN

--=============================================================================
-- COMPONENT INSTANTIATIONS
--=============================================================================
  i_clk_wiz_0 : clk_wiz_0
    PORT MAP (
      clk_out1 => CLK75xC,
      reset    => RSTxRI,
      locked   => OPEN,
      clk_in1  => CLK125xCI
      );

  i_blk_mem_gen_0 : blk_mem_gen_0
    PORT MAP (
      clka  => CLK75xC,
      ena   => ENAxS,
      wea   => WEAxS,
      addra => WrAddrAxD,
      dina  => DINAxD,

      clkb  => CLK75xC,
      enb   => ENBxS,
      addrb => RdAddrBxD,
      doutb => DOUTBxD
      );

  i_vga_controller : vga_controller
    PORT MAP (
      CLKxCI => CLK75xC,
      RSTxRI => RSTxRI,

      RedxSI   => RedxS,
      GreenxSI => GreenxS,
      BluexSI  => BluexS,

      HSxSO => HSxSO,
      VSxSO => VSxSO,

      VSEdgexSO => VSEdgexS,

      XCoordxDO => XCoordxD,
      YCoordxDO => YCoordxD,

      RedxSO   => RedxSO,
      GreenxSO => GreenxSO,
      BluexSO  => BluexSO
      );

  i_pong_fsm : pong_fsm
    PORT MAP (
      CLKxCI => CLK75xC,
      RSTxRI => RSTxRI,

      RightxSI => RightxSI,
      LeftxSI  => LeftxSI,

      VgaXxDI => XCoordxD,
      VgaYxDI => YCoordxD,

      VSEdgexSI => VSEdgexS,

      BallXxDO  => BallXxD,
      BallYxDO  => BallYxD,
      PlateXxDO => PlateXxD
      );

  i_mandelbrot : mandelbrot
    PORT MAP (
      CLKxCI => CLK75xC,
      RSTxRI => RSTxRI,

      ResetFramexSI => ResetFramexS,
      NextFramexSI  => NextFramexS,

      WExSO   => MandelbrotWExS,
      XxDO    => MandelbrotXxD,
      YxDO    => MandelbrotYxD,
      ITERxDO => MandelbrotITERxD
      );

--=============================================================================
-- MEMORY SIGNAL MAPPING
--=============================================================================

-- Port A
  ENAxS <= MandelbrotWExS;
  WEAxS <= (OTHERS => MandelbrotWExS);


  YMandelCoordxDMultipliedxD <= MandelbrotYxD(8-1 DOWNTO 0)&"00000000";  -- lsl 8

  WrAddrAxD <= std_logic_vector(YMandelCoordxDMultipliedxD + MandelbrotXxD);
  DINAxD    <= "000000000000"WHEN MandelbrotITERxD = MAX_ITER ELSE
            std_logic_vector(
              MandelbrotITERxD(3*COLOR_BW-4 DOWNTO 2*COLOR_BW-2)&'0'&
              MandelbrotITERxD(2*COLOR_BW-3 DOWNTO COLOR_BW-1)&'0'&
              MandelbrotITERxD(COLOR_BW-2 DOWNTO 0)&'0'
              );

-- Port B
  ENBxS                <= '1';
  YCoordShrunkxD       <= "00"&YCoordxD(COORD_BW-1 DOWNTO 2);       -- get MSBs
  YCoordxDMultipliedxD <= YCoordShrunkxD(8-1 DOWNTO 0)&"00000000";  -- lsl 8
  XCoordShrunk         <= "00"& XcoordxD(COORD_BW-1 DOWNTO 2);      -- get MSBs

  RdAddrBxD <= std_logic_vector(YCoordxDMultipliedxD + XcoordShrunk);

  BGRedxS   <= DOUTBxD(3 * COLOR_BW - 1 DOWNTO 2 * COLOR_BW);
  BGGreenxS <= DOUTBxD(2 * COLOR_BW - 1 DOWNTO 1 * COLOR_BW);
  BGBluexS  <= DOUTBxD(1 * COLOR_BW - 1 DOWNTO 0 * COLOR_BW);



--=============================================================================
-- SPRITE SIGNAL MAPPING
--=============================================================================


  --actually write colors to vga
  -- purpose: select BG or sprite 
  -- type   : combinational
  -- inputs : all
  -- outputs: VGA colors (RedxS, GreenxS, BluexS)
  SpriteLogic : PROCESS (ALL) IS
  BEGIN  -- PROCESS SpriteLogic
    --BG as default
    RedxS   <= BGRedxS;
    GreenxS <= BGGreenxS;
    BluexS  <= BGBluexS;

    -- ball logic
    IF XCoordxD < BallXxD+BALL_WIDTH AND XCoordxD >= BallXxD AND YCoordxD < BallYxD+BALL_HEIGHT AND YCoordxD >= BallYxD THEN
      RedxS   <= (OTHERS => '1');
      GreenxS <= (OTHERS => '1');
      BluexS  <= (OTHERS => '1');
    END IF;
    IF YCoordxD > VS_DISPLAY-PLATE_HEIGHT AND XCoordxD < PlateXxD+PLATE_WIDTH AND XCoordxD >= PlateXxD THEN
      RedxS   <= (OTHERS => '1');
      GreenxS <= (OTHERS => '1');
      BluexS  <= (OTHERS => '1');
    END IF;

  END PROCESS SpriteLogic;





  -- purpose: count frames (max 10)
  -- type   : sequential
  -- inputs : CLK75xC, RSTxRI
  newframecounter : PROCESS (CLK75xC, RSTxRI) IS
  BEGIN  -- PROCESS newframecounter
    IF RSTxRI = '1' THEN                -- asynchronous reset (active high)
      FramCounterxD <= (OTHERS => '0');
    ELSIF CLK75xC'event AND CLK75xC = '1' THEN  -- rising clock edge
      IF VSEdgexS = '1' THEN
        IF FramCounterxD = 10 THEN
          FramCounterxD <= (OTHERS => '0');
        ELSE
          FramCounterxD <= FramCounterxD+1;
        END IF;
      END IF;
    END IF;
  END PROCESS newframecounter;
  --frame new and rst
--  ResetFramexS <= '1' WHEN LeftxSI = '1' AND RightxSI = '1' ELSE
--                  '0';
  ResetFramexS <= '0';
  NextFramexS  <= '1' WHEN FramCounterxD = 10 AND VSEdgexS = '1' ELSE '0';


END rtl;
--=============================================================================
-- ARCHITECTURE END
--=============================================================================
