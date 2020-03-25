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

!>    @brief top level routine for setup aand computing head flow
!>    @param[in] ismpl local sample index
      SUBROUTINE calc_head(ismpl)
        use arrays
        use mod_genrlc
        use mod_genrl
        use mod_flow
        use mod_time
        use mod_linfos
        use mod_OMP_TOOLS
        IMPLICIT NONE
        integer :: ismpl
        integer :: i
        INCLUDE 'OMP_TOOLS.inc'
        INTEGER ijk


        IF (linfos(3)>=2) WRITE(*,*) ' ... calc_head'
!
#ifdef fOMP
!$OMP parallel num_threads(Tlevel_1)
!$      call omp_binding(ismpl)
#endif

        ijk = i0*j0*k0

        ! default to mark a non-boundary
!$OMP master
        DO i = 1, ijk
          bc_mask(i,ismpl) = '+'
        END DO
!$OMP end master

        ! initialize coefficients for sparse solvers as zero
        CALL omp_set_dval(ijk,0.D0,a(1,1,1,ismpl))
        CALL omp_set_dval(ijk,0.D0,b(1,1,1,ismpl))
        CALL omp_set_dval(ijk,0.D0,c(1,1,1,ismpl))
        CALL omp_set_dval(ijk,0.D0,d(1,1,1,ismpl))
        CALL omp_set_dval(ijk,0.D0,e(1,1,1,ismpl))
        CALL omp_set_dval(ijk,0.D0,f(1,1,1,ismpl))
        CALL omp_set_dval(ijk,0.D0,g(1,1,1,ismpl))
        CALL omp_set_dval(ijk,0.D0,w(1,1,1,ismpl))

!$OMP barrier

        ! calculate coefficients
        CALL set_hcoef(ismpl)

        ! set fluid sources/sinks (currently hardcoded to zero)
        CALL set_hq(ismpl)

!$OMP barrier

        ! calculate coefficients for right hand side
        CALL set_hcoefrs(ismpl)

#ifdef fOMP
!$OMP end parallel
#endif

        ! set boundary conditions
        CALL set_hbc(ismpl)

        ! standard output
        IF (linfos(3)>=2) WRITE(*,*) ' ... solve(head)'

        ! solve head
        CALL solve(pv_head,-1,head(1,1,1,ismpl),errf,aparf,controlf, &
          ismpl)

        RETURN

      END
