----------------------------------------------------------------------------------
-- Company: EPFL
-- Engineer: Simon Thür
-- 
-- Create Date: 02.12.2022 22:27:12
-- Design Name: 
-- Module Name: pong_fsm_tb - tb
-- Project Name: PONG
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------



LIBRARY ieee;
LIBRARY std;
-- Standard packages
USE std.env.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
-- Packages
LIBRARY work;
USE work.dsd_prj_pkg.ALL;


ENTITY pong_fsm_tb IS
END pong_fsm_tb;

ARCHITECTURE tb OF pong_fsm_tb IS
--constants
  CONSTANT CLK_HIGH : time := 6 ns;     -- ckl
  CONSTANT CLK_LOW  : time := 6 ns;
  CONSTANT CLK_STIM : time := 1 ns;


--signals
  SIGNAL CLK_CI : std_logic := '0';
  SIGNAL RSTxRI : std_logic := '1';



  --component signals
  SIGNAL CLKxCI    : std_logic;
  SIGNAL RSTxRI    : std_logic;
  SIGNAL LeftxSI   : std_logic;
  SIGNAL RightxSI  : std_logic;
  SIGNAL VgaXxDI   : unsigned(COORD_BW - 1 DOWNTO 0);
  SIGNAL VgaYxDI   : unsigned(COORD_BW - 1 DOWNTO 0);
  SIGNAL VSEdgexSI : std_logic;
  SIGNAL BallXxDO  : unsigned(COORD_BW - 1 DOWNTO 0);
  SIGNAL BallYxDO  : unsigned(COORD_BW - 1 DOWNTO 0);
  SIGNAL PlateXxDO : unsigned(COORD_BW - 1 DOWNTO 0);


--COMPONENT
  COMPONENT pong_fsm IS
    PORT (
      CLKxCI    : IN  std_logic;
      RSTxRI    : IN  std_logic;
      LeftxSI   : IN  std_logic;
      RightxSI  : IN  std_logic;
      VgaXxDI   : IN  unsigned(COORD_BW - 1 DOWNTO 0);
      VgaYxDI   : IN  unsigned(COORD_BW - 1 DOWNTO 0);
      VSEdgexSI : IN  std_logic;
      BallXxDO  : OUT unsigned(COORD_BW - 1 DOWNTO 0);
      BallYxDO  : OUT unsigned(COORD_BW - 1 DOWNTO 0);
      PlateXxDO : OUT unsigned(COORD_BW - 1 DOWNTO 0));
  END COMPONENT pong_fsm;




--architechture begin
BEGIN
  dut : ENTITY work.pong_fsm
    PORT MAP (
      CLKxCI    => CLKxCI,
      RSTxRI    => RSTxRI,
      LeftxSI   => LeftxSI,
      RightxSI  => RightxSI,
      VgaXxDI   => VgaXxDI,
      VgaYxDI   => VgaYxDI,
      VSEdgexSI => VSEdgexSI,
      BallXxDO  => BallXxDO,
      BallYxDO  => BallYxDO,
      PlateXxDO => PlateXxDO);

  -- vga, maybe change in further testing
  VgaXxDI <= (OTHERS => '0');
  VgaYxDI <= (OTHERS => '0');


  --clock generation
  p_clock : PROCESS IS
  BEGIN
    CLKxCI <= '0';
    WAIT FOR CLK_LOW;
    CLKxCI <= '1';
    WAIT FOR CLK_HIGH;
  END PROCESS p_clock;

  --reset
  p_reset : PROCESS IS
  BEGIN
    RSTxRI <= '1';
    WAIT UNTIL CLKxCI'event AND CLKxCI = '1';  -- Align to clock
    WAIT FOR (2*CLK_PER + CLK_STIM);
    RSTxRI <= '0';
    WAIT;
  END PROCESS p_reset;




END tb;
