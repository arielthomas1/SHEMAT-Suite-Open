!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of rhoceff in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: *temp *propunit *pres rhoceff
!   with respect to varying inputs: *temp *propunit *pres
!   Plus diff mem management of: temp:in propunit:in pres:in
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
!>    @brief calculates effective thermal conductivity of the two phase
!>    @param[in] i cell index, direction I0
!>    @param[in] j cell index, direction J0
!>    @param[in] k cell index, direction K0
!>    @param[in] ismpl local sample index
!>    @return  thermal conductivity                lz[W/(m*K)]
!>    @details
!>    calculates effective thermal conductivity of the two phase\n
!>    system matrix-porosity .\n
!>    input:\n
!>      porosity                            porlocal [-]\n
!>      pressure                            plocal [Mpa]\n
!>      temperature                         tlocal in [C]\n
SUBROUTINE RHOCEFF_AD(i, j, k, ismpl, rhoceff_adv)
  use arrays

  USE ARRAYS_AD

  USE ICE
  USE MOD_TEMP
  IMPLICIT NONE
  double precision :: rhoceff_adv
  INTEGER :: i, j, k, ui, ismpl
  DOUBLE PRECISION :: tlocal, rcsolid, rcfluid, rcice, porlocal, fm, fi&
& , ff
  DOUBLE PRECISION :: tlocal_ad, rcsolid_ad, rcfluid_ad, rcice_ad, &
& porlocal_ad, fm_ad, fi_ad, ff_ad
  DOUBLE PRECISION :: t0, theta, dtheta, w0
  DOUBLE PRECISION :: theta_ad, dtheta_ad
  EXTERNAL RHOCF, RHOCM, RHOCI, POR, RHOI, &
&     RHOF
  EXTERNAL RHOCF_AD, RHOCM_AD0, RHOCI_AD0, POR_AD, RHOF_AD
  DOUBLE PRECISION :: RHOCM, RHOCF, RHOCI, &
& POR, RHOI, RHOF
  INTRINSIC ABS
  DOUBLE PRECISION :: abs0
  DOUBLE PRECISION :: result1
  DOUBLE PRECISION :: result1_ad
  DOUBLE PRECISION :: temporary_ad
  DOUBLE PRECISION :: rhoceff
  tlocal = temp(i, j, k, ismpl)
  t0 = liq(i, j, k)
  IF (liq(i, j, k) - sol(i, j, k) .GE. 0.) THEN
    abs0 = liq(i, j, k) - sol(i, j, k)
  ELSE
    abs0 = -(liq(i, j, k)-sol(i, j, k))
  END IF
  w0 = abs0/2.d0
  CALL FTHETA(tlocal, t0, w0, theta, dtheta, ismpl)
  rcfluid = RHOCF(i, j, k, ismpl)
  rcice = RHOCI(i, j, k, ismpl)
  rcsolid = RHOCM(i, j, k, ismpl)
  porlocal = POR(i, j, k, ismpl)
  fm = 1.d0 - porlocal
  ff = porlocal*theta
  fi = porlocal - ff
!DM   Korrektur, 2008/02/21
  result1 = RHOF(i, j, k, ismpl)
  fi_ad = rcice*rhoceff_adv
  rcsolid_ad = fm*rhoceff_adv
  fm_ad = rcsolid*rhoceff_adv
  rcfluid_ad = ff*rhoceff_adv
  ff_ad = rcfluid*rhoceff_adv - fi_ad
  rcice_ad = fi*rhoceff_adv
  temporary_ad = lth*rhoceff_adv
  result1_ad = porlocal*dtheta*temporary_ad
  porlocal_ad = result1*dtheta*temporary_ad + fi_ad + theta*ff_ad - fm_ad
  dtheta_ad = result1*porlocal*temporary_ad
  CALL RHOF_AD(i, j, k, ismpl, result1_ad)
  theta_ad = porlocal*ff_ad
  CALL POR_AD(i, j, k, ismpl, porlocal_ad)
  CALL RHOCM_AD0(i, j, k, ismpl, rcsolid_ad)
  CALL RHOCI_AD0(i, j, k, ismpl, rcice_ad)
  CALL RHOCF_AD(i, j, k, ismpl, rcfluid_ad)
  tlocal_ad = 0.D0
  CALL FTHETA_AD(tlocal, tlocal_ad, t0, w0, theta, theta_ad, dtheta, &
&          dtheta_ad, ismpl)
  temp_ad(i, j, k, ismpl) = temp_ad(i, j, k, ismpl) + tlocal_ad
END SUBROUTINE RHOCEFF_AD

