!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of kx in forward (tangent) mode:
!   variations   of useful results: kx
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
DOUBLE PRECISION FUNCTION g_KX(i, j, k, ismpl, kx)
  USE ARRAYS
  USE g_ARRAYS
  IMPLICIT NONE
! Location indices
  INTEGER, INTENT(IN) :: i
  INTEGER, INTENT(IN) :: j
  INTEGER, INTENT(IN) :: k
! Sample index
  INTEGER :: ismpl
  DOUBLE PRECISION :: temporary
  DOUBLE PRECISION :: temporary0
  DOUBLE PRECISION :: kx
  temporary = propunit(uindex(i, j, k), idx_an_kx, ismpl)
  temporary0 = propunit(uindex(i, j, k), idx_kz, ismpl)
  g_kx = temporary*g_propunit(uindex(i, j, k), idx_kz, ismpl) + temporary0*&
&   g_propunit(uindex(i, j, k), idx_an_kx, ismpl)
  kx = temporary0*temporary
!       Wird das Setzen der Werte benoetigt?
!!       ANFANG SCHLEIFE ?BER SONDEN #######################
!        DO n=1,nghe
!!         hier wird variable Tiefe der Sonden gesetzt
!          k_start(n)=K0-(k_end(n)-depth_hpr/delz(1))
!          k_end(n)=K0-k_end(n)
!
!          WRITE(*,*), 'kdepth', k_start(n), k_end(n)
!          DO l=k_end(n),k_start(n)
!!           setze permeabilitaet an den sonden kl
!            IF (ighe(n).eq.i && jghe(n).eq.j && (K0-l+1).eq.k)
!              kx=1e-25
!            END IF
!          END DO
!        END DO
!!       ENDE SCHLEIFE ?BER SONDEN. #########################
  RETURN
END FUNCTION g_KX

