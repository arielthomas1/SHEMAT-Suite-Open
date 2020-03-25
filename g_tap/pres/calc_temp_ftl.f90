!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of calc_temp in forward (tangent) mode:
!   variations   of useful results: *d *e *f *g *temp *w *x *a
!                *b *c
!   with respect to varying inputs: *d *e *f *g *temp *w *x *dbc_data
!                *bcperiod *tempold *propunit *tsal *pres *a *b
!                *c
!   Plus diff mem management of: d:in e:in f:in g:in temp:in w:in
!                x:in dbc_data:in bcperiod:in tempold:in propunit:in
!                tsal:in pres:in simtime:in a:in b:in c:in
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
!>    @brief top level routine for setup and compute temperature
!>    @param[in] ismpl local sample index
SUBROUTINE g_CALC_TEMP(ismpl)
  USE ARRAYS

  USE g_ARRAYS

  USE MOD_GENRLC
  USE MOD_GENRL
  USE MOD_TEMP
  USE MOD_TIME

  USE g_MOD_TIME

  USE MOD_LINFOS
  USE MOD_OMP_TOOLS
  IMPLICIT NONE
  INCLUDE 'OMP_TOOLS.inc'
  EXTERNAL VXC, VYC, VZC, POR, KX, KY, KZ, LX, LY, LZ, RHOCEFF
  DOUBLE PRECISION :: VXC, VYC, VZC, POR, KX, KY, KZ, LX, LY, LZ, &
& RHOCEFF
  EXTERNAL VX, VY, VZ, RHOCF, RHOCM
  DOUBLE PRECISION :: VX, VY, VZ, RHOCF, RHOCM
  INTEGER :: ijk
  INTEGER :: i
  INTEGER :: ismpl
  EXTERNAL DUMMY
  IF (linfos(3) .GE. 2) WRITE(*, *) ' ... calc_temp'
!
!     selecting a part for each thread
#ifdef fOMP
!$OMP parallel num_threads(Tlevel_1)
!$      call omp_binding(ismpl)
#endif
  ijk = i0*j0*k0
!     default to mark a non-boundary
!$OMP master
  DO i=1,ijk
    bc_mask(i, ismpl) = '+'
  END DO
!$OMP end master
!     initialize coefficients for sparse solvers
  CALL g_OMP_SET_DVAL(ijk, 0.d0, a(1, 1, 1, ismpl), g_a(1, 1, 1, &
&                 ismpl))
  CALL g_OMP_SET_DVAL(ijk, 0.d0, b(1, 1, 1, ismpl), g_b(1, 1, 1, &
&                 ismpl))
  CALL g_OMP_SET_DVAL(ijk, 0.d0, c(1, 1, 1, ismpl), g_c(1, 1, 1, &
&                 ismpl))
  CALL g_OMP_SET_DVAL(ijk, 0.d0, d(1, 1, 1, ismpl), g_d(1, 1, 1, &
&                 ismpl))
  CALL g_OMP_SET_DVAL(ijk, 0.d0, e(1, 1, 1, ismpl), g_e(1, 1, 1, &
&                 ismpl))
  CALL g_OMP_SET_DVAL(ijk, 0.d0, f(1, 1, 1, ismpl), g_f(1, 1, 1, &
&                 ismpl))
  CALL g_OMP_SET_DVAL(ijk, 0.d0, g(1, 1, 1, ismpl), g_g(1, 1, 1, &
&                 ismpl))
  CALL g_OMP_SET_DVAL(ijk, 0.d0, w(1, 1, 1, ismpl), g_w(1, 1, 1, &
&                 ismpl))
!$OMP barrier
!     calculate coefficients
  CALL g_SET_TCOEF(ismpl)
!     set energy sources/sinks
  CALL g_SET_TQ(ismpl)
!$OMP barrier
  CALL g_SET_TCOEFRS(ismpl)
#ifdef fOMP
!$OMP end parallel
#endif
!     set boundary conditions
  CALL g_SET_TBC(ismpl)
  IF (linfos(3) .GE. 2) WRITE(*, *) ' ... solve(temp)'
!     solve it
  CALL g_SOLVE(pv_temp, -1, temp(1, 1, 1, ismpl), g_temp(1, 1, 1, &
&          ismpl), errt, apart, controlt, ismpl)
  RETURN
END SUBROUTINE g_CALC_TEMP

