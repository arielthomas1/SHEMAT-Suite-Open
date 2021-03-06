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

!>    @brief reset some values for each realisation/sample/gradient/ensemble run
!>    @param[in] ismpl local sample index
      SUBROUTINE prepare_realisation(ismpl)
        use arrays
        use mod_genrl
        use mod_time
        IMPLICIT NONE
        integer :: i, j, k
        integer :: ismpl
!     realisation
        INTEGER i_max
        INTRINSIC max

!       init physical values (main state variables) from master-init ("opti" copy)
        CALL old_restore(cgen_opti,ismpl)
!
!       init "BC" state (before)
        DO i = 1, nbc_data
          dbc_data(i,1,ismpl) = dbc_dataold(i)
        END DO
!
        DO j = 2, ndbc
          DO i = 1, nbc_data
            dbc_data(i,j,ismpl) = dbc_data(i,j,1)
          END DO
        END DO
!
!       init "properties" state (before)
        i_max = max(maxunits,bc_maxunits)
        DO j = 1, nprop
          DO i = 1, i_max
            propunit(i,j,ismpl) = propunitold(i,j)
          END DO
        END DO
!
!       init "periods" state (before)
        DO k = 1, nbctp
          DO j = 1, 3
            DO i = 1, ngsmax
              bcperiod(i,j,k,ismpl) = bcperiodold(i,j,k)
            END DO
          END DO
        END DO
!
        RETURN
      END
