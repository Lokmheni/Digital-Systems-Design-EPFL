----------------------------------------------------------------------------------
-- Company: EPFL
-- Engineer: Simon J. Thür
-- 
-- Create Date: 16.11.2022 11:03:36
-- Design Name: TEST BENCH for arbiter
-- Module Name: arbiter_tb - Behavioral
-- Project Name: ARBITER
-- Target Devices: PINQ
-- Tool Versions: idk
-- Description: tb
-- 
-- Dependencies: idk
-- 
-- Revision:0.01
-- Revision 0.01 - File Created
-- Additional Comments: NONE
-- 
----------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY std;
USE std.env.ALL;


-- tb entity

ENTITY arbiter_tb IS

END ENTITY arbiter_tb;


-- tb architecture

ARCHITECTURE tb OF arbiter_tb IS
  -- Constants
  CONSTANT ClkHigh : time      := 4ns;  -- Clock high time
  CONSTANT ClkLow  : time      := 4ns;  -- Clock low time
  CONSTANT CLKPer  : time      := ClkHigh+ClkLow;  -- Clock cycle period
  CONSTANT ClkStim : time      := 1ns;  -- Push a little after clock edge
  CONSTANT ClkLim  : integer   := 2**22;           -- Stop simulation timeout
  -- Signals
  SIGNAL CLK_c     : std_logic := '0';  -- clock
  SIGNAL RST       : std_logic := '1';  -- Async Reset
  SIGNAL Key0      : std_logic := '0';  -- Access request 0
  SIGNAL Key1      : std_logic := '0';  -- Access request 1
  SIGNAL RLED0     : std_logic;         -- RLED0
  SIGNAL GLED0     : std_logic;         -- GLED0
  SIGNAL RLED1     : std_logic;         -- RLED1
  SIGNAL GLED1     : std_logic;         -- GLED1
  -- components
  COMPONENT arbiter IS
    PORT (
      CLKxCI   : IN  std_logic;
      RSTxRI   : IN  std_logic;
      Key0xSI  : IN  std_logic;
      Key1xSI  : IN  std_logic;
      GLED0xSO : OUT std_logic;
      RLED0xSO : OUT std_logic;
      GLED1xSO : OUT std_logic;
      RLED1xSO : OUT std_logic);
  END COMPONENT arbiter;
BEGIN  -- ARCHITECTURE tb


  arbiter_1 : ENTITY work.arbiter
    PORT MAP (
      CLKxCI   => CLK_c,
      RSTxRI   => RST,
      Key0xSI  => Key0,
      Key1xSI  => Key1,
      GLED0xSO => GLED0,
      RLED0xSO => RLED0,
      GLED1xSO => GLED1,
      RLED1xSO => RLED1);
  -- Clock process
  p_clk : PROCESS IS
  BEGIN
    CLK_c <= '0';
    WAIT FOR ClkLow;
    CLK_c <= '0';
    WAIT FOR ClkHigh;
  END PROCESS p_clk;

  -- Rst process
  p_rst : PROCESS IS
  BEGIN  -- PROCESS p_rst
    RST <= '1';
    WAIT UNTIL CLK_c = '1';
    WAIT FOR (2* CLKPer + ClkStim);
    RST <= '0';
    WAIT;
  END PROCESS p_rst;


  --test stuff


  p_tst : PROCESS IS
  BEGIN
    WAIT UNTIL RST = '0';

    Key0 <= '1';
    WAIT FOR (2*ClkPer);
    Key0 <= '0';
    WAIT FOR (2*ClkPer);
    Key1 <= '1';
    WAIT FOR (2*ClkPer);
    Key0 <= '1';
    stop(0);
  END PROCESS p_tst;




END ARCHITECTURE tb;
