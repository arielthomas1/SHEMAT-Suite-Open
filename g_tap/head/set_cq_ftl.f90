!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of set_cq in forward (tangent) mode:
!   variations   of useful results: *w
!   with respect to varying inputs: *w
!   Plus diff mem management of: w:in simtime:in
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
!>    @brief modify coefficents for a concentration equation according to the prescribed sources and sinks
!>    @param[in] spec species index
!>    @param[in] ismpl local sample index
!>    @details
!> modify coefficents for a concentration equation according to the prescribed sources and sinks.\n
!> coefficients are stored as vectors in the diagonals a-g (d center) and rhs in w.\n
SUBROUTINE g_SET_CQ(spec, ismpl)
  USE ARRAYS

  USE g_ARRAYS

  USE MOD_GENRL
  USE MOD_TIME

  USE g_MOD_TIME

  IMPLICIT NONE
  INTEGER :: ismpl
  INTEGER :: i, j, k
  INTEGER :: spec
  EXTERNAL DELTAT, QC
  DOUBLE PRECISION :: DELTAT, deltf, QC
  EXTERNAL DUMMY
  DOUBLE PRECISION :: result1
! rhs: sources
  IF (transient .AND. tr_switch(ismpl)) THEN
    deltf = DELTAT(simtime(ismpl), ismpl)
!$OMP     do schedule (static)
    DO k=1,k0
      DO j=1,j0
        DO i=1,i0
          result1 = QC(i, j, k, spec, ismpl)
          w(i, j, k, ismpl) = w(i, j, k, ismpl) - result1
        END DO
      END DO
    END DO
!$OMP     end do nowait
  ELSE
!$OMP     do schedule (static)
    DO k=1,k0
      DO j=1,j0
        DO i=1,i0
          result1 = QC(i, j, k, spec, ismpl)
          w(i, j, k, ismpl) = w(i, j, k, ismpl) - result1
        END DO
      END DO
    END DO
!$OMP     end do nowait
  END IF
  RETURN
END SUBROUTINE g_SET_CQ

