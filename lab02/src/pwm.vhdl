--=============================================================================
-- @file pwm.vhdl
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

    BtnPressxSI : in std_logic;
    LedxSO  : out std_logic
  );
END pwm;


architecture rtl of pwm is

  constant CounterAdd                           : natural := 131072;
  signal EdgexS                                 : std_logic;
  signal BtnPressxSN, BtnPressxSP               : std_logic;
  signal CounterOverflowxDN, CounterOverflowxDP : unsigned(19 downto 0);
  signal PWMcountxDN, PWMcountxDP               : unsigned(19 downto 0); 
  signal PWMxS       

BEGIN


  PROCESS(CLKxCI, RSTxRI)
  BEGIN
    IF (RSTxRI = '1') THEN
      BtnPressxSP <= '0';
    ELSIF (CLKxCI'EVENT AND CLKxCI = '1') THEN
      BtnPressxSP <= BtnPressxSN;
    END IF;
  END PROCESS;
  EdgexS  <= BtnPressxSN AND (not BtnPressxSP);

  BtnPressxSN <= BtnPressxSI;
  PROCESS(CLKxCI, RSTxRI)
  BEGIN
    IF (RSTxRI = '1') THEN
      CounterOverflowxDP <= (OTHERS => '0');
    ELSIF (CLKxCI'EVENT AND CLKxCI = '1') THEN
      CounterOverflowxDP <= CounterOverflowxDN;
    END IF;
  END PROCESS;

  CounterOverflowxDN <=  CounterAdd + CounterOverflowxDP WHEN EdgexS = '1' ELSE CounterOverflowxDP;


-- PWM 
  PROCESS(CLKxCI, RSTxRI)
  BEGIN
    IF (RSTxRI = '1') THEN
      PWMcountxDP <= (OTHERS => '0');
    ELSIF (CLKxCI'EVENT AND CLKxCI = '1') THEN
      PWMcountxDP <= PWMcountxDN;
    END IF;
  END PROCESS;

  PWMcountxDN <= PWMcountxDP + 1;
  PWMxS <= '1' WHEN (PWMcountxDP < CounterOverflowxDP) ELSE '0';
  LedxSO <= PWMxS;

END rtl;
