--=============================================================================
-- @file mandelbrot.vhdl
--=============================================================================
-- Standard library
library ieee;
-- Standard packages
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Packages
library work;
use work.dsd_prj_pkg.all;

--=============================================================================
--
-- mandelbrot
--
-- @brief This file specifies a basic circuit for mandelbrot
--
--=============================================================================

--=============================================================================
-- ENTITY DECLARATION FOR MANDELBROT
--=============================================================================
entity mandelbrot is
  port (
    CLKxCI : in std_logic;
    RSTxRI : in std_logic;

    WExSO   : out std_logic;    -- write enable (==1 when number of iterations approached)
    XxDO    : out unsigned(COORD_BW - 1 downto 0);
    YxDO    : out unsigned(COORD_BW - 1 downto 0);
    ITERxDO : out unsigned(MEM_DATA_BW - 1 downto 0) -- number of iterations
  );
end entity mandelbrot;

--=============================================================================
-- ARCHITECTURE DECLARATION
--=============================================================================
architecture rtl of mandelbrot is

  -- TODO: Implement your own code here
-- GIVEN AT DESIGN TIME : MAX_ITER
--INPUTS : c_r , c_i ;
--OUTPUT: n ;
--z_r=c_r; 
--z_i=c_i;
--n = 1;
--While ((z_r * z_r + z_i * z_i) < 4 & n<MAX_ITER) {
--z_r� = z_r * z_r - z_i * z_i + c_r;
--z_i = 2 * z_r * z_i + c_i;
--z_r = z_r�;
--n = n + 1;
--}
-- asynchronous reset for the start
-- synchronous reset for the iteration
-- counter x,counter y, number of iterations
  SIGNAL XcounterxD       : unsigned(COORD_BW-1 DOWNTO 0);  -- Counter_value (physical x coordinate incl porch and pulse)
  SIGNAL YcounterxD       : unsigned(COORD_BW-1 DOWNTO 0);  -- Counter_value for y (physical)
  SIGNAL CntEnXxS         : std_logic;  -- Enable physical counter X
  SIGNAL CntEnYxS         : std_logic;  -- Enable physical counter Y
  SIGNAL CntEnZxS         : std_logic;
  SIGNAL CntMaxXxD        : unsigned(COORD_BW DOWNTO 0);  -- max value of counter x
  SIGNAL CntMaxYxD        : unsigned(COORD_BW DOWNTO 0);  -- max value of counter y
  SIGNAL CountXOverflowxS : std_logic;  -- Phys X counter overflow
  SIGNAL CountYOverflowxS : std_logic;  -- Phys Y Counter overflow
  SIGNAL Z_rexN           : unsigned(COORD_BW DOWNTO 0); -- real part of z
  SIGNAL Z_imxN           : unsigned(COORD_BW DOWNTO 0); -- real part of z
  SIGNAL Z_rexP           : unsigned(COORD_BW DOWNTO 0);
  SIGNAL Z_imxP           : unsigned(COORD_BW DOWNTO 0); -- imaginary part of z
  SIGNAL Z_re             : unsigned(COORD_BW DOWNTO 0);
  SIGNAL Z_im             : unsigned(COORD_BW DOWNTO 0);
  SIGNAL Z_rexInitial     : unsigned(COORD_BW DOWNTO 0); -- real part of z
  SIGNAL Z_imxInitial     : unsigned(COORD_BW DOWNTO 0); -- real part of z
  SIGNAL ITERxDN          : unsigned(MEM_DATA_BW - 1 downto 0);
  SIGNAL ITERxDP          : unsigned(MEM_DATA_BW - 1 downto 0);
  SIGNAL FINISHED_W       : std_logic;
  --SIGNAL N_iter         : unsigned(COORD_BW DOWNTO 0); -- number of iterations
    
--=============================================================================
-- ARCHITECTURE BEGIN
--=============================================================================
begin
CntMaxXxD <= to_unsigned(HS_DISPLAY + HS_FRONT_PORCH + HS_PULSE + HS_BACK_PORCH, CntMaxXxD'length);
CntMaxYxD <= to_unsigned(VS_DISPLAY + VS_FRONT_PORCH + VS_PULSE + VS_BACK_PORCH, CntMaxYxD'length);

FINISHED_W <= '1' WHEN ITERxDP = MAX_ITER OR Z_rexP * Z_rexP + Z_imxP * Z_imxP = ITER_LIM
    ELSE '0';

CounterRegisters : PROCESS (CLKxCI, RSTxRI) IS
  BEGIN  -- PROCESS CounterRegisters
    
    --RESET
    IF RSTxRI = '1' THEN                -- asynchronous reset (active high)
      XcounterxD <= (OTHERS => '0');
      YcounterxD <= (OTHERS => '0');
    ELSIF CLKxCI'event AND CLKxCI = '1' THEN  -- rising clock edge
      IF CntEnXxS = '1' THEN
        XcounterxD <= XcounterxD +1 WHEN XcounterxD +1 < CntMaxXxD ELSE
                      (OTHERS => '0');
      END IF;
      -- count Y
      IF CntEnYxS = '1' THEN
        YcounterxD <= YcounterxD + 1 WHEN YcounterxD + 1 < CntMaxYxD ELSE
                      (OTHERS => '0');
      END IF;
    END IF;
  END PROCESS CounterRegisters;
  
  CountXOverflowxS <= '1' WHEN XcounterxD = CntMaxXxD - 1 ELSE
                      '0';
  CountYOverflowxS <= '1' WHEN YcounterxD = CntMaxYxD - 1 ELSE
                      '0';
  CntEnXxS <= not FINISHED_W;

  CntEnYxS <= CountXOverflowxS;
  
  XxDO <= XcounterxD;
  YxDO <= YcounterxD;
  
  Z_rexInitial <= unsigned(unsigned(C_RE_INC(N_BITS-1 DOWNTO 0)) * XcounterxD(COORD_BW-1 DOWNTO 0) + unsigned(C_RE_0(N_BITS-1 DOWNTO 0)));
  Z_imxInitial <= unsigned(unsigned(C_IM_INC(N_BITS-1 DOWNTO 0)) * YcounterxD(COORD_BW-1 DOWNTO 0) + unsigned(C_IM_0(N_BITS-1 DOWNTO 0)));
  --ITERxDN <= ITERxDO;
  
  ITERxDN <= (OTHERS => '0') WHEN FINISHED_W = '1'
    ELSE ITERxDP + 1;
  
  --ITERxDN <= ITERxDP + 1    WHEN  ITERxDP < MAX_ITER
  --ELSE 0 WHEN CntEnxD
    --ELSE  ITERxDP;--- todo set to zero when done
    
CounterZ : PROCESS (ALL) IS
  BEGIN  -- PROCESS CounterZ
    --RESET
    IF RSTxRI = '1' THEN                -- asynchronous reset (active high)
      Z_rexP <= (OTHERS => '0');
      Z_imxP <= (OTHERS => '0');
      ITERxDP <= (OTHERS => '0');
    ELSIF CLKxCI'event AND CLKxCI = '1' THEN  -- rising clock edge
        IF CntEnZxS = '1' AND ITERxDP < MAX_ITER  THEN
            Z_rexP <= Z_rexN;
            Z_imxP <= Z_imxN;
            ITERxDP <= ITERxDN;
           --Z_rexP <=  Z_re_temp                            
        END IF;
    END IF;
  END PROCESS CounterZ;
  CntEnZxS <= '0' WHEN FINISHED_W = '1'
    ELSE '1';
  --IF(Z_rexP * Z_rexP + Z_imxP * Z_imxP < 4)   THEN
  ITERxDO <= ITERxDP;
  WExSO <= '0'   WHEN  FINISHED_W = '1'
    ELSE '1';  
  Z_rexN <= Z_rexInitial WHEN FINISHED_W = '1'
    ELSE unsigned(Z_rexP * Z_rexP - Z_imxP * Z_imxP + unsigned(C_RE_0(N_BITS-1 DOWNTO 0)));
  Z_imxN <= Z_imxInitial WHEN FINISHED_W = '1'
    ELSE unsigned(2 * Z_imxP * Z_rexP + unsigned(C_IM_0(N_BITS-1 DOWNTO 0)));
  
  -- TODO: Implement your own code here
  -- lokman does not know how to proceed :((((
  -- now it's getting better :))
  -- IT'S GETTING SHIT AGAIN :((((
end architecture rtl;
--=============================================================================
-- ARCHITECTURE END
--=============================================================================
