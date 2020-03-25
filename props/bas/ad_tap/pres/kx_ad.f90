!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of kx in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: *propunit kx
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
!> @brief assign permeability in x direction to cell
!> @param[in] i grid indices
!> @param[in] j grid indices
!> @param[in] k grid indices
!> @param[in] ismpl local sample index
!> @return  permeability                        (m^2)
!> @details
!> kx returns the permeability in x-direction [m2] at node(i,j,k) from
!> the input file.\n\n
!>
!> The permeability in x-direction is the product of the permeability
!> in z-direction and the anisotropy factor for the x-direction.
SUBROUTINE KX_AD(i, j, k, ismpl, kx_adv)
  use arrays

  USE ARRAYS_AD

  IMPLICIT NONE
  double precision :: kx_adv
! Location indices
  INTEGER, INTENT(IN) :: i
  INTEGER, INTENT(IN) :: j
  INTEGER, INTENT(IN) :: k
! Sample index
  INTEGER :: ismpl
  DOUBLE PRECISION :: kx
  propunit_ad(uindex(i, j, k), idx_kz, ismpl) = propunit_ad(uindex(i, j&
&   , k), idx_kz, ismpl) + propunit(uindex(i, j, k), idx_an_kx, ismpl)*&
&   kx_adv
  propunit_ad(uindex(i, j, k), idx_an_kx, ismpl) = propunit_ad(uindex(i&
&   , j, k), idx_an_kx, ismpl) + propunit(uindex(i, j, k), idx_kz, ismpl&
&   )*kx_adv
END SUBROUTINE KX_AD

