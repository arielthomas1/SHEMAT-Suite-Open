!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of ly in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: *temp *propunit *tsal ly
!   with respect to varying inputs: *temp *propunit *tsal
!   Plus diff mem management of: temp:in propunit:in tsal:in pres:in
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
!> @brief calculates effective thermal conductivity of the cell
!> @param[in] i cell index, direction I0
!> @param[in] j cell index, direction J0
!> @param[in] k cell index, direction K0
!> @param[in] ismpl local sample index
!> @return  thermal conductivity                ly[W/(m*K)]
!> @details
!> calculates effective thermal conductivity of the two phase system
!> matrix-porosity, y-direction.\n\n
!>
!> input:\n
!> porosity                            porlocal [-]\n
!> temperature                         tlocal in [degC]\n
SUBROUTINE LY_AD(i, j, k, ismpl, ly_adv)
  use arrays

  USE ARRAYS_AD

  USE MOD_TEMP
  IMPLICIT NONE
  double precision :: ly_adv
! Location indices
  INTEGER, INTENT(IN) :: i
  INTEGER, INTENT(IN) :: j
  INTEGER, INTENT(IN) :: k
! Sample index
  INTEGER :: ismpl
! Local uindex
  INTEGER :: ui
! Local temperature [degC]
  DOUBLE PRECISION :: tlocal
  DOUBLE PRECISION :: tlocal_ad
! Local porosity [-]
  DOUBLE PRECISION :: porlocal
  DOUBLE PRECISION :: porlocal_ad
! Reference matrix thermal conductivity [W/(m*K)]
  DOUBLE PRECISION :: lammref
  DOUBLE PRECISION :: lammref_ad
! Local fluid thermal conductivity [W/(m*K)]
  DOUBLE PRECISION :: lamfluid
  DOUBLE PRECISION :: lamfluid_ad
  DOUBLE PRECISION, EXTERNAL :: LAMF
! Local matrix thermal conductivity  [W/(m*K)]
  DOUBLE PRECISION, EXTERNAL :: LAMM
  DOUBLE PRECISION :: temp0
  DOUBLE PRECISION :: temp1
  DOUBLE PRECISION :: ly
! Local Temperature in degC
  tlocal = temp(i, j, k, ismpl)
! Local fluid thermal conductivity [W/(m*K)]
  lamfluid = LAMF(i, j, k, ismpl)
! Local unit index
  ui = uindex(i, j, k)
! Local porosity
  porlocal = propunit(ui, idx_por, ismpl)
! Reference matrix thermal conductivity [W/(m*K)]
  lammref = propunit(ui, idx_lz, ismpl)*propunit(ui, idx_an_ly, ismpl)
! Local matrix thermal conductivity  [W/(m*K)]
  ly = LAMM(lammref, tlocal, tref, ismpl)
  IF (ly .LE. 0.d0 .OR. lamfluid .LE. 0.d0) THEN
    STOP
  ELSE
    temp0 = lamfluid**porlocal
    temp1 = ly**(-porlocal+1.d0)
    IF (ly .LE. 0.0) THEN
      porlocal_ad = 0.D0
    ELSE
      porlocal_ad = -(temp1*LOG(ly)*temp0*ly_adv)
    END IF
    IF (lamfluid .LE. 0.0 .AND. (porlocal .EQ. 0.0 .OR. porlocal .NE. &
&       INT(porlocal))) THEN
      lamfluid_ad = 0.D0
    ELSE
      lamfluid_ad = porlocal*lamfluid**(porlocal-1)*temp1*ly_adv
    END IF
    IF (.NOT.lamfluid .LE. 0.0) porlocal_ad = porlocal_ad + temp0*LOG(&
&       lamfluid)*temp1*ly_adv
    IF (ly .LE. 0.0 .AND. (1.d0 - porlocal .EQ. 0.0 .OR. 1.d0 - porlocal&
&       .NE. INT(1.d0 - porlocal))) THEN
      ly_adv = 0.D0
    ELSE
      ly_adv = (1.d0-porlocal)*ly**(-porlocal)*temp0*ly_adv
    END IF
    CALL LAMM_AD0(lammref, lammref_ad, tlocal, tlocal_ad, tref, ismpl, &
&           ly_adv)
    propunit_ad(ui, idx_lz, ismpl) = propunit_ad(ui, idx_lz, ismpl) + &
&     propunit(ui, idx_an_ly, ismpl)*lammref_ad
    propunit_ad(ui, idx_an_ly, ismpl) = propunit_ad(ui, idx_an_ly, ismpl&
&     ) + propunit(ui, idx_lz, ismpl)*lammref_ad
    propunit_ad(ui, idx_por, ismpl) = propunit_ad(ui, idx_por, ismpl) + &
&     porlocal_ad
    CALL LAMF_AD0(i, j, k, ismpl, lamfluid_ad)
    temp_ad(i, j, k, ismpl) = temp_ad(i, j, k, ismpl) + tlocal_ad
  END IF
END SUBROUTINE LY_AD

