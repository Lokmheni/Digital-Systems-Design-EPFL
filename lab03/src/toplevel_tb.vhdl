--=============================================================================
-- @file toplevel.vhdl
-- @author Simon Thür
--=============================================================================
-- Standard library
LIBRARY ieee;
-- Standard packages
USE std.env.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

--=============================================================================
--
-- toplevel testbench
--
-- @brief This file specifies the testbench for the the keylock (lab 3)
--
--=============================================================================
ENTITY toplevel_tb IS
END ENTITY toplevel_tb;

ARCHITECTURE tb OF toplevel_tb IS

    --=============================================================================
    -- TYPE AND CONSTANT DECLARATIONS
    --=============================================================================
    CONSTANT CLK_HIGH   : time := 4 ns;
    CONSTANT CLK_LOW    : time := 4 ns;
    CONSTANT CLK_PERIOD : time := CLK_LOW + CLK_HIGH;
    CONSTANT CLK_STIM   : time := 1 ns;
    CONSTANT CLK_RESP   : time := CLK_PERIOD - 1 ns;

    --=============================================================================
    -- COMPONENT DECLARATIONS
    --=============================================================================
    COMPONENT toplevel IS
        PORT (
            CLKxCI : IN std_logic;
            RSTxRI : IN std_logic;

            Push0xSI : IN std_logic;
            Push1xSI : IN std_logic;
            Push2xSI : IN std_logic;
            Push3xSI : IN std_logic;

            RLEDxSO : OUT std_logic;
            GLEDxSO : OUT std_logic
        );
    END COMPONENT toplevel;

    --=============================================================================
    -- SIGNAL DECLARATIONS
    --=============================================================================
    SIGNAL CLKxC : std_logic;
    SIGNAL RSTxR : std_logic;

    SIGNAL Push0xS : std_logic;
    SIGNAL Push1xS : std_logic;
    SIGNAL Push2xS : std_logic;
    SIGNAL Push3xS : std_logic;

    SIGNAL RLEDxS : std_logic;
    SIGNAL GLEDxS : std_logic;

BEGIN

    --=============================================================================
    -- COMPONENT INSTANTIATIONS
    --=============================================================================

    -- Instantiate dut
    toplevel_1 : ENTITY work.toplevel
        PORT MAP(
            CLKxCI   => CLKxC,
            RSTxRI   => RSTxR,
            Push0xSI => Push0xS,
            Push1xSI => Push1xS,
            Push2xSI => Push2xS,
            Push3xSI => Push3xS,
            RLEDxSO  => RLEDxS,
            GLEDxSO  => GLEDxS
        );
    -- CLOCK PROCESS
    ClkProcess : PROCESS IS
    BEGIN
        CLKxC <= '0';
        WAIT FOR CLK_LOW;
        CLKxC <= '1';
        WAIT FOR CLK_HIGH;
    END PROCESS ClkProcess;

    --Rst
    ResetProcess : PROCESS IS
    BEGIN
        RSTxR <= '1';
        WAIT UNTIL CLKxC'event AND CLKxC = '1';
        WAIT FOR (2 * CLK_PERIOD + CLK_STIM);
        RSTxR <= '0';
        WAIT;
    END PROCESS ResetProcess;

    -- TESTS
    ProcessTestSim : PROCESS IS
    BEGIN
        Push0xS <= '0';
        Push1xS <= '0';
        Push2xS <= '0';
        Push3xS <= '0';
        WAIT UNTIL CLKxC'event AND CLKxC = '1' AND RSTxR = '0';

        --test buttons correct
        -- 0
        WAIT FOR 0.5ms;
        WAIT UNTIL CLKxC'event AND CLKxC = '1';
        WAIT FOR CLK_STIM;
        Push0xS <= '1';

        WAIT FOR 0.25ms;
        WAIT UNTIL CLKxC'event AND CLKxC = '1';
        WAIT FOR CLK_STIM;
        Push0xS <= '0';

        -- 2
        WAIT FOR 0.5ms;
        WAIT UNTIL CLKxC'event AND CLKxC = '1';
        WAIT FOR CLK_STIM;
        Push2xS <= '1';

        WAIT FOR 0.25ms;
        WAIT UNTIL CLKxC'event AND CLKxC = '1';
        WAIT FOR CLK_STIM;
        Push2xS <= '0';

        -- 1
        WAIT FOR 0.5ms;
        WAIT UNTIL CLKxC'event AND CLKxC = '1';
        WAIT FOR CLK_STIM;
        Push1xS <= '1';

        WAIT FOR 0.25ms;
        WAIT UNTIL CLKxC'event AND CLKxC = '1';
        WAIT FOR CLK_STIM;
        Push1xS <= '0';

        -- Press buttons wrong
        WAIT UNTIL CLKxC'event AND CLKxC = '1' AND RLEDxS = '1';

        -- 0
        WAIT FOR 0.5ms;
        WAIT UNTIL CLKxC'event AND CLKxC = '1';
        WAIT FOR CLK_STIM;

        Push0xS <= '1';
        WAIT FOR 0.25ms;
        WAIT UNTIL CLKxC'event AND CLKxC = '1';
        WAIT FOR CLK_STIM;
        Push0xS <= '0';

        -- 3
        WAIT FOR 0.5ms;
        WAIT UNTIL CLKxC'event AND CLKxC = '1';
        WAIT FOR CLK_STIM;

        Push3xS <= '1';
        WAIT FOR 0.25ms;
        WAIT UNTIL CLKxC'event AND CLKxC = '1';
        WAIT FOR CLK_STIM;
        Push3xS <= '0';

        -- 1
        WAIT FOR 0.5ms;
        WAIT UNTIL CLKxC'event AND CLKxC = '1';
        WAIT FOR CLK_STIM;
        Push1xS <= '1';

        WAIT FOR 0.25ms;
        WAIT UNTIL CLKxC'event AND CLKxC = '1';
        WAIT FOR CLK_STIM;
        Push1xS <= '0';

        WAIT FOR 0.5ms;
        stop(0);
    END PROCESS ProcessTestSim;

END ARCHITECTURE tb;