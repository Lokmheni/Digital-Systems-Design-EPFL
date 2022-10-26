--=============================================================================
-- @file toplevel.vhdl
-- @author Simon Thür
--=============================================================================
-- Standard library
library ieee;
-- Standard packages
use ieee.std_logic_1164.all;

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

  
  
  BEGIN
  key_lock : KeyLock
  PORT MAP(
      CLKxCI => CLKxCI,
      RSTxRI => RSTxRI,
      
      KeyValidxSI => KeyValidxSI,
      KeyxDI  => KeyxDI ,
      
      GLEDxSO => GLEDxSO,
      RLEDxSO => RLEDxSO,
      )


end rtl;