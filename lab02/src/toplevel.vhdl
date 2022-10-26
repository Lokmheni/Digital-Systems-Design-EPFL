--=============================================================================
-- @file toplevel.vhdl
--=============================================================================
-- Standard library
library ieee;
-- Standard packages
use ieee.std_logic_1164.all;

--=============================================================================
--
-- toplevel
--
-- @brief This file specifies the toplevel for the RGB LED lab (lab 2)
--
--=============================================================================
entity toplevel is
  PORT (
    CLKxCI : in std_logic;
    RSTxRI : in std_logic;

    PushRedxSI   : in std_logic;
    PushGreenxSI : in std_logic;
    PushBluexSI  : in std_logic;

    LedRedxSO   : out std_logic;
    LedGreenxSO : out std_logic;
    LedBluexSO  : out std_logic
  );
END toplevel;


architecture rtl of toplevel is

  COMPONENT pwm
    PORT (
      CLKxCI : in std_logic;
      RSTxRI : in std_logic;

      PushxSI : in std_logic;
      LedxSO  : out std_logic
    );
  END COMPONENT;

BEGIN
  pwm_r : pwm
    PORT MAP (
      CLKxCI  => CLKxCI,
      RSTxRI  => RSTxRI,
      PushxSI => PushRedxSI,
      LedxSO  => LedRedxSO
    );
  pwm_gen : pwm
    PORT MAP (
      CLKxCI  => CLKxCI,
      RSTxRI  => RSTxRI,
      PushxSI => PushGreenxSI,
      LedxSO  => LedGreenxSO
    );
  pwm_be : pwm
    PORT MAP (
      CLKxCI  => CLKxCI,
      RSTxRI  => RSTxRI,
      PushxSI => PushBluexSI,
      LedxSO  => LedBluexSO
    );
END rtl;
