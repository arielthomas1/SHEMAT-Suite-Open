!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of rhocm in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: *propunit rhocm
!   with respect to varying inputs: *propunit
!   Plus diff mem management of: propunit:in
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
!> @brief calculates  heat capacity*density of rock
!> @param[in] i cell index, direction I0
!> @param[in] j cell index, direction J0
!> @param[in] k cell index, direction K0
!> @param[in] ismpl local sample index
!> @return  heat capacity*density = volumetric heat capacity   rhocm    [J/(K*m3)]
!> @details
!> rhocm returns the volumetric heat capacity [J/(K*m3)] at
!> node(i,j,k) from the input file.\n
SUBROUTINE RHOCM_AD0(i, j, k, ismpl, rhocm_ad)
  use arrays

  USE ARRAYS_AD

  IMPLICIT NONE
! Location indices
  INTEGER, INTENT(IN) :: i
  INTEGER, INTENT(IN) :: j
  INTEGER, INTENT(IN) :: k
! Sample index
  INTEGER :: ismpl
  DOUBLE PRECISION :: rhocm
  DOUBLE PRECISION :: rhocm_ad
  propunit_ad(uindex(i, j, k), idx_rc, ismpl) = propunit_ad(uindex(i, j&
&   , k), idx_rc, ismpl) + rhocm_ad
END SUBROUTINE RHOCM_AD0
