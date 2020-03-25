!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of compw in forward (tangent) mode:
!   variations   of useful results: compw
!   with respect to varying inputs: t_h p_h
! MIT License
!
! Copyright (c) 2020 SHEMAT-Suite
!
! Permission is hereby granted, free of charge, to any person obtaining a copy
! of this software and associated documentation files (the "Software"), to deal
! in the Software without restriction, including without limitation the rights
! to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
! copies of the Software, and to permit persons to whom the Software is
! furnished to do so, subject to the following conditions:
!
! The above copyright notice and this permission notice shall be included in all
! copies or substantial portions of the Software.
!
! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
! IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
! FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
! AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
! LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
! OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
! SOFTWARE.
!> @brief compw calculates compressibility of pure water
!> @param[in] p_h pressure [MPa]
!> @param[in] t_h temporaryerature [degC]
!> @return  compressibility                     compw  [1./Pa]
!> @details
!> compw calculates compressibility of pure water [1/Pa]
!> given temporaryerature (t, in C), and pressure (p,in MPa)
!> at pressure/temporaryerature (p_h,t).\n \n
!>
!> Method: \n
!>
!> compw = 1/rhow d/dP rhow, \n
!>
!> where rhow= water density.\n \n
!>
!>  Main source Zyvoloski1997: \n
!>
!> Zyvoloski, G.A., Robinson, B.A., Dash, Z.V., & Trease, L.L. Summary
!> of the models and methods for the FEHM application - a
!> finite-element heat- and mass-transfer code. United
!> States. doi:10.2172/565545. \n \n
!>
!> See Section 8.4.3. of Zyvoloski1997 for an explanation of the
!> "Rational function approximation" used in this subroutine. \n \n
!> The approximation uses the table of coefficients in Appendix 10 of
!> Zyvoloski1997.\n
!>
!> Alternative source (same text, more modern, without doi): \n
!> https://fehm.lanl.gov/orgs/ees/fehm/pdfs/fehm_mms.pdf \n \n
!>
!> The table of coefficients from Zyvoloski1997 describes the physical
!> values found in Haar1984: \n
!>
!> Lester Haar, John Gallagher, George Kell, NBS/NRC Steam Tables:
!> Thermodynamic and Transport Properties and Computer Programs for
!> Vapor and Liquid States of Water in SI Units, Hemisphere Publishing
!> Corporation, Washington, 1984. \n \n
!>
!>    range of validity:\n
!>    - pressures   0.001 - 110 MPa,\n
!>    - temporaryerature   15 - 360 degC\n \n
!>
!> input:\n
!>   pressure                               p [MPa]\n
!>   temporaryerature                         t in [degC]\n
DOUBLE PRECISION FUNCTION g_COMPW(p_h, g_p_h, t_h, g_t_h, compw)
  USE MOD_FLOW
  IMPLICIT NONE
! Input Pressure (MPa)
  DOUBLE PRECISION :: p_h
  DOUBLE PRECISION :: g_p_h
! Input temporaryerature (degc)
  DOUBLE PRECISION :: t_h
  DOUBLE PRECISION :: g_t_h
! Monomials of temporaryerature and pressure
  DOUBLE PRECISION :: t, t2, t3
  DOUBLE PRECISION :: g_t, g_t2, g_t3
  DOUBLE PRECISION :: p, p2, p3, p4
  DOUBLE PRECISION :: g_p, g_p2, g_p3
  DOUBLE PRECISION :: tp, t2p, tp2
  DOUBLE PRECISION :: g_tp, g_t2p, g_tp2
! Coefficients of numerator of rational function approximation
  DOUBLE PRECISION, PARAMETER :: y0=0.10000000d+01
  DOUBLE PRECISION, PARAMETER :: y1=0.17472599d-01
  DOUBLE PRECISION, PARAMETER :: y2=-0.20443098d-04
  DOUBLE PRECISION, PARAMETER :: y3=-0.17442012d-06
  DOUBLE PRECISION, PARAMETER :: y4=0.49564109d-02
  DOUBLE PRECISION, PARAMETER :: y5=-0.40757664d-04
  DOUBLE PRECISION, PARAMETER :: y6=0.50676664d-07
  DOUBLE PRECISION, PARAMETER :: y7=0.50330978d-04
  DOUBLE PRECISION, PARAMETER :: y8=0.33914814d-06
  DOUBLE PRECISION, PARAMETER :: y9=-0.18383009d-06
! Coefficients of denominator of rational function approximation
  DOUBLE PRECISION, PARAMETER :: z0=0.10009476d-02
  DOUBLE PRECISION, PARAMETER :: z1=0.16812589d-04
  DOUBLE PRECISION, PARAMETER :: z2=-0.24582622d-07
  DOUBLE PRECISION, PARAMETER :: z3=-0.17014984d-09
  DOUBLE PRECISION, PARAMETER :: z4=0.48841156d-05
  DOUBLE PRECISION, PARAMETER :: z5=-0.32967985d-07
  DOUBLE PRECISION, PARAMETER :: z6=0.28619380d-10
  DOUBLE PRECISION, PARAMETER :: z7=0.53249055d-07
  DOUBLE PRECISION, PARAMETER :: z8=0.30456698d-09
  DOUBLE PRECISION, PARAMETER :: z9=-0.12221899d-09
! Numerator and denominator of rational function approximation
  DOUBLE PRECISION :: ta, tb
  DOUBLE PRECISION :: g_ta, g_tb
! Derivative of numerator wrt P
  DOUBLE PRECISION :: da
  DOUBLE PRECISION :: g_da
! Derivative of denominator wrt P
  DOUBLE PRECISION :: db
  DOUBLE PRECISION :: g_db
! Denominator squared
  DOUBLE PRECISION :: b2
  DOUBLE PRECISION :: g_b2
! Water density (local)
  DOUBLE PRECISION :: rhow_loc
  DOUBLE PRECISION :: g_rhow_loc
! Derivative of water density wrt P
  DOUBLE PRECISION :: drhodp
  DOUBLE PRECISION :: g_drhodp
! Compressibiliy in Mpa
  DOUBLE PRECISION :: compw_mpa
  DOUBLE PRECISION :: g_compw_mpa
  DOUBLE PRECISION :: temporary
  DOUBLE PRECISION :: compw
! pressure [MPa]
  g_p = g_p_h
  p = p_h
! temporaryerature [degC]
  g_t = g_t_h
  t = t_h
! Compute monomials in pressure and temporaryerature
  g_p2 = 2*p*g_p
  p2 = p*p
  g_p3 = p*g_p2 + p2*g_p
  p3 = p2*p
  p4 = p3*p
  g_t2 = 2*t*g_t
  t2 = t*t
  g_t3 = t*g_t2 + t2*g_t
  t3 = t2*t
  g_tp = t*g_p + p*g_t
  tp = p*t
  g_t2p = p*g_t2 + t2*g_p
  t2p = t2*p
  g_tp2 = p2*g_t + t*g_p2
  tp2 = t*p2
! Numerator of rational function approximation
  g_ta = y1*g_p + y2*g_p2 + y3*g_p3 + y4*g_t + y5*g_t2 + y6*&
&   g_t3 + y7*g_tp + y8*g_tp2 + y9*g_t2p
  ta = y0 + y1*p + y2*p2 + y3*p3 + y4*t + y5*t2 + y6*t3 + y7*tp + y8*tp2&
&   + y9*t2p
! Denominator of rational function approximation
  g_tb = z1*g_p + z2*g_p2 + z3*g_p3 + z4*g_t + z5*g_t2 + z6*&
&   g_t3 + z7*g_tp + z8*g_tp2 + z9*g_t2p
  tb = z0 + z1*p + z2*p2 + z3*p3 + z4*t + z5*t2 + z6*t3 + z7*tp + z8*tp2&
&   + z9*t2p
! Water density
  g_rhow_loc = (g_ta-ta*g_tb/tb)/tb
  rhow_loc = ta/tb
! Derivative of numerator
  g_da = y2*2.d0*g_p + y3*3.d0*g_p2 + y7*g_t + y8*2.d0*g_tp + &
&   y9*g_t2
  da = y1 + 2.d0*y2*p + 3.d0*y3*p2 + y7*t + 2.d0*y8*tp + y9*t2
! Derivative of denominator
  g_db = z2*2.d0*g_p + z3*3.d0*g_p2 + z7*g_t + z8*2.0*g_tp + &
&   z9*g_t2
  db = z1 + 2.d0*z2*p + 3.d0*z3*p2 + z7*t + 2.0*z8*tp + z9*t2
! Denominator squared
  g_b2 = 2*tb*g_tb
  b2 = tb*tb
! Derivative, quotient rule
  temporary = (da*tb-ta*db)/b2
  g_drhodp = (tb*g_da+da*g_tb-db*g_ta-ta*g_db-temporary*g_b2)/b2
  drhodp = temporary
! Compressibility: (1/rhow_loc) * drhodp [1/MPa]
  g_compw_mpa = (g_drhodp-drhodp*g_rhow_loc/rhow_loc)/rhow_loc
  compw_mpa = drhodp/rhow_loc
! Compressibility [1/Pa]
  g_compw = g_compw_mpa/pa_conv
  compw = compw_mpa/pa_conv
  RETURN
END FUNCTION g_COMPW
