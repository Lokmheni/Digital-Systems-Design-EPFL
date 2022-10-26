--=============================================================================
-- @file key_lock_timed.vhdl
-- @author Simon Thür
--=============================================================================
-- Standard library
library ieee;
-- Standard packages
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- =============================================================================

-- Keylock

-- @brief Keylock circuit for Lab3

-- =============================================================================




entity KeyLock is
    port (
    CLKxCI : in std_logic;
    RSTxRI : in std_logic;

    KeyValidxSI : in std_logic;
    KeyxDI  : in unsigned(3 downto 0);

    GLEDxSO : out std_logic;
    RLEDxSO : out std_logic
    );
end KeyLock;

architecture rtl of KeyLock is
    type KeyLockState_type is ( locked,
                                wrong1,
                                wrong1wait,
                                wrong2,
                                wrong2wait,
                                wrong3,
                                wrong3wait,
                                ok1,
                                ok1wait,
                                ok2,
                                ok2wait,
                                ok3,
                                unlocked);
    signal KeyLockStatexN : KeyLockState_type;
    signal CountEnxSN : std_logic;
    signal CountValxDN : unsigned(32 downto 0);
    signal KeyLockStatexP : KeyLockState_type;
    signal CountEnxSP : std_logic;
    signal CountValxDP : unsigned(32 downto 0);

    begin
        FSM_PROC : process(all)
        begin
            --DEFAULT
            KeyLockStatexN <= KeyLockStatexP;
            CountEnxSN <= CountEnxSP;
            CountValxDN <= CountValxDP;

                case KeyLockStatexP is
                    --LOCKED
                    when locked =>
                        if(KeyValidxSI='1') then
                            if(KeyxDI=0) then
                                KeyLockStatexN <= ok1;
                            else
                                KeyLockStatexN <= wrong1;
                            end if;
                        end if;
                    --Oks
                    when ok1 =>
                        if(KeyValidxSI='0') then
                            KeyLockStatexN <= ok1wait;
                        end if;
                    when ok2 =>
                        if(KeyValidxSI='0') then
                            KeyLockStatexN <= ok2wait;
                        end if;
                    when ok3 =>
                        if(KeyValidxSI='0') then
                            KeyLockStatexN <= unlocked;
                            CountEnxSN <='1';
                            CountValxDN <= (others => '0');
                        end if;
                    --WRONGS
                    when wrong1 =>
                        if(KeyValidxSI='0') then
                            KeyLockStatexN <= wrong1wait;
                        end if;
                    when wrong2 =>
                        if(KeyValidxSI='0') then
                            KeyLockStatexN <= wrong2wait;
                        end if;
                    when wrong3 =>
                        if(KeyValidxSI='0') then
                            KeyLockStatexN <= wrong3wait;
                        end if;
                    --wgong-wait
                    when wrong1wait =>
                        if(KeyValidxSI='1') then
                            KeyLockStatexN <= wrong2;
                        end if;
                    when wrong2wait =>
                        if(KeyValidxSI='1') then
                            KeyLockStatexN <= wrong3;
                        end if;
                    when wrong3wait =>
                        if(KeyValidxSI='1') then
                            KeyLockStatexN <= locked;
                        end if;
                    --ok-wait
                    when ok1wait =>
                        if(KeyValidxSI='1') then
                            if(KeyxDI=2) then
                                KeyLockStatexN <= ok2;
                            else
                                KeyLockStatexN <= wrong2;
                            end if;
                        end if;
                    when ok2wait =>
                        if(KeyValidxSI='1') then
                            if(KeyxDI=1) then
                                KeyLockStatexN <= ok3;
                            else
                                KeyLockStatexN <= wrong3;
                            end if;
                        end if;
                    --open
                    when unlocked =>
                        if(CountValxDN>=100000000) then
                            KeyLockStatexN <= locked;
                            CountEnxSN <='0';
                        end if;
                    when others =>
                        CountEnxSN <='0';
                        KeyLockStatexN <= locked;
                end case;

                --Counter:
                if(CountEnxSN = '1') then
                    CountValxDN <= CountValxDP + 1;
                end if;

                --output
                case KeyLockStatexP is
                
                    when locked =>
                        RLEDxSO <= '1';
                        GLEDxSO <= '0';
                    when unlocked =>
                        RLEDxSO <= '0';
                        GLEDxSO <= '1';
                    when others =>
                        RLEDxSO <= '0';
                        GLEDxSO <= '0';
                end case;

        end process;

        registers : process(RSTxRI,CLKxCI)
        begin
            --default
            KeyLockStatexP <= KeyLockStatexP;
            CountEnxSP <= CountEnxSP;
            CountValxDP <= CountValxDP;
            if RSTxRI = '1' then
                KeyLockStatexP <= locked;
                CountEnxSP <= '0';
                CountValxDP <= (others => '0');
            elsif (CLKxCI'EVENT AND CLKxCI = '1') then
                
            KeyLockStatexP <= KeyLockStatexN;
            CountEnxSP <= CountEnxSN;
            CountValxDP <= CountValxDN;
            end if;
        end process;




end architecture;