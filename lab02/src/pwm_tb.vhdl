--=============================================================================
-- @file pwm_tb.vhdl
--=============================================================================
-- Standard library
LIBRARY ieee;
LIBRARY std;
-- Standard packages
USE std.env.ALL;
USE ieee.std_logic_1164.ALL;

--=============================================================================
--
-- pwm_tb
--
-- @brief This file specifies the testbench for the RGB LED lab (lab 2).
--
-- This test will
--
--=============================================================================

--=============================================================================
-- ENTITY DECLARATION FOR pwm_tb
--=============================================================================
ENTITY pwm_tb IS
END pwm_tb;

--=============================================================================
-- ARCHITECTURE DECLARATION
--=============================================================================
ARCHITECTURE tb OF pwm_tb IS

    -- Constants
    CONSTANT CLK_HIGH : time    := 4ns; -- 125 MHz clk freq
    CONSTANT CLK_LOW  : time    := 4ns;
    CONSTANT CLK_PER  : time    := CLK_LOW + CLK_HIGH;
    CONSTANT CLK_STIM : time    := 1ns;     -- Used to push us a little bit after the clock edge
    CONSTANT CLK_LIM  : integer := 2 ** 22; -- Stops simulation from running forever if circuit is not correct

    CONSTANT CNT_ADD : integer := 2 ** 17;
    CONSTANT CNT_LIM : integer := 2 ** 20 - 1;

    -- DUT signals
    SIGNAL CLKxCI : std_logic := '0';
    SIGNAL RSTxRI : std_logic := '0';

    SIGNAL PushxSI : std_logic := '0';
    SIGNAL LedxSO  : std_logic;

    -- Testbench signals
    --=============================================================================
    -- COMPONENT DECLARATIONS
    --=============================================================================
    COMPONENT pwm IS
        PORT (
            CLKxCI : IN std_logic;
            RSTxRI : IN std_logic;

            PushxSI : IN std_logic;
            LedxSO  : OUT std_logic
        );
    END COMPONENT;

    --=============================================================================
    -- ARCHITECTURE BEGIN
    --=============================================================================
BEGIN

    --=============================================================================
    -- COMPONENT INSTANTIATIONS
    --=============================================================================
    dut : pwm
    PORT MAP(
        CLKxCI => CLKxCI,
        RSTxRI => RSTxRI,

        PushxSI => PushxSI,
        LedxSO  => LedxSO
    );

    --=============================================================================
    -- CLOCK PROCESS
    -- Process for generating the clock signal
    --=============================================================================
    p_clock : PROCESS IS
    BEGIN
        CLKxCI <= '0';
        WAIT FOR CLK_LOW;
        CLKxCI <= '1';
        WAIT FOR CLK_HIGH;
    END PROCESS p_clock;

    --=============================================================================
    -- RESET PROCESS
    -- Process for generating the reset signal
    --=============================================================================
    p_reset : PROCESS IS
    BEGIN
        RSTxRI <= '1';
        WAIT UNTIL rising_edge(CLKxCI);    -- Align to clock rising edge
        WAIT FOR (2 * CLK_PER + CLK_STIM); -- Align to CLK_STIM ns after rising edge
        RSTxRI <= '0';
        WAIT;
    END PROCESS p_reset;

    --=============================================================================
    -- TEST PROCESSS
    --=============================================================================
    p_stim : PROCESS

        VARIABLE CCLedHigh    : integer := 0; -- Cycle where LedxSO was set high
        VARIABLE CCLedLow     : integer := 0; -- Cycle where LedxSO was set low
        VARIABLE CCLedHighSet : integer := 0;
        VARIABLE CCLedLowSet  : integer := 0;

        VARIABLE ClkCnt : integer := 0; -- Free-running clock-cycle counter

        VARIABLE LEDPrev : std_logic := '0';

        VARIABLE PulseW     : integer := 0; -- Pulse width in clock cycles
        VARIABLE PulseWGold : integer := 0;

    BEGIN
        WAIT UNTIL RSTxRI = '0';

        FOR PushIdx IN 1 TO 7 LOOP -- Reset after 8 button presses (need initial push to turn on)
            -- This means that the 7th button press is the last one
            PushxSI <= '1';
            WAIT FOR CLK_PER;
            PushxSI <= '0';
            WAIT FOR CNT_ADD * CLK_PER; -- When pushing, the free-running counter may give a pulse
            -- which is too short depending on the current counter value.
            -- We wait until this pulse dies out before measuring

            FOR ClkIdx IN 1 TO CLK_LIM LOOP -- Detect rising- and falling-edges of LedxSO and verify
                -- pulse width between these
                LEDPrev := LedxSO;
                ClkCnt  := ClkCnt + 1;
                WAIT FOR CLK_PER;

                -- Detect the rising edge of LedxSO (assuming neither rising nor falling edge has been detected yet)
                IF (LEDPrev = '0') AND (LedxSO = '1') AND (CCLedHighSet = 0 AND CCLedLowSet = 0) THEN
                    CCLedHigh    := ClkCnt;
                    CCLedHighSet := 1;
                END IF;

                -- Detect the falling edge of LedxSO (checks only after rising edge has been observed first)
                IF (LEDPrev = '1') AND (LedxSO = '0') AND (CCLedHighSet = 1 AND CCLedLowSet = 0) THEN
                    CCLedLow    := ClkCNT;
                    CCLedLowSet := 1;
                END IF;

                -- If both rising and falling edges have been observed, verify the pulse width
                IF (CCLedHighSet = 1 AND CCLedLowSet = 1) THEN
                    PulseW     := CCLedLow - CCLedHigh;
                    PulseWGold := PushIdx * CNT_ADD;

                    IF PulseW = PulseWGold THEN
                        REPORT "Pulse width " & integer'image(PulseW) & " cycles, expected " & integer'image(PulseWGold) & " good work!";
                        CCLedHighSet := 0;
                        CCLedLowSet  := 0;
                        EXIT;
                    ELSE
                        REPORT "Pulse width " & integer'image(PulseW) & " cycles, expected " & integer'image(PulseWGold) & " try again!" SEVERITY warning;
                        CCLedHighSet := 0;
                        CCLedLowSet  := 0;
                    END IF;
                END IF;
            END LOOP;
        END LOOP;

        PushxSI <= '1';
        WAIT FOR CLK_PER;
        PushxSI <= '0';

        WAIT FOR CLK_PER;
        stop(0);

    END PROCESS;
END tb;
--=============================================================================
-- ARCHITECTURE END
--=============================================================================