!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of cpf in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: *temp *pres cpf
!   with respect to varying inputs: *temp *pres
!   Plus diff mem management of: temp:in pres:in
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
!> @brief cpf(i,j,k,ismpl) calculates the isobaric heat capacity in (in J/kg/K)
!> @param[in] i cell index, direction I0
!> @param[in] j cell index, direction J0
!> @param[in] k cell index, direction K0
!> @param[in] ismpl local sample index
!> @return cpf  [J/kg/K]
!> @details
!> cpf(i,j,k,ismpl) calculates the isobaric heat capacity in (in
!> J/kg/K)\n of pure water, given temperature (t, in C), and
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
!> temperature   15 - 350 degC\n
SUBROUTINE CPF_AD(i, j, k, ismpl, cpf_adv)
  use arrays
  USE ARRAYS_AD
  USE MOD_FLOW, ONLY : pa_conv1
  IMPLICIT NONE
  double precision :: cpf_adv
! Location indices
  INTEGER, INTENT(IN) :: i
  INTEGER, INTENT(IN) :: j
  INTEGER, INTENT(IN) :: k
! Sample index
  INTEGER :: ismpl
! Temperature (degC)
  DOUBLE PRECISION :: tlocal
  DOUBLE PRECISION :: tlocal_ad
! Pressure (MPa)
  DOUBLE PRECISION :: plocal
  DOUBLE PRECISION :: plocal_ad
! Enthalpy (J/kg)
  DOUBLE PRECISION :: enth
! Derivative of enthalpy wrt T (J/kg/K)
  DOUBLE PRECISION :: denthdt
  DOUBLE PRECISION :: denthdt_ad
! Monomials of temperature and pressure
  DOUBLE PRECISION :: t, t2, t3
  DOUBLE PRECISION :: t_ad, t2_ad, t3_ad
  DOUBLE PRECISION :: p, p2, p3, p4
  DOUBLE PRECISION :: p_ad, p2_ad, p3_ad
  DOUBLE PRECISION :: tp, t2p, tp2
  DOUBLE PRECISION :: tp_ad, t2p_ad, tp2_ad
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
  DOUBLE PRECISION :: ta_ad, tb_ad
! Derivative of numerator wrt T
  DOUBLE PRECISION :: da
  DOUBLE PRECISION :: da_ad
! Derivative of denominator wrt T
  DOUBLE PRECISION :: db
  DOUBLE PRECISION :: db_ad
! Denominator squared
  DOUBLE PRECISION :: b2
  DOUBLE PRECISION :: b2_ad
  DOUBLE PRECISION :: temporary_ad
  DOUBLE PRECISION :: cpf
! Local Pressure in MPa
  plocal = pres(i, j, k, ismpl)*pa_conv1
! Local Temperature in degC
  tlocal = temp(i, j, k, ismpl)
! Temperature out of bounds
  IF (tlocal .GT. 360.0d0) THEN
    STOP
  ELSE IF (tlocal .LT. 0.0d0) THEN
! Relax table boundary of 15degC to error boundary 0degC
    STOP
  ELSE IF (plocal .GT. 110.0d0) THEN
! Pressure out of bounds
    STOP
  ELSE IF (plocal .LT. 0.001d0) THEN
    STOP
  ELSE
! Compute monomials in pressure and temperature
    p = plocal
    t = tlocal
    p2 = p*p
    p3 = p2*p
    t2 = t*t
    t3 = t2*t
    tp = p*t
    tp2 = t*p2
    t2p = t2*p
! Numerator of rational function approximation
    ta = y0 + y1*p + y2*p2 + y3*p3 + y4*t + y5*t2 + y6*t3 + y7*tp + y8*&
&     tp2 + y9*t2p
! Denominator of rational function approximation
    tb = z0 + z1*p + z2*p2 + z3*p3 + z4*t + z5*t2 + z6*t3 + z7*tp + z8*&
&     tp2 + z9*t2p
! Enthalpy
! Derivative of numerator
    da = y4 + 2.0d0*y5*t + 3.0d0*y6*t2 + y7*p + y8*p2 + 2.0d0*y9*tp
! Derivative of denominator
    db = z4 + 2.0d0*z5*t + 3.0d0*z6*t2 + z7*p + z8*p2 + 2.0d0*z9*tp
! Denominator squared
    b2 = tb*tb
! Derivative, quotient rule
! Isobaric heat capacity (J/kg/K)
    denthdt_ad = 1.0d6*cpf_adv
    da_ad = denthdt_ad/tb
    temporary_ad = -(denthdt_ad/b2)
    ta_ad = db*temporary_ad
    db_ad = ta*temporary_ad
    b2_ad = -(ta*db*temporary_ad/b2)
    tb_ad = 2*tb*b2_ad - da*denthdt_ad/tb**2
    tp_ad = z9*2.0d0*db_ad + y9*2.0d0*da_ad + z7*tb_ad + y7*ta_ad
    p3_ad = z3*tb_ad + y3*ta_ad
    t3_ad = z6*tb_ad + y6*ta_ad
    tp2_ad = z8*tb_ad + y8*ta_ad
    p2_ad = z8*db_ad + y8*da_ad + z2*tb_ad + y2*ta_ad + t*tp2_ad + p*&
&     p3_ad
    t2p_ad = z9*tb_ad + y9*ta_ad
    t2_ad = z6*3.0d0*db_ad + y6*3.0d0*da_ad + z5*tb_ad + y5*ta_ad + p*&
&     t2p_ad + t*t3_ad
    t_ad = z5*2.0d0*db_ad + y5*2.0d0*da_ad + z4*tb_ad + y4*ta_ad + p2*&
&     tp2_ad + p*tp_ad + t2*t3_ad + 2*t*t2_ad
    p_ad = z7*db_ad + y7*da_ad + z1*tb_ad + y1*ta_ad + t2*t2p_ad + t*&
&     tp_ad + p2*p3_ad + 2*p*p2_ad
    tlocal_ad = t_ad
    plocal_ad = p_ad
    temp_ad(i, j, k, ismpl) = temp_ad(i, j, k, ismpl) + tlocal_ad
    pres_ad(i, j, k, ismpl) = pres_ad(i, j, k, ismpl) + pa_conv1*&
&     plocal_ad
  END IF
END SUBROUTINE CPF_AD
