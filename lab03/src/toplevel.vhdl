--=============================================================================
-- @file toplevel.vhdl
-- @author Simon Thür
--=============================================================================
-- Standard library
library ieee;
-- Standard packages
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--=============================================================================
--
-- toplevel
--
-- @brief This file specifies the toplevel for the the keylock (lab 3)
--
--=============================================================================

entity toplevel is
    port (
        CLKxCI : in std_logic;
        RSTxRI : in std_logic;
        Push0xSI : in std_logic;
        Push1xSI : in std_logic;
        Push2xSI : in std_logic;
        Push3xSI : in std_logic;
        RLEDxSO : out std_logic;
        GLEDxSO : out std_logic
    );
end toplevel;


architecture rtl of toplevel is

  COMPONENT KeyLock
    PORT (
        CLKxCI : in std_logic;
        RSTxRI : in std_logic;

        KeyValidxSI : in std_logic;
        KeyxDI  : in unsigned(3 downto 0);

        GLEDxSO : out std_logic;
        RLEDxSO : out std_logic
    );
  END COMPONENT;

  signal KeyValidxS : std_logic;
  signal KeyxD : unsigned(3 downto 0);
  
  BEGIN

  KeyValidxS <= '1' when Push0xSI='1' and Push1xSI = '0'and Push2xSI = '0'and Push3xSI = '0' else
                '1' when Push0xSI='0' and Push1xSI = '1'and Push2xSI = '0'and Push3xSI = '0' else
                '1' when Push0xSI='0' and Push1xSI = '0'and Push2xSI = '1'and Push3xSI = '0' else
                '1' when Push0xSI='0' and Push1xSI = '0'and Push2xSI = '0'and Push3xSI = '1' else
                '0';
  KeyxD <= to_unsigned(0,4) when Push0xSI='1' else
           to_unsigned(1,4) when Push1xSI='1' else
           to_unsigned(2,4) when Push2xSI='1' else
           to_unsigned(3,4) when Push3xSI='1';

  key_lock : KeyLock
  PORT MAP(
      CLKxCI => CLKxCI,
      RSTxRI => RSTxRI,
      --in
      KeyValidxSI => KeyValidxS,
      KeyxDI  => KeyxD ,
      --out
      GLEDxSO => GLEDxSO,
      RLEDxSO => RLEDxSO
      );


end rtl;