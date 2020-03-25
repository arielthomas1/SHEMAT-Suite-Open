!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of calc_conc in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: *d *e *f *concold *g *temp
!                *w *x *dbc_data *bcperiod *propunit *tsal *conc
!                *pres *a *b *c
!   with respect to varying inputs: *d *e *f *concold *g *temp
!                *w *x *dbc_data *bcperiod *propunit *tsal *conc
!                *pres *a *b *c
!   Plus diff mem management of: d:in e:in f:in concold:in g:in
!                temp:in w:in x:in dbc_data:in bcperiod:in propunit:in
!                tsal:in conc:in pres:in simtime:in a:in b:in c:in
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
!>    @brief top level routine for setup and computing tracer concentration
!>    @param[in] species tracer species index
!>    @param[in] ismpl local sample index
SUBROUTINE CALC_CONC_AD(species, ismpl)
  use arrays

  USE ARRAYS_AD

!      use chem_arrays
  USE MOD_GENRLC
  USE MOD_GENRL
  USE MOD_CONC
  use mod_time

  USE MOD_TIME_AD

  USE MOD_LINFOS
  USE MOD_OMP_TOOLS
  IMPLICIT NONE
  INTEGER :: ismpl
  INTEGER :: i
  INCLUDE 'OMP_TOOLS.inc'
  INTEGER :: ijk, species
  INTEGER :: branch
  IF (linfos(3) .GE. 2) WRITE(*, '(1A,i4)') ' ... calc_conc', species
!
!     selecting a part for each thread
  ijk = i0*j0*k0
! initialize coefficients for sparse solvers
  CALL OMP_SET_DVAL(ijk, 0.d0, a(1, 1, 1, ismpl))
  CALL OMP_SET_DVAL(ijk, 0.d0, b(1, 1, 1, ismpl))
  CALL OMP_SET_DVAL(ijk, 0.d0, c(1, 1, 1, ismpl))
  CALL OMP_SET_DVAL(ijk, 0.d0, d(1, 1, 1, ismpl))
  CALL OMP_SET_DVAL(ijk, 0.d0, e(1, 1, 1, ismpl))
  CALL OMP_SET_DVAL(ijk, 0.d0, f(1, 1, 1, ismpl))
  CALL OMP_SET_DVAL(ijk, 0.d0, g(1, 1, 1, ismpl))
  CALL OMP_SET_DVAL(ijk, 0.d0, w(1, 1, 1, ismpl))
!     calculate coefficients
  CALL SET_CCOEF(species, ismpl)
!     set energy sources/sinks
  IF (ALLOCATED(simtime)) THEN
    CALL PUSHREAL8ARRAY(simtime, SIZE(simtime, 1))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  CALL SET_CQ(species, ismpl)
  IF (ALLOCATED(simtime)) THEN
    CALL PUSHREAL8ARRAY(simtime, SIZE(simtime, 1))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(delt_count)) THEN
    CALL PUSHINTEGER8ARRAY(delt_count, SIZE(delt_count, 1))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(flag_1st_timestep)) THEN
    CALL PUSHINTEGER8ARRAY(flag_1st_timestep, SIZE(flag_1st_timestep, 1)&
&                   )
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(delt_old)) THEN
    CALL PUSHREAL8ARRAY(delt_old, SIZE(delt_old, 1))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(d)) THEN
    CALL PUSHREAL8ARRAY(d, SIZE(d, 1)*SIZE(d, 2)*SIZE(d, 3)*SIZE(d, 4))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  CALL SET_CCOEFRS(species, ismpl)
!     set boundary conditions
  IF (ALLOCATED(c)) THEN
    CALL PUSHREAL8ARRAY(c, SIZE(c, 1)*SIZE(c, 2)*SIZE(c, 3)*SIZE(c, 4))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(b)) THEN
    CALL PUSHREAL8ARRAY(b, SIZE(b, 1)*SIZE(b, 2)*SIZE(b, 3)*SIZE(b, 4))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(a)) THEN
    CALL PUSHREAL8ARRAY(a, SIZE(a, 1)*SIZE(a, 2)*SIZE(a, 3)*SIZE(a, 4))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(conc)) THEN
    CALL PUSHREAL8ARRAY(conc, SIZE(conc, 1)*SIZE(conc, 2)*SIZE(conc, 3)*&
&                 SIZE(conc, 4)*SIZE(conc, 5))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(g)) THEN
    CALL PUSHREAL8ARRAY(g, SIZE(g, 1)*SIZE(g, 2)*SIZE(g, 3)*SIZE(g, 4))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(f)) THEN
    CALL PUSHREAL8ARRAY(f, SIZE(f, 1)*SIZE(f, 2)*SIZE(f, 3)*SIZE(f, 4))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(e)) THEN
    CALL PUSHREAL8ARRAY(e, SIZE(e, 1)*SIZE(e, 2)*SIZE(e, 3)*SIZE(e, 4))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  CALL SET_CBC(species, ismpl)
  IF (linfos(3) .GE. 2) WRITE(*, '(A,i4)') ' calling solve (conc)', &
&                       species
  CALL SOLVE_AD(pv_conc, species, conc(1, 1, 1, species, ismpl), conc_ad&
&         (1, 1, 1, species, ismpl), errc, aparc, controlc, ismpl)
  CALL POPCONTROL1B(branch)
  IF (branch .EQ. 1) CALL POPREAL8ARRAY(e, SIZE(e, 1)*SIZE(e, 2)*SIZE(e&
&                                 , 3)*SIZE(e, 4))
  CALL POPCONTROL1B(branch)
  IF (branch .EQ. 1) CALL POPREAL8ARRAY(f, SIZE(f, 1)*SIZE(f, 2)*SIZE(f&
&                                 , 3)*SIZE(f, 4))
  CALL POPCONTROL1B(branch)
  IF (branch .EQ. 1) CALL POPREAL8ARRAY(g, SIZE(g, 1)*SIZE(g, 2)*SIZE(g&
&                                 , 3)*SIZE(g, 4))
  CALL POPCONTROL1B(branch)
  IF (branch .EQ. 1) CALL POPREAL8ARRAY(conc, SIZE(conc, 1)*SIZE(conc, 2&
&                                 )*SIZE(conc, 3)*SIZE(conc, 4)*SIZE(&
&                                 conc, 5))
  CALL POPCONTROL1B(branch)
  IF (branch .EQ. 1) CALL POPREAL8ARRAY(a, SIZE(a, 1)*SIZE(a, 2)*SIZE(a&
&                                 , 3)*SIZE(a, 4))
  CALL POPCONTROL1B(branch)
  IF (branch .EQ. 1) CALL POPREAL8ARRAY(b, SIZE(b, 1)*SIZE(b, 2)*SIZE(b&
&                                 , 3)*SIZE(b, 4))
  CALL POPCONTROL1B(branch)
  IF (branch .EQ. 1) CALL POPREAL8ARRAY(c, SIZE(c, 1)*SIZE(c, 2)*SIZE(c&
&                                 , 3)*SIZE(c, 4))
  CALL SET_CBC_AD(species, ismpl)
  CALL POPCONTROL1B(branch)
  IF (branch .EQ. 1) CALL POPREAL8ARRAY(d, SIZE(d, 1)*SIZE(d, 2)*SIZE(d&
&                                 , 3)*SIZE(d, 4))
  CALL POPCONTROL1B(branch)
  IF (branch .EQ. 1) CALL POPREAL8ARRAY(delt_old, SIZE(delt_old, 1))
  CALL POPCONTROL1B(branch)
  IF (branch .EQ. 1) CALL POPINTEGER8ARRAY(flag_1st_timestep, SIZE(&
&                                    flag_1st_timestep, 1))
  CALL POPCONTROL1B(branch)
  IF (branch .EQ. 1) CALL POPINTEGER8ARRAY(delt_count, SIZE(delt_count, &
&                                    1))
  CALL POPCONTROL1B(branch)
  IF (branch .EQ. 1) CALL POPREAL8ARRAY(simtime, SIZE(simtime, 1))
  CALL SET_CCOEFRS_AD(species, ismpl)
  CALL POPCONTROL1B(branch)
  IF (branch .EQ. 1) CALL POPREAL8ARRAY(simtime, SIZE(simtime, 1))
  CALL SET_CQ_AD(species, ismpl)
  CALL SET_CCOEF_AD(species, ismpl)
  CALL OMP_SET_DVAL_AD(ijk, 0.d0, w(1, 1, 1, ismpl), w_ad(1, 1, 1, ismpl&
&                ))
  CALL OMP_SET_DVAL_AD(ijk, 0.d0, g(1, 1, 1, ismpl), g_ad(1, 1, 1, ismpl&
&                ))
  CALL OMP_SET_DVAL_AD(ijk, 0.d0, f(1, 1, 1, ismpl), f_ad(1, 1, 1, ismpl&
&                ))
  CALL OMP_SET_DVAL_AD(ijk, 0.d0, e(1, 1, 1, ismpl), e_ad(1, 1, 1, ismpl&
&                ))
  CALL OMP_SET_DVAL_AD(ijk, 0.d0, d(1, 1, 1, ismpl), d_ad(1, 1, 1, ismpl&
&                ))
  CALL OMP_SET_DVAL_AD(ijk, 0.d0, c(1, 1, 1, ismpl), c_ad(1, 1, 1, ismpl&
&                ))
  CALL OMP_SET_DVAL_AD(ijk, 0.d0, b(1, 1, 1, ismpl), b_ad(1, 1, 1, ismpl&
&                ))
  CALL OMP_SET_DVAL_AD(ijk, 0.d0, a(1, 1, 1, ismpl), a_ad(1, 1, 1, ismpl&
&                ))
END SUBROUTINE CALC_CONC_AD

