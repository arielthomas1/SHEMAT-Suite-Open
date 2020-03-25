!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of lami in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: *temp lami
!   with respect to varying inputs: *temp
!   Plus diff mem management of: temp:in
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
!>    @brief calculate ice thermal conductivity [W/(m*K)]
!>    @param[in] i cell index, direction I0
!>    @param[in] j cell index, direction J0
!>    @param[in] k cell index, direction K0
!>    @param[in] ismpl local sample index
!#>   return thermal conductivity of ice [W/(m*K)]
!>    @details
!>    Ling, F. & Zhang, T. (2004):
!>    A Numerical Modelfor surface energy balance and the thermal 
!>    regime of the active layer and permafrost containing 
!>    unfrozen water or brine
!>    Cold Regions Science & Technology, 38, 1-15
!>    Ling and Zhang cite Osterkamp, T. E. (1987):
!>    Freezing and Thawing of Soils and Permafrost
!>    Containing Unfrozen Water or Brine
!>    Water Resources Research, Vol. 23, No. 12, pages 2279-2285
!>    Alternative: 
!>    Fukusako, S.:
!>    Thermophysical Properties of Ice, Snow,and Sea Ice
!>    International Journal of Thermophysics, 1990, 11, 353-372
SUBROUTINE LAMI_AD(i, j, k, ismpl, lami_adv)
  use arrays

  USE ARRAYS_AD

  IMPLICIT NONE
  double precision :: lami_adv
  INTEGER :: i, j, k, ismpl
  DOUBLE PRECISION :: plocal, tlocal
  DOUBLE PRECISION :: tlocal_ad
  INTEGER :: branch
  DOUBLE PRECISION :: lami
  tlocal = temp(i, j, k, ismpl)
  IF (tlocal .GT. 0.d0) THEN
    tlocal = 0.d0
    CALL PUSHCONTROL1B(0)
  ELSE
    CALL PUSHCONTROL1B(1)
  END IF
  tlocal_ad = -(488.19d0*lami_adv/(tlocal+273.16d0)**2)
  CALL POPCONTROL1B(branch)
  IF (branch .EQ. 0) tlocal_ad = 0.D0
  temp_ad(i, j, k, ismpl) = temp_ad(i, j, k, ismpl) + tlocal_ad
END SUBROUTINE LAMI_AD

