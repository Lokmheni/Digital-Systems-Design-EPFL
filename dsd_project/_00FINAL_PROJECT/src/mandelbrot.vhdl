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
    CLKxCI        : IN std_logic;
    RSTxRI        : IN std_logic;
    ResetFramexSI : IN std_logic;
    NextFramexSI  : IN std_logic;

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
  SIGNAL Z_rexInitial     : signed(N_BITS+COORD_BW+1 DOWNTO 0);  -- real part of z
  SIGNAL Z_imxInitial     : signed(N_BITS+COORD_BW+1 DOWNTO 0);  -- imaginary part of z
  SIGNAL IterCntxD        : unsigned(MEM_DATA_BW-1 DOWNTO 0);  -- we need 7 bits for 100 iteratins, Im using 8 bits so we could go up to 255 iterations
  SIGNAL IterCntSyncRstxS : std_logic;
  SIGNAL IterDonexS       : std_logic;  -- basically WE
  --SIGNAL N_iter         : unsigned(COORD_BW DOWNTO 0); -- number of iterations

  --intermediate signals
  SIGNAL Z_re_multxN           : signed(N_BITS+1 DOWNTO 0);    -- Z_rexP*2
  SIGNAL z_rerexD_Q6_30        : signed(2*N_bits+1 DOWNTO 0);  -- re_re*z_re
  SIGNAL Z_imimxD_Q6_30        : signed(2*N_bits+1 DOWNTO 0);  -- z_im*z_im
  SIGNAL z_reimxD_Q6_30        : signed(2*N_bits+1 DOWNTO 0);  -- z_im*z_re
  SIGNAL z_re2_min_im2xD_Q6_30 : signed(2*N_bits+1 DOWNTO 0);  -- z_rerexD_Q6_30-z_imimxD_Q6_30

  SIGNAL z_rexN_q4_15     : signed(N_BITS+1 DOWNTO 0);  -- intermediate signal to
                                                        -- counteract overflos
  SIGNAL ZAbsSqrdxD_Q6_30 : unsigned(2*N_BITS+1 DOWNTO 0);  -- |z|^2 with Q6,30 bit fraction

  --zooming signals
  SIGNAL ReStartValxDP : signed(N_BITS DOWNTO 0);
  SIGNAL ReStartValxDN : signed(N_BITS DOWNTO 0);
  SIGNAL ImStartValxDP : signed(N_BITS DOWNTO 0);
  SIGNAL ImStartValxDN : signed(N_BITS DOWNTO 0);

  SIGNAL ReIncxDP  : signed(N_BITS DOWNTO 0);
  SIGNAL ReIncxDN  : signed(N_BITS DOWNTO 0);
  SIGNAL ImIncxDP  : signed(N_BITS DOWNTO 0);
  SIGNAL ImIncxDN  : signed(N_BITS DOWNTO 0);
  SIGNAL ZoomEn    : std_logic;
  SIGNAL ZoomInxSN : std_logic;  -- '1' when zooming in , '0' when zooming out
  SIGNAL ZoomInxSP : std_logic;




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
        IF XcounterxD+1 < HS_DISPLAY/4 THEN
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
        IF YcounterxD+1 < VS_DISPLAY/4 THEN
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



  CountXOverflowxS <= '1' WHEN XcounterxD = HS_DISPLAY/4 - 1 ELSE  -- this is fine
                      '0';
  CountYOverflowxS <= '1' WHEN YcounterxD = VS_DISPLAY/4 - 1 ELSE
                      '0';




  -- normal register process
  z_reg_proc : PROCESS (ALL) IS
  BEGIN  -- PROCESS CounterZ
    --RESET
    IF RSTxRI = '1' THEN                -- asynchronous reset (active high)
      Z_rexP        <= (OTHERS => '0');
      Z_imxP        <= (OTHERS => '0');
      ReStartValxDP <= C_RE_0;
      ImStartValxDP <= C_IM_0;
      ReIncxDP      <= C_RE_INC;
      ImIncxDP      <= C_IM_INC;
      ZoomInxSP     <= '0';
    ELSIF CLKxCI'event AND CLKxCI = '1' THEN  -- rising clock edge
      Z_rexP        <= Z_rexN;
      Z_imxP        <= Z_imxN;
      ReStartValxDP <= ReStartValxDN;
      ImStartValxDP <= ImStartValxDN;
      ReIncxDP      <= ReIncxDN;
      ImIncxDP      <= ImIncxDN;
      ZoomInxSP     <= ZoomInxSN;
    END IF;
  END PROCESS z_reg_proc;


--x,y counter logic
  CntEnXxS <= IterDonexS;
  CntEnYxS <= '1' WHEN CountXOverflowxS = '1' AND IterDonexS = '1' ELSE
              '0';


  -- zoom logic
  zoomlogic : PROCESS (ALL) IS
  BEGIN  -- PROCESS zoomlogic
    --default
    ReStartValxDN <= ReStartValxDP;
    ImStartValxDN <= ImStartValxDP;
    ReIncxDN      <= ReIncxDP;
    ImIncxDN      <= ImIncxDP;
    ZoomInxSN     <= ZoomInxSP;
    --logic zoom diraction
    IF ImIncxDP = C_ZOOM_LIMIT OR ReIncxDP = C_ZOOM_LIMIT THEN
      ZoomInxSN <= '0';
    ELSIF ReStartValxDP = C_RE_0 OR ImStartValxDP = C_IM_0 THEN
      ZoomInxSN <= '1';
    END IF;
    --logic zoom factor
    IF ResetFramexSI = '1' THEN
      ReStartValxDN <= C_RE_0;
      ImStartValxDN <= C_IM_0;
      ReIncxDN      <= C_RE_INC;
      ImIncxDN      <= C_IM_INC;
    ELSIF NextFramexSI = '1' THEN
      ReStartValxDN <= ReStartValxDP + C_RE_0_INCSTEP WHEN ZoomInxSP = '1' ELSE
                       ReStartValxDP - C_RE_0_INCSTEP;
      ImStartValxDN <= ImStartValxDP + C_IM_0_INCSTEP WHEN ZoomInxSP = '1' ELSE
                       ImStartValxDP - C_IM_0_INCSTEP;
      ReIncxDN <= ReIncxDP + C_RE_INC_INCSTEP WHEN ZoomInxSP = '1' ELSE
                  ReIncxDP - C_RE_INC_INCSTEP;
      ImIncxDN <= ImIncxDP + C_IM_INC_INCSTEP WHEN ZoomInxSP = '1' ELSE
                  ImIncxDP - C_IM_INC_INCSTEP;
    ELSE
      ReStartValxDN <= ReStartValxDP;
      ImStartValxDN <= ImStartValxDP;
      ReIncxDN      <= ReIncxDP;
      ImIncxDN      <= ImIncxDP;
    END IF;
  END PROCESS zoomlogic;




  --iteration logic:
  Z_rexInitial <= ReIncxDP * signed('0'&XcounterxD) + ReStartValxDP;  --sign bit to 0
  Z_imxInitial <= ImIncxDP * signed('0'&YcounterxD) + ImStartValxDP;  --sign bit to 0



--calculate next Z:
  Z_re_multxN           <= Z_imxP&'0';                       --x2 unused rn
  z_rerexD_Q6_30        <= Z_rexP * Z_rexP;
  Z_imimxD_Q6_30        <= Z_imxP*Z_imxP;
  z_reimxD_Q6_30        <= Z_rexP*Z_imxP;
  z_re2_min_im2xD_Q6_30 <= z_rerexD_Q6_30 - Z_imimxD_Q6_30;  --Q6,15
  ZoomEn                <= '1' WHEN IterDonexS = '1' AND XcounterxD = 0 AND YcounterxD = 0 ELSE
            '0';


  z_rexN_q4_15 <= signed(z_reimxD_Q6_30(2*N_BITS) & z_reimxD_Q6_30(2*N_BITS-3 DOWNTO N_FRAC-1)) + signed(Z_imxInitial(N_BITS+COORD_BW)&Z_imxInitial(N_BITS DOWNTO 0));  --2*Zreim +ziminit
  --real tahing
  Z_rexN       <= Z_rexInitial(N_BITS+COORD_BW)& Z_rexInitial(N_BITS-1 DOWNTO 0)
            WHEN IterDonexS = '1' ELSE
            signed(z_re2_min_im2xD_Q6_30(2*N_BITS)&z_re2_min_im2xD_Q6_30(2*N_BITS-3 DOWNTO N_FRAC)) + signed(Z_rexInitial(N_BITS+COORD_BW)&Z_rexInitial(N_BITS-1 DOWNTO 0));

  Z_imxN <= Z_imxInitial(N_BITS+COORD_BW) & Z_imxInitial(N_BITS-1 DOWNTO 0) WHEN IterDonexS = '1' ELSE
            z_rexN_q4_15(N_BITS) & z_rexN_q4_15(N_BITS-1 DOWNTO 0);



  ZAbsSqrdxD_Q6_30 <= unsigned(z_rerexD_Q6_30+z_imimxD_Q6_30);

  IterDonexS <= '1' WHEN ZAbsSqrdxD_Q6_30(2*N_BITS+1 DOWNTO 2*N_BITS-4) > 4 OR IterCntxD = MAX_ITER ELSE
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
