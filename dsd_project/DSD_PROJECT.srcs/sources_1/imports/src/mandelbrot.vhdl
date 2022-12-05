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
--z_r’ = z_r * z_r - z_i * z_i + c_r;
--z_i = 2 * z_r * z_i + c_i;
--z_r = z_r’;
--n = n + 1;
--}
-- asynchronous reset for the start
-- synchronous reset for the iteration
-- counter x,counter y, number of iterations
  SIGNAL XcounterxD       : unsigned(COORD_BW DOWNTO 0);  -- Counter_value (physical x coordinate incl porch and pulse)
  SIGNAL YcounterxD       : unsigned(COORD_BW DOWNTO 0);  -- Counter_value for y (physical)
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
  --SIGNAL N_iter         : unsigned(COORD_BW DOWNTO 0); -- number of iterations
    
--=============================================================================
-- ARCHITECTURE BEGIN
--=============================================================================
begin
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
  
CounterZ : PROCESS (CLKxCI, RSTxRI) IS
  BEGIN  -- PROCESS CounterZ
    Z_rexN <= unsigned(unsigned(C_RE_INC(N_BITS-1 DOWNTO 0)) * XcounterxD(COORD_BW-1 DOWNTO 0) + unsigned(C_RE_0(N_BITS-1 DOWNTO 0)));
    Z_imxN <= unsigned(unsigned(C_IM_INC(N_BITS-1 DOWNTO 0)) * YcounterxD(COORD_BW-1 DOWNTO 0) + unsigned(C_IM_0(N_BITS-1 DOWNTO 0)));
    --RESET
    IF RSTxRI = '1' THEN                -- asynchronous reset (active high)
      Z_rexN <= (OTHERS => '0');
      Z_imxN <= (OTHERS => '0');
       
    ELSIF CLKxCI'event AND CLKxCI = '1' THEN  -- rising clock edge
        IF CntEnZxS = '1' AND ITERxDO < MAX_ITER  THEN
            Z_rexP <= unsigned(Z_rexN * Z_rexN - Z_imxN * Z_imxN + unsigned(C_RE_0(N_BITS-1 DOWNTO 0)))
            Z_imxP <= unsigned(2 * Z_imxN * Z_rexN + unsigned(C_IM_0(N_BITS-1 DOWNTO 0)))
            --Z_rexP <=  Z_re_temp 
            ITERxDO <= ITERxDO + 1    WHEN(Z_rexN * Z_rexN + Z_imxN * Z_imxN < 4); 
        ELSIF ITERxDO = MAX_ITER THEN
            WExSO <= '1'   WHEN  Z_rexN * Z_rexN + Z_imxN * Z_imxN < 4   ELSE
                           (OTHERS => '0');
        END IF;
    END IF;
  END PROCESS CounterZ;
    
  
  
  
 
  -- TODO: Implement your own code here
  -- lokman does not know how to proceed :((((
  
end architecture rtl;
--=============================================================================
-- ARCHITECTURE END
--=============================================================================
