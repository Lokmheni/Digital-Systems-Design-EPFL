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




  --output registers!!!
  SIGNAL RedxSOP    : std_logic_vector(COLOR_BW - 1 DOWNTO 0);
  SIGNAL GreenxSOP  : std_logic_vector(COLOR_BW - 1 DOWNTO 0);
  SIGNAL BluexSOP   : std_logic_vector(COLOR_BW - 1 DOWNTO 0);
  SIGNAL XCoordxDOP : unsigned(COORD_BW - 1 DOWNTO 0);
  SIGNAL XCoordxDON : unsigned(COORD_BW -1 DOWNTO 0);
  SIGNAL YCoordxDOP : unsigned(COORD_BW - 1 DOWNTO 0);
  SIGNAL YCoordxDON : unsigned(COORD_BW -1 DOWNTO 0);
  SIGNAL HSxSOP    : std_logic;
  SIGNAL HSxSON    : std_logic;
  SIGNAL VSxSOP     : std_logic;
  SIGNAL VSxSON : std_logic;
  SIGNAL RedxSON    : std_logic_vector(COLOR_BW - 1 DOWNTO 0);
  SIGNAL GreenxSON  : std_logic_vector(COLOR_BW - 1 DOWNTO 0);
  SIGNAL BluexSON   : std_logic_vector(COLOR_BW - 1 DOWNTO 0);

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





  --outputregisters

  -- purpose: Registers for storing output values
  -- type   : sequential
  -- inputs : CLKxCI, RSTxRI, RedxSON,GreenxSON,BluexSON,XCoordxDON,YCoordxDON,HSxSON,VSxSON
  -- outputs: same but x_OP
  outputregisters: PROCESS (CLKxCI, RSTxRI) IS
  BEGIN  -- PROCESS outputregisters
    IF RSTxRI = '1' THEN                -- asynchronous reset (active high)
      RedxSON<=(OTHERS => '0');
      GreenxSON<=(OTHERS => '0');
      BluexSON<=(OTHERS => '0');
      XCoordxDON<=(OTHERS => '0');
      YCoordxDON<=(OTHERS => '0');
      VSxSON<=(OTHERS => '0');
      HSxSON<=(OTHERS => '0');
    ELSIF CLKxCI'event AND CLKxCI = '1' THEN  -- rising clock edge
      
    END IF;
  END PROCESS outputregisters;

  

  --output
  HSxSON <= CountXOverflowxS;
  VSxSON <= CountYOverflowxS;

  XCoordxDON <= XcounterxD - (HS_FRONT_PORCH + HS_PULSE);
  YCoordxDON <= YcounterxD - (VS_FRONT_PORCH + VS_PULSE);

 validRegionxD <='1' WHEN XcounterxD > HS_FRONT_PORCH + HS_PULSE
            AND XcounterxD < HS_FRONT_PORCH+HS_PULSE + HS_DISPLAY
            AND YcounterxD > VS_FRONT_PORCH + VS_PULSE
            AND YcounterxD < VS_FRONT_PORCH + VS_PULSE + VS_DISPLAY ELSE
            '0';

  RedxSON <= RedxSI WHEN validRegionxD='1' ELSE
            (OTHERS => '0');
  GreenxSON <= GreenxSI WHEN validRegionxD='1' ELSE
              (OTHERS => '0');
  BluexSON <= BluexSI WHEN validRegionxD='1' ELSE
             (OTHERS => '0');



  

  

  

END rtl;
--=============================================================================
-- ARCHITECTURE END
--=============================================================================
