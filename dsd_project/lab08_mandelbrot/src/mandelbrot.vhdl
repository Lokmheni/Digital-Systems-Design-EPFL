--=============================================================================
-- @file mandelbrot.vhdl
--=============================================================================
-- Standard library
LIBRARY ieee;
-- Standard packages
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
-- Packages
LIBRARY work;
USE work.dsd_prj_pkg.ALL;

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
ENTITY mandelbrot IS
  PORT (
    CLKxCI : IN std_logic;
    RSTxRI : IN std_logic;

    WExSO   : OUT std_logic;  -- write enable (==1 when number of iterations approached)
    XxDO    : OUT unsigned(COORD_BW - 1 DOWNTO 0);
    YxDO    : OUT unsigned(COORD_BW - 1 DOWNTO 0);
    ITERxDO : OUT unsigned(MEM_DATA_BW - 1 DOWNTO 0)  -- number of iterations
    );
END ENTITY mandelbrot;

--=============================================================================
-- ARCHITECTURE DECLARATION
--=============================================================================
ARCHITECTURE rtl OF mandelbrot IS

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
  SIGNAL CountXOverflowxS : std_logic;  -- Phys X counter overflow
  SIGNAL CountYOverflowxS : std_logic;  -- Phys Y Counter overflow
  SIGNAL Z_rexN           : signed(N_BITS DOWNTO 0);  -- real part of z
  SIGNAL Z_imxN           : signed(N_BITS DOWNTO 0);  -- real part of z
  SIGNAL Z_rexP           : signed(N_BITS DOWNTO 0);
  SIGNAL Z_imxP           : signed(N_BITS DOWNTO 0);  -- imaginary part of z
  SIGNAL Z_rexInitial     : signed(N_BITS DOWNTO 0);  -- real part of z
  SIGNAL Z_imxInitial     : signed(N_BITS DOWNTO 0);  -- real part of z
  SIGNAL IterCntxD        : unsigned(MEM_DATA_BW-1 DOWNTO 0);  -- we need 7 bits for 100 iteratins, Im using 8 bits so we could go up to 255 iterations
  SIGNAL IterCntSyncRstxS : std_logic;
  SIGNAL IterDonexS       : std_logic;  -- basically WE
  --SIGNAL N_iter         : unsigned(COORD_BW DOWNTO 0); -- number of iterations

  --intermediate signals
  SIGNAL Z_re_multxN : signed(N_BITS+1 DOWNTO 0);    -- Z_rexP*2
  SIGNAL z_rere      : signed(2*N_bits+1 DOWNTO 0);  -- re_re*z_re
  SIGNAL Z_imim      : signed(2*N_bits+1 DOWNTO 0);  -- z_im*z_im
  SIGNAL z_reim      : signed(2*N_bits+1 DOWNTO 0);  -- z_im*z_re



--=============================================================================
-- ARCHITECTURE BEGIN
--=============================================================================
BEGIN




  -- purpose: This is the x counter register
  -- type   : sequential
  -- inputs : CLKxCI, RSTxRI
  -- outputs: 
  CounterX_proc : PROCESS (CLKxCI, RSTxRI) IS
  BEGIN  -- PROCESS CounterX_proc
    IF RSTxRI = '1' THEN                -- asynchronous reset (active high)
      XcounterxD <= (OTHERS => '0');
    ELSIF CLKxCI'event AND CLKxCI = '1' THEN  -- rising clock edge
      IF CntEnXxS = '1' THEN
        IF XcounterxD+1 < HS_DISPLAY THEN
          XcounterxD <= XcounterxD+1;
        ELSE
          XcounterxD <= (OTHERS => '0');
        END IF;
      END IF;
    END IF;
  END PROCESS CounterX_proc;


  -- purpose: This is the y counter register
  -- type   : sequential
  -- inputs : CLKxCI, RSTxR
  -- outputs: 
  CounterY_proc : PROCESS (CLKxCI, RSTxRI) IS
  BEGIN  -- PROCESS CounterX_proc
    IF RSTxRI = '1' THEN                -- asynchronous reset (active high)
      YcounterxD <= (OTHERS => '0');
    ELSIF CLKxCI'event AND CLKxCI = '1' THEN  -- rising clock edge
      IF CntEnYxS = '1' THEN
        IF YcounterxD+1 < VS_DISPLAY THEN
          YcounterxD <= YcounterxD+1;
        ELSE
          YcounterxD <= (OTHERS => '0');
        END IF;
      END IF;
    END IF;
  END PROCESS CounterY_proc;


-- purpose: count iterations (always counts, except if sync/async rst is high
-- type   : sequential
-- inputs : CLKxCI, RSTxRI
-- outputs: 
  iteration_counter_process : PROCESS (CLKxCI, RSTxRI) IS
  BEGIN  -- PROCESS iteration_counter_process
    IF RSTxRI = '1' THEN                -- asynchronous reset (active high)
      IterCntxD <= (OTHERS => '0');
    ELSIF CLKxCI'event AND CLKxCI = '1' THEN  -- rising clock edge
      IF IterCntSyncRstxS = '0' THEN
        IterCntxD <= IterCntxD + 1;
      ELSE
        IterCntxD <= (OTHERS => '0');
      END IF;
    END IF;
  END PROCESS iteration_counter_process;



  CountXOverflowxS <= '1' WHEN XcounterxD = HS_DISPLAY - 1 ELSE  -- this is fine
                      '0';
  CountYOverflowxS <= '1' WHEN YcounterxD = VS_DISPLAY - 1 ELSE
                      '0';




  -- normal register process, this is fine
  z_reg_proc : PROCESS (ALL) IS
  BEGIN  -- PROCESS CounterZ
    --RESET
    IF RSTxRI = '1' THEN                -- asynchronous reset (active high)
      Z_rexP <= (OTHERS => '0');
      Z_imxP <= (OTHERS => '0');
    ELSIF CLKxCI'event AND CLKxCI = '1' THEN  -- rising clock edge
      Z_rexP <= Z_rexN;
      Z_imxP <= Z_imxN;
    END IF;
  END PROCESS z_reg_proc;


--x,y counter logic
  CntEnXxS <= IterDonexS;
  CntEnYxS <= '1' WHEN CountXOverflowxS = '1' AND IterDonexS = '1' ELSE
              '0';


  --iteration logic:

  Z_rexInitial <= resize(C_RE_INC * signed(XcounterxD), N_BITS+1) + C_RE_0;  --sign bit to 0
  Z_imxInitial <= resize(C_IM_INC * signed(YcounterxD), N_BITS+1) + C_IM_0;  --sign bit to 0




  Z_re_multxN <= Z_imxP&'0';            --x2
  z_rere      <= Z_rexP * Z_rexP;
  Z_imim      <= Z_imxP*Z_imxP;
  z_reim      <= Z_rexP*Z_imxP;

  Z_rexN <= Z_rexInitial WHEN IterDonexS = '1' ELSE
            z_rere(N_BITS+N_FRAC+1 DOWNTO N_FRAC+1) - Z_imim(N_BITS+N_FRAC+1 DOWNTO N_FRAC+1) + Z_rexInitial;
  Z_imxN <= Z_imxInitial WHEN IterDonexS = '1' ELSE
            z_reim(N_BITS+N_FRAC+2 DOWNTO N_FRAC+2) + Z_imxInitial;  --2*Zreim +ziminit



--when done?
  IterDonexS <= '1' WHEN (Z_rexP * Z_rexP + Z_imxP * Z_imxP > ITER_LIM) OR IterCntxD = MAX_ITER ELSE
                '0';
  IterCntSyncRstxS <= IterDonexS;




-- output assignements (can be done directly, since they are all counter
-- registers dircltly
  XxDO    <= XcounterxD;
  YxDO    <= YcounterxD;
  ITERxDO <= IterCntxD;
  WExSO   <= IterDonexS;
END ARCHITECTURE rtl;
--=============================================================================
-- ARCHITECTURE END
--=============================================================================
