--=============================================================================
-- @file toplevel.vhdl
-- @author Simon Thür
--=============================================================================
-- Standard library
LIBRARY ieee;
-- Standard packages
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

--=============================================================================
--
-- toplevel
--
-- @brief This file specifies the toplevel for the the keylock (lab 3)
--
--=============================================================================

ENTITY toplevel IS
    PORT (
        CLKxCI   : IN std_logic;
        RSTxRI   : IN std_logic;
        Push0xSI : IN std_logic;
        Push1xSI : IN std_logic;
        Push2xSI : IN std_logic;
        Push3xSI : IN std_logic;
        RLEDxSO  : OUT std_logic;
        GLEDxSO  : OUT std_logic
    );
END toplevel;
ARCHITECTURE rtl OF toplevel IS

    COMPONENT KeyLock
        PORT (
            CLKxCI : IN std_logic;
            RSTxRI : IN std_logic;

            KeyValidxSI : IN std_logic;
            KeyxDI      : IN unsigned(3 DOWNTO 0);

            GLEDxSO : OUT std_logic;
            RLEDxSO : OUT std_logic
        );
    END COMPONENT;

    SIGNAL KeyValidxS : std_logic;
    SIGNAL KeyxD      : unsigned(3 DOWNTO 0);

BEGIN

    KeyValidxS <= '1' WHEN Push0xSI = '1' AND Push1xSI = '0'AND Push2xSI = '0'AND Push3xSI = '0' ELSE
        '1' WHEN Push0xSI = '0' AND Push1xSI = '1'AND Push2xSI = '0'AND Push3xSI = '0' ELSE
        '1' WHEN Push0xSI = '0' AND Push1xSI = '0'AND Push2xSI = '1'AND Push3xSI = '0' ELSE
        '1' WHEN Push0xSI = '0' AND Push1xSI = '0'AND Push2xSI = '0'AND Push3xSI = '1' ELSE
        '0';
    KeyxD <= to_unsigned(0, 4) WHEN Push0xSI = '1' ELSE
        to_unsigned(1, 4) WHEN Push1xSI = '1' ELSE
        to_unsigned(2, 4) WHEN Push2xSI = '1' ELSE
        to_unsigned(3, 4) WHEN Push3xSI = '1' ELSE
        TO_UNSIGNED(0, 4);

    key_lock : KeyLock
    PORT MAP(
        CLKxCI => CLKxCI,
        RSTxRI => RSTxRI,
        --in
        KeyValidxSI => KeyValidxS,
        KeyxDI      => KeyxD,
        --out
        GLEDxSO => GLEDxSO,
        RLEDxSO => RLEDxSO
    );
END rtl;