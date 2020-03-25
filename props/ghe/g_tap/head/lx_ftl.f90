!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of lx in forward (tangent) mode:
!   variations   of useful results: lx
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
DOUBLE PRECISION FUNCTION g_LX(i, j, k, ismpl, lx)
  USE ARRAYS

  USE g_ARRAYS

  USE MOD_TEMP
  IMPLICIT NONE
  INTEGER :: i, j, k, ui, ismpl
  EXTERNAL LAMF, LAMM
  EXTERNAL g_LAMF, g_LAMM
  DOUBLE PRECISION :: plocal, tlocal, fluid, lamunit, LAMF, &
& porlocal, LAMM
  DOUBLE PRECISION :: g_tlocal, g_fluid, g_lamunit, g_LAMF, &
& g_porlocal, g_LAMM
  DOUBLE PRECISION :: pwy1
  DOUBLE PRECISION :: g_pwy1
  DOUBLE PRECISION :: pwr1
  DOUBLE PRECISION :: g_pwr1
  DOUBLE PRECISION :: pwr2
  DOUBLE PRECISION :: g_pwr2
  DOUBLE PRECISION :: temp0
  DOUBLE PRECISION :: lx
!      ploCal = pres(i,j,k,ismpl)*Pa_Conv1
  g_tlocal = g_temp(i, j, k, ismpl)
  tlocal = temp(i, j, k, ismpl)
  g_fluid = g_LAMF(i, j, k, ismpl, fluid)
  ui = uindex(i, j, k)
  g_porlocal = g_propunit(ui, idx_por, ismpl)
  porlocal = propunit(ui, idx_por, ismpl)
  g_lamunit = propunit(ui, idx_an_lx, ismpl)*g_propunit(ui, idx_lz, &
&   ismpl) + propunit(ui, idx_lz, ismpl)*g_propunit(ui, idx_an_lx, &
&   ismpl)
  lamunit = propunit(ui, idx_lz, ismpl)*propunit(ui, idx_an_lx, ismpl)
!         lx=
!     *    (1.d0-porlocal)*lamm(lamunit,tlocal,tref,ismpl)+porlocal*fluid
  g_lx = g_LAMM(lamunit, g_lamunit, tlocal, g_tlocal, tref, &
&   ismpl, lx)
  IF (lx .LE. 0.d0 .OR. fluid .LE. 0.d0) THEN
    WRITE(*, *) 'warning: "lx" computes bad math !', lx, fluid, tlocal
  ELSE
    g_pwy1 = -g_porlocal
    pwy1 = 1.d0 - porlocal
    temp0 = lx**pwy1
    IF (lx .LE. 0.0 .AND. (pwy1 .EQ. 0.0 .OR. pwy1 .NE. INT(pwy1))) THEN
      g_pwr1 = 0.D0
    ELSE IF (lx .LE. 0.0) THEN
      g_pwr1 = pwy1*lx**(pwy1-1)*g_lx
    ELSE
      g_pwr1 = pwy1*lx**(pwy1-1)*g_lx + temp0*LOG(lx)*g_pwy1
    END IF
    pwr1 = temp0
    temp0 = fluid**porlocal
    IF (fluid .LE. 0.0 .AND. (porlocal .EQ. 0.0 .OR. porlocal .NE. INT(&
&       porlocal))) THEN
      g_pwr2 = 0.D0
    ELSE IF (fluid .LE. 0.0) THEN
      g_pwr2 = porlocal*fluid**(porlocal-1)*g_fluid
    ELSE
      g_pwr2 = porlocal*fluid**(porlocal-1)*g_fluid + temp0*LOG(&
&       fluid)*g_porlocal
    END IF
    pwr2 = temp0
    g_lx = pwr2*g_pwr1 + pwr1*g_pwr2
    lx = pwr1*pwr2
  END IF
  RETURN
END FUNCTION g_LX

