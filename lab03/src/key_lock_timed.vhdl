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
    signal KeyLockState : KeyLockState_type;
    signal CountEnxS : std_logic;
    signal CountValxD : unsigned(32 downto 0);

    begin
        FSM_PROC : process(CLKxCI,RSTxRI)
        begin
            --DEFAULT
            KeyLockState <= KeyLockState;
            CountEnxS <= CountEnxS;
            CountValxD <= CountValxD;

            --PROCESS

            --RST
            if RSTxRI = '1' then
                KeyLockState <= locked;
                CountEnxS <= '0';
                CountValxD <= (others => '0');
            elsif (CLKxCI'EVENT AND CLKxCI = '1') then
                case KeyLockState is
                    --LOCKED
                    when locked =>
                        if(KeyValidxSI='1') then
                            if(KeyxDI=0) then
                                KeyLockState <= ok1;
                            else
                                KeyLockState <= wrong1;
                            end if;
                        end if;
                    --Oks
                    when ok1 =>
                        if(KeyValidxSI='0') then
                            KeyLockState <= ok1wait;
                        end if;
                    when ok2 =>
                        if(KeyValidxSI='0') then
                            KeyLockState <= ok2wait;
                        end if;
                    when ok3 =>
                        if(KeyValidxSI='0') then
                            KeyLockState <= unlocked;
                            CountEnxS <='1';
                            CountValxD <= (others => '0');
                        end if;
                    --WRONGS
                    when wrong1 =>
                        if(KeyValidxSI='0') then
                            KeyLockState <= wrong1wait;
                        end if;
                    when wrong2 =>
                        if(KeyValidxSI='0') then
                            KeyLockState <= wrong2wait;
                        end if;
                    when wrong3 =>
                        if(KeyValidxSI='0') then
                            KeyLockState <= wrong3wait;
                        end if;
                    --wgong-wait
                    when wrong1wait =>
                        if(KeyValidxSI='1') then
                            KeyLockState <= wrong2;
                        end if;
                    when wrong2wait =>
                        if(KeyValidxSI='1') then
                            KeyLockState <= wrong3;
                        end if;
                    when wrong3wait =>
                        if(KeyValidxSI='1') then
                            KeyLockState <= locked;
                        end if;
                    --ok-wait
                    when ok1wait =>
                        if(KeyValidxSI='1') then
                            if(KeyxDI=2) then
                                KeyLockState <= ok2;
                            else
                                KeyLockState <= wrong2;
                            end if;
                        end if;
                    when ok2wait =>
                        if(KeyValidxSI='1') then
                            if(KeyxDI=1) then
                                KeyLockState <= ok3;
                            else
                                KeyLockState <= wrong3;
                            end if;
                        end if;
                    --open
                    when unlocked =>
                        if(CountValxD>=100000000) then
                            KeyLockState <= locked;
                            CountEnxS <='0';
                        end if;
                    when others =>
                        CountEnxS <='0';
                        KeyLockState <= locked;
                end case;

                --Counter:
                if(CountEnxS = '1') then
                    CountValxD <= CountValxD + 1;
                end if;

                --output
                case KeyLockState is
                
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


            end if;
        end process;




end architecture;