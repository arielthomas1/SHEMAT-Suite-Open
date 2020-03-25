!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of lx in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: *temp *propunit lx
!   with respect to varying inputs: *temp *propunit
!   Plus diff mem management of: temp:in propunit:in
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
!>    @return  thermal conductivity                lx[W/(m*K)]
!>    @details
!>    calculates effective thermal conductivity of the two phase\n
!>    system matrix-porosity .\n
!>    input:\n
!>      porosity                            porlocal [-]\n
!>      pressure                            plocal [pa]\n
!>      temperature                         tlocal in [C]\n
SUBROUTINE LX_AD(i, j, k, ismpl, lx_adv)
  use arrays

  USE ARRAYS_AD

  USE MOD_TEMP
  IMPLICIT NONE
  double precision :: lx_adv
  INTEGER :: i, j, k, ui, ismpl
  EXTERNAL LAMF, LAMM
  EXTERNAL LAMF_AD, LAMM_AD
  DOUBLE PRECISION :: plocal, tlocal, fluid, lamunit, LAMF, &
& porlocal, LAMM
  DOUBLE PRECISION :: tlocal_ad, fluid_ad, lamunit_ad, porlocal_ad
  DOUBLE PRECISION :: temp0
  DOUBLE PRECISION :: temp1
  DOUBLE PRECISION :: lx
!      ploCal = pres(i,j,k,ismpl)*Pa_Conv1
  tlocal = temp(i, j, k, ismpl)
  fluid = LAMF(i, j, k, ismpl)
  ui = uindex(i, j, k)
  porlocal = propunit(ui, idx_por, ismpl)
  lamunit = propunit(ui, idx_lz, ismpl)*propunit(ui, idx_an_lx, ismpl)
!         lx=
!     *    (1.d0-porlocal)*lamm(lamunit,tlocal,tref,ismpl)+porlocal*fluid
  lx = LAMM(lamunit, tlocal, tref, ismpl)
  IF (lx .LE. 0.d0 .OR. fluid .LE. 0.d0) THEN
    porlocal_ad = 0.D0
    fluid_ad = 0.D0
  ELSE
    temp0 = fluid**porlocal
    temp1 = lx**(-porlocal+1.d0)
    IF (lx .LE. 0.0) THEN
      porlocal_ad = 0.D0
    ELSE
      porlocal_ad = -(temp1*LOG(lx)*temp0*lx_adv)
    END IF
    IF (fluid .LE. 0.0 .AND. (porlocal .EQ. 0.0 .OR. porlocal .NE. INT(&
&       porlocal))) THEN
      fluid_ad = 0.D0
    ELSE
      fluid_ad = porlocal*fluid**(porlocal-1)*temp1*lx_adv
    END IF
    IF (.NOT.fluid .LE. 0.0) porlocal_ad = porlocal_ad + temp0*LOG(fluid&
&       )*temp1*lx_adv
    IF (lx .LE. 0.0 .AND. (1.d0 - porlocal .EQ. 0.0 .OR. 1.d0 - porlocal&
&       .NE. INT(1.d0 - porlocal))) THEN
      lx_adv = 0.D0
    ELSE
      lx_adv = (1.d0-porlocal)*lx**(-porlocal)*temp0*lx_adv
    END IF
  END IF
  CALL LAMM_AD(lamunit, lamunit_ad, tlocal, tlocal_ad, tref, ismpl, &
&        lx_adv)
  propunit_ad(ui, idx_lz, ismpl) = propunit_ad(ui, idx_lz, ismpl) + &
&   propunit(ui, idx_an_lx, ismpl)*lamunit_ad
  propunit_ad(ui, idx_an_lx, ismpl) = propunit_ad(ui, idx_an_lx, ismpl) &
&   + propunit(ui, idx_lz, ismpl)*lamunit_ad
  propunit_ad(ui, idx_por, ismpl) = propunit_ad(ui, idx_por, ismpl) + &
&   porlocal_ad
  CALL LAMF_AD(i, j, k, ismpl, fluid_ad)
  temp_ad(i, j, k, ismpl) = temp_ad(i, j, k, ismpl) + tlocal_ad
END SUBROUTINE LX_AD

