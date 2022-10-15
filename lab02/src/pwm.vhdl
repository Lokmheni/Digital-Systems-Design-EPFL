--=============================================================================
-- @file toplevel.vhdl
--=============================================================================
-- Standard library
library ieee;
-- Standard packages
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--=============================================================================
--
-- pwm
--
-- @brief PWM circuit for the RGB LED lab (lab 2)
--
--=============================================================================
entity pwm is
  port (
    CLKxCI : in std_logic;
    RSTxRI : in std_logic;

    PushxSI : in std_logic;
    LedxSO  : out std_logic
  );
end pwm;


architecture rtl of pwm is

  -- TODO: define the needed signals

begin

  -- TODO: Edge detection
  PushxSN <= PushxSI;  -- input push botton


  -- TODO: Threshold generation


  -- TODO: PWM pulse


  LedxSO <= PWMxS; -- assign to output

end rtl;
