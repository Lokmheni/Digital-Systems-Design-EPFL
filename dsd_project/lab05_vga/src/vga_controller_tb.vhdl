--=============================================================================
-- @file vga_controller_tb.vhdl
--=============================================================================
-- Standard library
library ieee;
library std;
-- Standard packages
use std.env.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Packages
library work;
use work.dsd_prj_pkg.all;

--=============================================================================
--
-- vga_controller_tb
--
-- @brief This file specifies the testbench of the VGA controller
--
-- We verify the following:
--  * The width of the sync pulses
--  * The length of the horizontal line
--  * The duration of a frame
--
-- Note that until the first verticalical sync is observed, the measured length is
-- most likely not correct (but this is okay!).
--
-- We verify based on the number of clock cycles, but we also print the expected
-- and observed time in nanoseconds.
--
-- The testbench contains golden values.
--
-- For the timing parameters, see http://tinyvga.com/vga-timing/1024x768@70Hz
-- As these parameters use a negative polarity for the sync signals, we count the
-- duration from the falling-edge of the sync signals to their rising-edge
--=============================================================================

--=============================================================================
-- ENTITY DECLARATION FOR VGA_CONTROLLER_TB
--=============================================================================
entity vga_controller_tb is
end entity vga_controller_tb;

--=============================================================================
-- ARCHITECTURE DECLARATION
--=============================================================================
architecture tb of vga_controller_tb is

--=============================================================================
-- TYPE AND CONSTANT DECLARATIONS
--=============================================================================
  constant CLK_HIGH : time := 6.667 ns; -- Clock is 75 MHz, approximate with 6.667 ns, 74.996 MHz
  constant CLK_LOW  : time := 6.667 ns;
  constant CLK_PER  : time := CLK_LOW + CLK_HIGH;
  constant CLK_STIM : time := 1 ns;

--=============================================================================
-- SIGNAL DECLARATIONS
--=============================================================================

  signal CLKxCI : std_logic := '0';
  signal RSTxRI : std_logic := '1';

  signal XCoordxDO : unsigned(COORD_BW - 1 downto 0);
  signal YCoordxDO : unsigned(COORD_BW - 1 downto 0);

  signal HSxSO : std_logic;
  signal VSxSO : std_logic;

  signal RedxSO   : std_logic_VECTOR(COLOR_BW - 1 downto 0);
  signal GreenxSO : std_logic_VECTOR(COLOR_BW - 1 downto 0);
  signal BluexSO  : std_logic_VECTOR(COLOR_BW - 1 downto 0);

--=============================================================================
-- COMPONENT DECLARATIONS
--=============================================================================

  component vga_controller is
    port (
      CLKxCI : in std_logic;
      RSTxRI : in std_logic;

      -- Data/color input
      RedxSI   : in std_logic_VECTOR(COLOR_BW - 1 downto 0);
      GreenxSI : in std_logic_VECTOR(COLOR_BW - 1 downto 0);
      BluexSI  : in std_logic_VECTOR(COLOR_BW - 1 downto 0);

      -- Coordinate output
      XCoordxDO : out unsigned(COORD_BW - 1 downto 0);
      YCoordxDO : out unsigned(COORD_BW - 1 downto 0);

      -- Timing output
      HSxSO : out std_logic;
      VSxSO : out std_logic;

      -- Data/color output
      RedxSO   : out std_logic_VECTOR(COLOR_BW - 1 downto 0);
      GreenxSO : out std_logic_VECTOR(COLOR_BW - 1 downto 0);
      BluexSO  : out std_logic_VECTOR(COLOR_BW - 1 downto 0)
    );
  end component vga_controller;

--=============================================================================
-- ARCHITECTURE BEGIN
--=============================================================================
begin

--=============================================================================
-- COMPONENT INSTANTIATIONS
--=============================================================================
-------------------------------------------------------------------------------
-- The design under test
-------------------------------------------------------------------------------
  dut: vga_controller
    port map (
      CLKxCI => CLKxCI,
      RSTxRI => RSTxRI,

      RedxSI   => "1111",
      GreenxSI => "1111",
      BluexSI  => "1111",

      HSxSO => HSxSO,
      VSxSO => VSxSO,

      XCoordxDO => XCoordxDO,
      YCoordxDO => YCoordxDO,

      RedxSO   => RedxSO,
      GreenxSO => GreenxSO,
      BluexSO  => BluexSO
    );

--=============================================================================
-- CLOCK PROCESS
-- Process for generating the clock signal
--=============================================================================
  p_clock: process is
  begin
    CLKxCI <= '0';
    wait for CLK_LOW;
    CLKxCI <= '1';
    wait for CLK_HIGH;
  end process p_clock;

--=============================================================================
-- RESET PROCESS
-- Process for generating initial reset
--=============================================================================
  p_reset: process is
  begin
    RSTxRI <= '1';
    wait until CLKxCI'event and CLKxCI = '1'; -- Align to clock
    wait for (2*CLK_PER + CLK_STIM);
    RSTxRI <= '0';
    wait;
  end process p_reset;

--=============================================================================
-- HSYNC VERIFICATION PROCESSS
-- Verifies the length of the pulse and line
--=============================================================================
  p_verify_hsync: process is

    variable ClockCNT : integer := 0; -- Number of clock cycles

    variable HSPrev : std_logic := '0'; -- Previous value of HSxSO

    variable HSyncCCHighPrev : integer := 0; -- Cycle where output went high
    variable HSyncCCLow      : integer := 0; -- Cycle where output went low

    variable HSyncPulseWCC : integer := 0; -- Horizontal sync pulse width in clock cycles
    variable HLineWCC      : integer := 0; -- Horizontal line width in clock cycles

    variable HSyncPulseWSec : time := 0 ns; -- Horizontal sync pulse width in seconds
    variable HLineWSec      : time := 0 ns; -- Horizontal line width in seconds

    variable HSyncPulseWCCGOLDEN : integer := HS_PULSE; -- 136, See http://tinyvga.com/vga-timing/1024x768@70Hz
    variable HLineWCCGOLDEN      : integer := HS_DISPLAY + HS_FRONT_PORCH + HS_PULSE + HS_BACK_PORCH; -- 1328

    -- 136/(75 MHz)*1ns = 1813.333333 ns but simulation time resolution too low, so we get 136*(2*6.667 ns) = 1813.424 ns
    -- 1328/(75 MHz)*1ns = 17706.666666667 ns but simulation time resolution too low, so we get 1328*(2*6.667 ns) = 17707.552 ns
    variable HSyncPulseWSecGOLDEN : time := 1813.424 ns;
    variable HLineWSecGOLDEN      : time := 17707.552 ns;

    variable HSyncPulseWNumErrors : integer := 0; -- Number of errors for horizontal sync pulse widths
    variable HLineWNumErrors      : integer := 0; -- Number of errors for horizontal line widths

    variable HSyncPulseWNumCorrect : integer := 0; -- Number of correct horizontal sync pulse widths
    variable HLineWNumCorrect      : integer := 0; -- Number of correct horizontal line widths

  begin

    wait until CLKxCI'event and CLKxCI = '1' and RSTxRI = '0';
    wait for CLK_STIM;

    -- Save prev pulse and wait 1 CC, then check if falling/rising edges
    while now < 50 ms loop

      HSPrev := HSxSO;

      wait until CLKxCI'event and CLKxCI = '1';
      ClockCNT := ClockCNT + 1;
      wait for CLK_STIM;

      -- Falling edge of HSxSO
      if HSxSO = '0' and HSPrev = '1' then
        HSyncCCLow := ClockCNT;
      end if;

      -- Rising edge of HSxSO
      if HSxSO = '1' and HSPrev = '0' then

        HSyncPulseWCC  := ClockCNT - HSyncCCLow;
        HLineWCC       := ClockCNT - HSyncCCHighPrev;
        HSyncPulseWSec := HSyncPulseWCC  * CLK_PER;
        HLineWSec      := HLineWCC * CLK_PER;

        if HSyncPulseWCC /= HSyncPulseWCCGOLDEN then
          report
            lf & "Horizontal sync pulse width is " & integer'image(HSyncPulseWCC) & " CC, expected " & integer'image(HSyncPulseWCCGOLDEN) &
            lf & "Horizontal sync pulse width is " & time'image(HSyncPulseWSec) & ", expected (approx) " & time'image(HSyncPulseWSecGOLDEN) &
            lf
          severity warning;

          HSyncPulseWNumErrors := HSyncPulseWNumErrors + 1;
        else
          HSyncPulseWNumCorrect := HSyncPulseWNumCorrect + 1;
        end if;

        if HLineWCC /= HLineWCCGOLDEN then
          report
            lf & "Horizontal line width is " & integer'image(HLineWCC) & " CC, expected " & integer'image(HLineWCCGOLDEN) &
            lf & "Horizontal line width is " & time'image(HLineWSec) & ", expected (approx) " & time'image(HLineWSecGOLDEN) &
            lf
          severity warning;

          HLineWNumErrors := HLineWNumErrors + 1;
          else
          HLineWNumCorrect := HLineWNumCorrect + 1;
        end if;

        HSyncCCHighPrev := ClockCNT;
      end if;
    end loop;



    report
      lf & "********************************************************************" &
      lf & "HORIZONTAL SYNC CHECK COMPLETE" &
      lf & "    Got " & integer'image(HSyncPulseWNumErrors) & " errors for horizontal pulse width (1 is okay initially)" &
      lf & "    Got " & integer'image(HLineWNumErrors) & " errors for horizontal line width (1 is okay initially)" &
      lf & "    Got " & integer'image(HSyncPulseWNumCorrect) & " correct for horizontal pulse width" &
      lf & "    Got " & integer'image(HLineWNumCorrect) & " correct for horizontal line width" &
      lf & "********************************************************************" &
      lf;

    wait for 1 ms;
    stop(0);

  end process p_verify_hsync;

--=============================================================================
-- VSYNC VERIFICATION PROCESSS
-- Verifies the length of the pulse and frame
--=============================================================================
  p_verify_vsync: process is

    variable ClockCNT : integer := 0;

    variable VSPrev : std_logic := '0';

    variable VSyncCCHighPrev : integer := 0;
    variable VSyncCCLow      : integer := 0;

    variable VSyncPulseWCC : integer := 0;
    variable VFrameWCC     : integer := 0;

    variable VSyncPulseWSec : time := 0 ns;
    variable VFrameWSec     : time := 0 ns;

    variable VSyncPulseWCCGOLDEN : integer := 7968; -- See http://tinyvga.com/vga-timing/1024x768@70Hz
    variable VFrameWCCGOLDEN     : integer := 1070368;

    -- 7968/(75 MHz)*1ns = 106240 ns but simulation time resolution too low, so we get 7968*(2*6.667) = 106245.312 ns
    -- 1070368/(75 MHz)*1ns = 14271573.333333 ns but simulation time resolution too low, so we get 1070368*(2*6.667 ns) = 14272286.912 ns
    variable VSyncPulseWSecGOLDEN : time := 106245.312 ns;
    variable VFrameWSecGOLDEN     : time := 14272286.912 ns;

    variable VSyncPulseWNumErrors : integer := 0;
    variable VFrameWNumErrors     : integer := 0;

    variable VSyncPulseWNumCorrect : integer := 0;
    variable VFrameWNumCorrect     : integer := 0;

  begin

    wait until CLKxCI'event and CLKxCI = '1' and RSTxRI = '0';
    wait for CLK_STIM;

    while now < 50 ms loop

      VSPrev := VSxSO;

      wait until CLKxCI'event and CLKxCI = '1';
      ClockCNT := ClockCNT + 1;
      wait for CLK_STIM;

      -- Falling edge of VSxSO
      if VSxSO = '0' and VSPrev = '1' then
        VSyncCCLow := ClockCNT;
      end if;

      -- Rising edge of VSxSO
      if VSxSO = '1' and VSPrev = '0' then

        VSyncPulseWCC  := ClockCNT - VSyncCCLow;
        VFrameWCC      := ClockCNT - VSyncCCHighPrev;
        VSyncPulseWSec := VSyncPulseWCC  * CLK_PER;
        VFrameWSec     := VFrameWCC * CLK_PER;

        if VSyncPulseWCC /= VSyncPulseWCCGOLDEN then
          report
            lf & "Vertical sync pulse width is " & integer'image(VSyncPulseWCC) & " CC, expected " & integer'image(VSyncPulseWCCGOLDEN) &
            lf & "Vertical sync pulse width is " & time'image(VSyncPulseWSec) & ", expected (approx) " & time'image(VSyncPulseWSecGOLDEN) &
            lf
          severity warning;

          VSyncPulseWNumErrors := VSyncPulseWNumErrors + 1;
        else
          VSyncPulseWNumCorrect := VSyncPulseWNumCorrect + 1;
        end if;

        if VFrameWCC /= VFrameWCCGOLDEN then
          report
            lf & "Vertical frame width is " & integer'image(VFrameWCC) & " CC, expected " & integer'image(VFrameWCCGOLDEN) &
            lf & "Vertical frame width is " & time'image(VFrameWSec) & ", expected (approx) " & time'image(VFrameWSecGOLDEN) &
            lf
          severity warning;

          VFrameWNumErrors := VFrameWNumErrors + 1;
        else
          VFrameWNumCorrect := VFrameWNumCorrect + 1;
        end if;

        VSyncCCHighPrev := ClockCNT;
      end if;
    end loop;



    report
      lf & "********************************************************************" &
      lf & "VERTICAL SYNC CHECK COMPLETE" &
      lf & "    Got " & integer'image(VSyncPulseWNumErrors) & " errors for vertical pulse width (1 is okay initially)" &
      lf & "    Got " & integer'image(VFrameWNumErrors) & " errors for vertical frame width (1 is okay initially)" &
      lf & "    Got " & integer'image(VSyncPulseWNumCorrect) & " correct for vertical pulse width" &
      lf & "    Got " & integer'image(VFrameWNumCorrect) & " correct for vertical frame width" &
      lf & "********************************************************************" &
      lf;

    wait for 1 ms;
    stop(0);

  end process p_verify_vsync;

end architecture tb;
--=============================================================================
-- ARCHITECTURE END
--=============================================================================
