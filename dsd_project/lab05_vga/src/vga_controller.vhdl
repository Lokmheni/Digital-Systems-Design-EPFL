--=============================================================================
-- @file vga_controller.vhdl
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
-- vga_controller
--
-- @brief This file specifies a VGA controller circuit
--
--=============================================================================

--=============================================================================
-- ENTITY DECLARATION FOR VGA_CONTROLLER
--=============================================================================
ENTITY vga_controller IS
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

    -- Data/color output
    RedxSO   : OUT std_logic_vector(COLOR_BW - 1 DOWNTO 0);
    GreenxSO : OUT std_logic_vector(COLOR_BW - 1 DOWNTO 0);
    BluexSO  : OUT std_logic_vector(COLOR_BW - 1 DOWNTO 0)
    );
END vga_controller;

--=============================================================================
-- ARCHITECTURE DECLARATION
--=============================================================================
ARCHITECTURE rtl OF vga_controller IS

  -- TODO: Implement your own code here
  SIGNAL XcounterxD       : unsigned(COORD_BW DOWNTO 0);  -- Counter_value (physical x coordinate incl porch and pulse)
  SIGNAL YcounterxD       : unsigned(COORD_BW DOWNTO 0);  -- Counter_value for y (physical)
  SIGNAL CntEnXxS       : std_logic;  -- Enable physical counter X
  SIGNAL CntEnYxS       : std_logic;  -- Enable physical counter Y
  SIGNAL CntMaxXxD        : unsigned(COORD_BW DOWNTO 0);  -- max value of counter x
  SIGNAL CntMaxYxD        : unsigned(COORD_BW DOWNTO 0);  -- max value of counter y
  SIGNAL CountXOverflowxS : std_logic;  -- Phys X counter overflow
  SIGNAL CountYOverflowxS : std_logic;  -- Phys Y Counter overflow

  SIGNAL validRegionxD : std_logic;     -- Is output color valid?

--=============================================================================
-- ARCHITECTURE BEGIN
--=============================================================================
BEGIN





  -- overflow values:
  CntMaxXxD <= to_unsigned(HS_DISPLAY + HS_FRONT_PORCH + HS_PULSE + HS_BACK_PORCH, CntMaxXxD'length);
  CntMaxYxD <= to_unsigned(VS_DISPLAY + VS_FRONT_PORCH + VS_PULSE + VS_BACK_PORCH, CntMaxYxD'length);



  -- purpose: Counters
  -- type   : sequential
  -- inputs : CLKxCI, RSTxRI, CntEnXxS, CntEnYxS,CntMaxXxD, CntMaxYxD
  -- outputs: overflow
  CounterRegisters : PROCESS (CLKxCI, RSTxRI) IS
  BEGIN  -- PROCESS CounterRegisters
    --DEFAULT
    XcounterxD       <= XcounterxD;
    YcounterxD       <= YcounterxD;
    CountXOverflowxS <= '0';
    CountYOverflowxS <= '0';

    --RESET
    IF RSTxRI = '1' THEN                -- asynchronous reset (active high)
      XcounterxD <= (OTHERS => '0');
      YcounterxD <= (OTHERS => '0');
    ELSIF CLKxCI'event AND CLKxCI = '1' THEN  -- rising clock edge
      --COUNTERS
      --Count X
      IF CntEnXxS = '1' THEN
        XcounterxD <= XcounterxD +1 WHEN XcounterxD+1 < CntMaxXxD ELSE
                      (OTHERS => '0');
        CountXOverflowxS <= '0' WHEN XcounterxD+1 < CntMaxXxD ELSE
                            '1';

      END IF;

      -- count Y
      IF CntEnYxS = '1' THEN
        YcounterxD <= YcounterxD+1 WHEN YcounterxD+1 < CntMaxXxD ELSE
                      (OTHERS => '0');
        CountYOverflowxS <= '0' WHEN YcounterxD+1 < CntMaxXxD ELSE
                            '1';

      END IF;


    END IF;
  END PROCESS CounterRegisters;




  --Counter Enable and other logic:
  CntEnXxS <= '1';
  CntEnYxS <= CountXOverflowxS;


  --output
  HSxSO <= CountXOverflowxS;
  VSxSO <= CountYOverflowxS;

  XCoordxDO <= XcounterxD - (HS_FRONT_PORCH + HS_PULSE);
  YCoordxDO <= YcounterxD - (VS_FRONT_PORCH + VS_PULSE);

 validRegionxD <='1' WHEN XcounterxD > HS_FRONT_PORCH + HS_PULSE
            AND XcounterxD < HS_FRONT_PORCH+HS_PULSE + HS_DISPLAY
            AND YcounterxD > VS_FRONT_PORCH + VS_PULSE
            AND YcounterxD < VS_FRONT_PORCH + VS_PULSE + VS_DISPLAY ELSE
            '0';

  RedxSO <= RedxSI WHEN validRegionxD='1' ELSE
            (OTHERS => '0');
  GreenxSO <= GreenxSI WHEN validRegionxD='1' ELSE
              (OTHERS => '0');
  BluexSO <= BluexSI WHEN validRegionxD='1' ELSE
             (OTHERS => '0');





  --TODO REGISTERS FOR OUTPUT VARIABLES

END rtl;
--=============================================================================
-- ARCHITECTURE END
--=============================================================================
