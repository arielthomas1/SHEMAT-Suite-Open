!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of cpw in forward (tangent) mode:
!   variations   of useful results: cpw
!   with respect to varying inputs: p t
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
!> @brief cpf(i,j,k,ismpl) calculates the isobaric heat capacity of water in (in J/kg/K)
!> @param[in] p pressure [MPa]
!> @param[in] t temporaryerature [degC]
!> @return cpf  [J/kg/K]
!> @details
!> cpf(i,j,k,ismpl) calculates the isobaric heat capacity in (in
!> J/kg/K)\n of pure water, given temporaryerature (t, in C), and
!> pressure (p,in Pa)\n at node(i,j,k).\n \n
!>
!> method: c_p = d/dT E, E= fluid enthalpy.\n \n
!>
!>  Main source Zyvoloski1997: \n
!>
!> Zyvoloski, G.A., Robinson, B.A., Dash, Z.V., & Trease, L.L. Summary
!> of the models and methods for the FEHM application - a
!> finite-element heat- and mass-transfer code. United
!> States. doi:10.2172/565545. \n \n
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
!> range of validity:\n
!> pressures      0.001 - 110 MPa,\n
!> temporaryerature   15 - 350 degC\n
DOUBLE PRECISION FUNCTION g_CPW(p, g_p, t, g_t, cpw)
  IMPLICIT NONE
! Input Pressure (MPa)
  DOUBLE PRECISION, INTENT(IN) :: p
  DOUBLE PRECISION, INTENT(IN) :: g_p
! Input Temperature (degC)
  DOUBLE PRECISION, INTENT(IN) :: t
  DOUBLE PRECISION, INTENT(IN) :: g_t
! Enthalpy (J/kg)
  DOUBLE PRECISION :: enth
! Derivative of enthalpy wrt T (J/kg/K)
  DOUBLE PRECISION :: denthdt
  DOUBLE PRECISION :: g_denthdt
! Monomials of temporaryerature and pressure
  DOUBLE PRECISION :: t2, t3
  DOUBLE PRECISION :: g_t2, g_t3
  DOUBLE PRECISION :: p2, p3, p4
  DOUBLE PRECISION :: g_p2, g_p3
  DOUBLE PRECISION :: tp, t2p, tp2
  DOUBLE PRECISION :: g_tp, g_t2p, g_tp2
! Coefficients of numerator of rational function approximation
  DOUBLE PRECISION, PARAMETER :: y0=0.25623465d-3
  DOUBLE PRECISION, PARAMETER :: y1=0.10184405d-2
  DOUBLE PRECISION, PARAMETER :: y2=0.22554970d-4
  DOUBLE PRECISION, PARAMETER :: y3=0.34836663d-7
  DOUBLE PRECISION, PARAMETER :: y4=0.41769866d-2
  DOUBLE PRECISION, PARAMETER :: y5=-0.21244879d-4
  DOUBLE PRECISION, PARAMETER :: y6=0.25493516d-7
  DOUBLE PRECISION, PARAMETER :: y7=0.89557885d-4
  DOUBLE PRECISION, PARAMETER :: y8=0.10855046d-6
  DOUBLE PRECISION, PARAMETER :: y9=-0.21720560d-6
! Coefficients of denominator of rational function approximation
  DOUBLE PRECISION, PARAMETER :: z0=0.10000000d+1
  DOUBLE PRECISION, PARAMETER :: z1=0.23513278d-1
  DOUBLE PRECISION, PARAMETER :: z2=0.48716386d-4
  DOUBLE PRECISION, PARAMETER :: z3=-0.19935046d-8
  DOUBLE PRECISION, PARAMETER :: z4=-0.50770309d-2
  DOUBLE PRECISION, PARAMETER :: z5=0.57780287d-5
  DOUBLE PRECISION, PARAMETER :: z6=0.90972916d-9
  DOUBLE PRECISION, PARAMETER :: z7=-0.58981537d-4
  DOUBLE PRECISION, PARAMETER :: z8=-0.12990752d-7
  DOUBLE PRECISION, PARAMETER :: z9=0.45872518d-8
! Numerator and denominator of rational function approximation
  DOUBLE PRECISION :: ta, tb
  DOUBLE PRECISION :: g_ta, g_tb
! Derivative of numerator wrt T
  DOUBLE PRECISION :: da
  DOUBLE PRECISION :: g_da
! Derivative of denominator wrt T
  DOUBLE PRECISION :: db
  DOUBLE PRECISION :: g_db
! Denominator squared
  DOUBLE PRECISION :: b2
  DOUBLE PRECISION :: g_b2
  DOUBLE PRECISION :: temporary
  DOUBLE PRECISION :: cpw
! Temperature out of bounds
  IF (t .GT. 360.0d0) THEN
    WRITE(*, *) '[E1]: Error: Temperature (', t, &
&   ') out of bounds (> 360 degC).'
    STOP
  ELSE IF (t .LT. 0.0d0) THEN
! Relax table boundary of 15degC to error boundary 0degC
    WRITE(*, *) '[E2]: Error: Temperature (', t, &
&   ') out of bounds (< 0 degC).'
    STOP
  ELSE IF (p .GT. 110.0d0) THEN
! Pressure out of bounds
    WRITE(*, *) '[E3]: Error: Pressure (', p, &
&   ') out of bounds (> 110 MPa)'
    STOP
  ELSE IF (p .LT. 0.001d0) THEN
    WRITE(*, *) '[E4]: Error: Pressure (', p, &
&   ') out of bounds (< 0.001 MPa)'
    STOP
  ELSE
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
    g_tp2 = p2*g_t + t*g_p2
    tp2 = t*p2
    g_t2p = p*g_t2 + t2*g_p
    t2p = t2*p
! Numerator of rational function approximation
    g_ta = y1*g_p + y2*g_p2 + y3*g_p3 + y4*g_t + y5*g_t2 + &
&     y6*g_t3 + y7*g_tp + y8*g_tp2 + y9*g_t2p
    ta = y0 + y1*p + y2*p2 + y3*p3 + y4*t + y5*t2 + y6*t3 + y7*tp + y8*&
&     tp2 + y9*t2p
! Denominator of rational function approximation
    g_tb = z1*g_p + z2*g_p2 + z3*g_p3 + z4*g_t + z5*g_t2 + &
&     z6*g_t3 + z7*g_tp + z8*g_tp2 + z9*g_t2p
    tb = z0 + z1*p + z2*p2 + z3*p3 + z4*t + z5*t2 + z6*t3 + z7*tp + z8*&
&     tp2 + z9*t2p
! Enthalpy
    enth = ta/tb
! Derivative of numerator
    g_da = y5*2.0d0*g_t + y6*3.0d0*g_t2 + y7*g_p + y8*g_p2 + &
&     y9*2.0d0*g_tp
    da = y4 + 2.0d0*y5*t + 3.0d0*y6*t2 + y7*p + y8*p2 + 2.0d0*y9*tp
! Derivative of denominator
    g_db = z5*2.0d0*g_t + z6*3.0d0*g_t2 + z7*g_p + z8*g_p2 + &
&     z9*2.0d0*g_tp
    db = z4 + 2.0d0*z5*t + 3.0d0*z6*t2 + z7*p + z8*p2 + 2.0d0*z9*tp
! Denominator squared
    g_b2 = 2*tb*g_tb
    b2 = tb*tb
! Derivative, quotient rule
    temporary = ta*db/b2
    g_denthdt = (g_da-da*g_tb/tb)/tb - (db*g_ta+ta*g_db-temporary*&
&     g_b2)/b2
    denthdt = da/tb - temporary
! Isobaric heat capacity (J/kg/K)
    g_cpw = 1.0d6*g_denthdt
    cpw = denthdt*1.0d6
    RETURN
  END IF
END FUNCTION g_CPW

