----------------------------------------------------------------------------------
-- Company: EPFL
-- Engineer: Simon J. Thür
-- 
-- Create Date: 16.11.2022 09:25:28
-- Design Name: ARBITER
-- Module Name: arbiter - Behavioral
-- Project Name: STUFF
-- Target Devices: PINQ
-- Tool Versions: IDK
-- Description: ARBITER FOR KEYS
-- 
-- Dependencies: NONE
-- 
-- Revision: 0.01
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;


entity arbiter is
  
  generic (
    port : <type > );

  port (
    CLKxCI   : in  std_logic;           -- CLK
    RSTxRI   : in  std_logic;           -- --Async rst
    Key0xSI  : in  std_logic;           -- Access request Key0
    Key1xSI  : in  std_logic;           -- Access request Key1
    GLED0xSO : out std_logic;           -- Grant Access Key0
    RLED0xSO : out std_logic;           -- Deny access Key0
    GLED1xSO : out std_logic;           -- Grant access Key1
    RLED1xSO : out std_logic);          -- Deny access Key1

end entity arbiter;


architecture rtl of arbiter is
type arbiter_state is (base,Access0,Access1);               -- Arbiter states
SIGNAL PrioxDP : std_logic;             -- Prio previous state
SIGNAL PrioxDN : std_logic;             -- Prio next state
SIGNAL FsmStatexDP : arbiter_state;     -- previous state of FSM
SIGNAL FsmStatexDN : arbiter_state;     -- next state of FSM
SIGNAL CountEnablexDP : std_logic;
SIGNAL CountEnablexDN : std_logic;
SIGNAL CounterValxDN : unsigned(31 DOWNTO 0);  -- Counter Value
SIGNAL CountEnablexDN : unsigned(31 DOWNTO 0);  -- Counter Value

  
begin  -- architecture rtl

  -- purpose: Register of Arbiter state
  -- type   : sequential
  -- inputs : CLKxCI, RSTxRI, all
  -- outputs: 
  registers: PROCESS (CLKxCI, RSTxRI) IS
  BEGIN  -- PROCESS registers
    IF RSTxRI = '1' THEN                -- asynchronous reset (active high)
      PrioxDP <= '0';
      FsmStatexDP <= base;
      CountEnablexDP <= '0';
      CounterValxDP <= (OTHERS => '0');
      
    ELSIF CLKxCI'event AND CLKxCI = '1' THEN  -- rising clock edge
      PrioxDP <=PrioxDN;
      FsmStatexDP <= FsmStatexDPN;
      CountEnablexDP <= CountEnablexDN;
      CounterValxDP <= CounterValxDN;
    END IF;
  END PROCESS registers;


  FSM_progression: PROCESS (ALL) IS
  BEGIN  -- PROCESS FSM_progression
    -- Default assignment
    FsmStatexDN <= FsmStatexDP;
    PrioxDN <= PrioxDP;
    
    -- State progression
    CASE FsmStatexDP IS
      WHEN base => IF Key0xSI='1' OR Key1xSI='1' THEN
                     CountEnablexDN <= '1';
                     PrioxDN <= '0';
                     CounterValxDN <= (OTHERS => '0');
                     IF Key0xSI='1' THEN
                       FsmStatexDN <= Access0;
                     ELSIF Key1xSI='1' THEN
                         FsmStatexDN <= Access1;
                     END IF;
                    END IF;
      WHEN Access0 => IF Key0xSI='0' AND Key1xSI='0' THEN
                        FsmStatexDN <= base;
                      ELSIF Key1xSI='1' AND (Key0xSI='0' OR PrioxDP='1') THEN
                          FsmStatexDN <= Access1;
                          PrioxDN <= '0';
                          CountEnablexDN<='1';
                          CounterValxDN <= (OTHERS => '0');
                      END IF;
      WHEN Access1 => IF
      WHEN OTHERS => NULL;
    END CASE;
  END PROCESS FSM_progression;
  

end architecture rtl;


