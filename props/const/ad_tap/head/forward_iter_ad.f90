!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of forward_iter in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: *sdata
!   with respect to varying inputs: *d *e *f *concold *g *temp
!                *w *headold *x *sdata *head *dbc_data *bcperiod
!                *tempold *propunit *presold *conc *pres *a *b
!                *c
!   Plus diff mem management of: d:in e:in f:in concold:in g:in
!                temp:in w:in headold:in x:in sdata:in head:in
!                dbc_data:in bcperiod:in tempold:in propunit:in
!                presold:in conc:in pres:in simtime:in a:in b:in
!                c:in
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
!> @brief time discretisation loop
!> @param[in] iter_out inverse iteration, SM realisation
!> @param[in] simtime_run start time of the simulation
!> @param[in] simtime_end finish time of the simulation
!> @param[in] iseed 0: FW simulation, 1 .. <mpara>: AD seeding index
!> @param[in] ismpl local sample index
!> @details
!> In-a-Nutshell description of this subroutine: \n
!> - Preprocessing before time step loop, initial variable values,
!>   monitoring output, extra steady-state initialisation, status_log\n
!> - Time loop: \n
!>   - before computations: time stepping, saving old variable arrays,
!>     output \n
!>   - computation: calling `forward_wrapper.f90`
!>   - after computations: save simulated data, update simtime,
!>     output, check divergence for variable step size \n
!> - Postprocessing: standard output
SUBROUTINE FORWARD_ITER_AD(simtime_run, simtime_end, iter_out, iseed, &
& ismpl)
  use arrays

  USE ARRAYS_AD

  USE MOD_GENRL
  USE MOD_GENRLC
  use mod_time

  USE MOD_TIME_AD

  USE MOD_LINFOS
  IMPLICIT NONE
! wrapper for output
!          call write_outt(deltt,ismpl)
! monitoring output
! initial monitoring output
! local sample index
  INTEGER :: ismpl
! iter_out: inverse iteration, SM realisation
  INTEGER :: iter_out, iseed
! Time step index
  INTEGER :: itimestep
! Size of a time period
  DOUBLE PRECISION :: deltt
! Start time of the simulation
  DOUBLE PRECISION, INTENT(IN) :: simtime_run
! Finish time of the simulation
  DOUBLE PRECISION, INTENT(IN) :: simtime_end
  DOUBLE PRECISION, EXTERNAL :: DELTAT
  INTEGER, EXTERNAL :: LBLANK
  INTEGER :: branch
  INTEGER :: res
  INTEGER :: res0
  INTEGER :: ad_count
  INTEGER :: i
! Preprocessing
! -------------
! initial values for some variables/arrays
  flag_1st_timestep(ismpl) = 0
  itimestep = itimestep_0
  simtime(ismpl) = simtime_run
  deltt = DELTAT(simtime(ismpl), ismpl)
  tr_switch(ismpl) = .true.
  iter_nlold = maxiter_nl/2
!          call write_monitor(1,ismpl)
!          call write_monitor_user(1,ismpl)
! runmode 2: extra steady state initialisation
  IF (transient .AND. runmode .EQ. 2) THEN
    tr_switch(ismpl) = .false.
    IF (iseed .EQ. 0 .AND. linfos(2) .GE. 0) WRITE(*, '(1A)') &
&                            '  [I] : extra steady state initialisation'
    IF (ALLOCATED(c)) THEN
      CALL PUSHREAL8ARRAY(c, SIZE(c, 1)*SIZE(c, 2)*SIZE(c, 3)*SIZE(c, 4)&
&                  )
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(b)) THEN
      CALL PUSHREAL8ARRAY(b, SIZE(b, 1)*SIZE(b, 2)*SIZE(b, 3)*SIZE(b, 4)&
&                  )
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(a)) THEN
      CALL PUSHREAL8ARRAY(a, SIZE(a, 1)*SIZE(a, 2)*SIZE(a, 3)*SIZE(a, 4)&
&                  )
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(simtime)) THEN
      CALL PUSHREAL8ARRAY(simtime, SIZE(simtime, 1))
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(pres)) THEN
      CALL PUSHREAL8ARRAY(pres, SIZE(pres, 1)*SIZE(pres, 2)*SIZE(pres, 3&
&                   )*SIZE(pres, 4))
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(conc)) THEN
      CALL PUSHREAL8ARRAY(conc, SIZE(conc, 1)*SIZE(conc, 2)*SIZE(conc, 3&
&                   )*SIZE(conc, 4)*SIZE(conc, 5))
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
    IF (ALLOCATED(flag_delt)) THEN
      CALL PUSHINTEGER8ARRAY(flag_delt, SIZE(flag_delt, 1))
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(flag_1st_timestep)) THEN
      CALL PUSHINTEGER8ARRAY(flag_1st_timestep, SIZE(flag_1st_timestep, &
&                      1))
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(tempold)) THEN
      CALL PUSHREAL8ARRAY(tempold, SIZE(tempold, 1)*SIZE(tempold, 2)*&
&                   SIZE(tempold, 3))
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(omp_iglobal)) THEN
      CALL PUSHINTEGER8ARRAY(omp_iglobal, SIZE(omp_iglobal, 1)*SIZE(&
&                      omp_iglobal, 2)*SIZE(omp_iglobal, 3))
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(dbc_data)) THEN
      CALL PUSHREAL8ARRAY(dbc_data, SIZE(dbc_data, 1)*SIZE(dbc_data, 2)*&
&                   SIZE(dbc_data, 3))
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
    IF (ALLOCATED(omp_dglobal)) THEN
      CALL PUSHREAL8ARRAY(omp_dglobal, SIZE(omp_dglobal, 1)*SIZE(&
&                   omp_dglobal, 2)*SIZE(omp_dglobal, 3))
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(head)) THEN
      CALL PUSHREAL8ARRAY(head, SIZE(head, 1)*SIZE(head, 2)*SIZE(head, 3&
&                   )*SIZE(head, 4))
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(conv_ipos)) THEN
      CALL PUSHINTEGER8ARRAY(conv_ipos, SIZE(conv_ipos, 1)*SIZE(&
&                      conv_ipos, 2))
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(x)) THEN
      CALL PUSHREAL8ARRAY(x, SIZE(x, 1)*SIZE(x, 2)*SIZE(x, 3)*SIZE(x, 4)&
&                  )
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(headold)) THEN
      CALL PUSHREAL8ARRAY(headold, SIZE(headold, 1)*SIZE(headold, 2)*&
&                   SIZE(headold, 3))
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(w)) THEN
      CALL PUSHREAL8ARRAY(w, SIZE(w, 1)*SIZE(w, 2)*SIZE(w, 3)*SIZE(w, 4)&
&                  )
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(lcon)) THEN
      CALL PUSHBOOLEANARRAY(lcon, SIZE(lcon, 1)*SIZE(lcon, 2))
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(conc_conv)) THEN
      CALL PUSHREAL8ARRAY(conc_conv, SIZE(conc_conv, 1)*SIZE(conc_conv, &
&                   2))
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(conv_chlen)) THEN
      CALL PUSHINTEGER8ARRAY(conv_chlen, SIZE(conv_chlen, 1)*SIZE(&
&                      conv_chlen, 2))
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(temp)) THEN
      CALL PUSHREAL8ARRAY(temp, SIZE(temp, 1)*SIZE(temp, 2)*SIZE(temp, 3&
&                   )*SIZE(temp, 4))
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(g)) THEN
      CALL PUSHREAL8ARRAY(g, SIZE(g, 1)*SIZE(g, 2)*SIZE(g, 3)*SIZE(g, 4)&
&                  )
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(concold)) THEN
      CALL PUSHREAL8ARRAY(concold, SIZE(concold, 1)*SIZE(concold, 2)*&
&                   SIZE(concold, 3)*SIZE(concold, 4))
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(f)) THEN
      CALL PUSHREAL8ARRAY(f, SIZE(f, 1)*SIZE(f, 2)*SIZE(f, 3)*SIZE(f, 4)&
&                  )
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(conv_history)) THEN
      CALL PUSHREAL8ARRAY(conv_history, SIZE(conv_history, 1)*SIZE(&
&                   conv_history, 2)*SIZE(conv_history, 3))
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(e)) THEN
      CALL PUSHREAL8ARRAY(e, SIZE(e, 1)*SIZE(e, 2)*SIZE(e, 3)*SIZE(e, 4)&
&                  )
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    IF (ALLOCATED(d)) THEN
      CALL PUSHREAL8ARRAY(d, SIZE(d, 1)*SIZE(d, 2)*SIZE(d, 3)*SIZE(d, 4)&
&                  )
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHCONTROL1B(0)
    END IF
    CALL PUSHINTEGER8(iter_nlold)
    CALL FORWARD_WRAPPER(itimestep, iseed, ismpl)
    IF (iseed .EQ. 0 .AND. linfos(2) .GE. 0) WRITE(*, '(1A)') &
&                                     '  [I] : normal transient process'
    CALL PUSHBOOLEAN(tr_switch(ismpl))
    tr_switch(ismpl) = .true.
    CALL PUSHCONTROL1B(0)
  ELSE
    CALL PUSHCONTROL1B(1)
  END IF
! Write to status_log
  IF (transient .AND. iseed .EQ. 0 .AND. (.NOT.write_iter_disable)) THEN
    OPEN(76, file=status_log, status='unknown', position='append') 
    WRITE(76, fmt='(I8,1e14.6,1e14.6)') itimestep, deltt, simtime(ismpl)&
&   /tunit
    CLOSE(76) 
  END IF
  ad_count = 1
! Time step loop for forward modeling
! -----------------------------------
 1000 IF (transient) THEN
! Advance time step
    CALL PUSHINTEGER8(itimestep)
    itimestep = itimestep + 1
! Initialize flag for variable time step size
    CALL PUSHINTEGER8(flag_delt(ismpl))
    flag_delt(ismpl) = 0
! Time stepping info to standard out
    IF (linfos(1) .GE. 1) THEN
      WRITE(*, *) ' '
      WRITE(*, '(1A,1I6)') '  >>>> new time step: ', itimestep
      WRITE(*, '(1A,1e16.8,1A,1e16.8)') '  >>>>     cum. time= ', (&
&     simtime(ismpl)+deltt)/tunit, '/', max_simtime/tunit
      WRITE(*, '(1A,1e16.8)') '  >>>>     time step= ', deltt/tunit
    END IF
! Save old time level
    CALL OLD_SAVE(cgen_time, ismpl)
    CALL PUSHCONTROL1B(0)
  ELSE
    CALL PUSHCONTROL1B(1)
  END IF
! ######### Forward Iteration ######
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
  IF (ALLOCATED(simtime)) THEN
    CALL PUSHREAL8ARRAY(simtime, SIZE(simtime, 1))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(pres)) THEN
    CALL PUSHREAL8ARRAY(pres, SIZE(pres, 1)*SIZE(pres, 2)*SIZE(pres, 3)*&
&                 SIZE(pres, 4))
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
  IF (ALLOCATED(delt_count)) THEN
    CALL PUSHINTEGER8ARRAY(delt_count, SIZE(delt_count, 1))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(flag_delt)) THEN
    CALL PUSHINTEGER8ARRAY(flag_delt, SIZE(flag_delt, 1))
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
  IF (ALLOCATED(tempold)) THEN
    CALL PUSHREAL8ARRAY(tempold, SIZE(tempold, 1)*SIZE(tempold, 2)*SIZE(&
&                 tempold, 3))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(omp_iglobal)) THEN
    CALL PUSHINTEGER8ARRAY(omp_iglobal, SIZE(omp_iglobal, 1)*SIZE(&
&                    omp_iglobal, 2)*SIZE(omp_iglobal, 3))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(dbc_data)) THEN
    CALL PUSHREAL8ARRAY(dbc_data, SIZE(dbc_data, 1)*SIZE(dbc_data, 2)*&
&                 SIZE(dbc_data, 3))
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
  IF (ALLOCATED(omp_dglobal)) THEN
    CALL PUSHREAL8ARRAY(omp_dglobal, SIZE(omp_dglobal, 1)*SIZE(&
&                 omp_dglobal, 2)*SIZE(omp_dglobal, 3))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(head)) THEN
    CALL PUSHREAL8ARRAY(head, SIZE(head, 1)*SIZE(head, 2)*SIZE(head, 3)*&
&                 SIZE(head, 4))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(conv_ipos)) THEN
    CALL PUSHINTEGER8ARRAY(conv_ipos, SIZE(conv_ipos, 1)*SIZE(conv_ipos&
&                    , 2))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(x)) THEN
    CALL PUSHREAL8ARRAY(x, SIZE(x, 1)*SIZE(x, 2)*SIZE(x, 3)*SIZE(x, 4))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(headold)) THEN
    CALL PUSHREAL8ARRAY(headold, SIZE(headold, 1)*SIZE(headold, 2)*SIZE(&
&                 headold, 3))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(w)) THEN
    CALL PUSHREAL8ARRAY(w, SIZE(w, 1)*SIZE(w, 2)*SIZE(w, 3)*SIZE(w, 4))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(lcon)) THEN
    CALL PUSHBOOLEANARRAY(lcon, SIZE(lcon, 1)*SIZE(lcon, 2))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(conc_conv)) THEN
    CALL PUSHREAL8ARRAY(conc_conv, SIZE(conc_conv, 1)*SIZE(conc_conv, 2)&
&                )
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(conv_chlen)) THEN
    CALL PUSHINTEGER8ARRAY(conv_chlen, SIZE(conv_chlen, 1)*SIZE(&
&                    conv_chlen, 2))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  IF (ALLOCATED(temp)) THEN
    CALL PUSHREAL8ARRAY(temp, SIZE(temp, 1)*SIZE(temp, 2)*SIZE(temp, 3)*&
&                 SIZE(temp, 4))
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
  IF (ALLOCATED(concold)) THEN
    CALL PUSHREAL8ARRAY(concold, SIZE(concold, 1)*SIZE(concold, 2)*SIZE(&
&                 concold, 3)*SIZE(concold, 4))
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
  IF (ALLOCATED(conv_history)) THEN
    CALL PUSHREAL8ARRAY(conv_history, SIZE(conv_history, 1)*SIZE(&
&                 conv_history, 2)*SIZE(conv_history, 3))
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
  IF (ALLOCATED(d)) THEN
    CALL PUSHREAL8ARRAY(d, SIZE(d, 1)*SIZE(d, 2)*SIZE(d, 3)*SIZE(d, 4))
    CALL PUSHCONTROL1B(1)
  ELSE
    CALL PUSHCONTROL1B(0)
  END IF
  CALL PUSHINTEGER8(iter_nlold)
  CALL FORWARD_WRAPPER(itimestep, iseed, ismpl)
! ##################################
! save and collect the computed values for:
! - comparison with 'ddata(*,cid_pv)' (observed data)
! - data-output (write_data.f)
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
  IF (ALLOCATED(dbc_data)) THEN
    CALL PUSHREAL8ARRAY(dbc_data, SIZE(dbc_data, 1)*SIZE(dbc_data, 2)*&
&                 SIZE(dbc_data, 3))
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
  CALL SAVE_DATA(ismpl)
  IF (transient) THEN
! Update simulation time
    simtime(ismpl) = simtime(ismpl) + deltt
!            call write_monitor(2,ismpl)
!            call write_monitor_user(2,ismpl)
! Write to status_log
    IF (.NOT.write_iter_disable .AND. iseed .EQ. 0) THEN
! Status log info to standard out
      IF (linfos(1) .GE. 1) THEN
        CALL PUSHCONTROL1B(0)
        res = LBLANK(status_log)
        WRITE(*, '(3A)') '  [W] : "', status_log(1:res), '"'
      ELSE
        CALL PUSHCONTROL1B(0)
      END IF
      OPEN(76, file=status_log, status='unknown', position='append') 
      WRITE(76, fmt='(I8,1e14.6,1e14.6)') itimestep, deltt, simtime(&
&     ismpl)/tunit
      CLOSE(76) 
    ELSE
      CALL PUSHCONTROL1B(1)
    END IF
! Check for variable time stepping divergence flag
    IF (flag_delt(ismpl) .EQ. -2) THEN
! Restore old values of variable arrays if time step was
! halfed (restoring simtime is handled in "deltat")
      IF (ALLOCATED(pres)) THEN
        CALL PUSHREAL8ARRAY(pres, SIZE(pres, 1)*SIZE(pres, 2)*SIZE(pres&
&                     , 3)*SIZE(pres, 4))
        CALL PUSHCONTROL1B(1)
      ELSE
        CALL PUSHCONTROL1B(0)
      END IF
      CALL OLD_RESTORE(cgen_time, ismpl)
      CALL PUSHCONTROL1B(0)
    ELSE
      CALL PUSHCONTROL1B(1)
    END IF
! Set variable time stepping divergence flag to zero to
! avoid double calling of deltat.
    CALL PUSHINTEGER8(flag_delt(ismpl))
    flag_delt(ismpl) = 0
    deltt = DELTAT(simtime(ismpl), ismpl)
    CALL PUSHCONTROL1B(0)
  ELSE
    CALL PUSHCONTROL1B(1)
  END IF
! Important: This if statement (with the goto) needs to be
! outside of the other "transient" scopes, to generate
! reverse-mode code!
  IF (transient .AND. simtime(ismpl) .LT. simtime_end) THEN
    ad_count = ad_count + 1
    GOTO 1000
  END IF
  CALL PUSHINTEGER8(ad_count)
! --------------- 1000: return to next time step ----------------------
! Postprocessing
! --------------
! Write to status_log and status_log_inv
  IF (transient .AND. runmode .GE. 2 .AND. (.NOT.write_iter_disable) &
&     .AND. iseed .EQ. 0) THEN
    res0 = LBLANK(status_log)
    WRITE(*, '(3A)') '  [W] : "', status_log(1:res0), '"'
    OPEN(76, file=status_log, status='unknown', position='append') 
    WRITE(76, '(1A)') key_char//' transient end'
    CLOSE(76) 
    OPEN(76, file=status_log_inv, status='unknown', position='append') 
    WRITE(76, '(1A,I8,1e14.6,1e14.6)') key_char//' transient: ', &
&   itimestep, deltt, simtime(ismpl)/tunit
    CLOSE(76) 
  END IF
! Standard output: steady state
  IF (iter_out .GT. 0 .AND. linfos(1) .GE. 1 .AND. (.NOT.transient) &
&     .AND. iseed .EQ. 0) WRITE(*, '(29X,1A)') &
&                         ' ===> leaving nonlinear iteration'
! Standard output: transient
  IF (linfos(1) .GE. 0 .AND. transient .AND. iseed .EQ. 0) WRITE(*, &
&                                                    '(1A,I8,1A,1e14.6)'&
&                                                         ) &
&                                           '  [I] : final time step = '&
&                                                          , itimestep, &
&                                                    ', simulation time'&
&                                                          , simtime(&
&                                                          ismpl)/tunit
  CALL POPINTEGER8(ad_count)
  DO i=1,ad_count
    IF (i .EQ. 1) THEN
      IF (ALLOCATED(d_ad)) d_ad = 0.D0
      IF (ALLOCATED(e_ad)) e_ad = 0.D0
      IF (ALLOCATED(f_ad)) f_ad = 0.D0
      IF (ALLOCATED(concold_ad)) concold_ad = 0.D0
      IF (ALLOCATED(g_ad)) g_ad = 0.D0
      IF (ALLOCATED(temp_ad)) temp_ad = 0.D0
      IF (ALLOCATED(w_ad)) w_ad = 0.D0
      IF (ALLOCATED(headold_ad)) headold_ad = 0.D0
      IF (ALLOCATED(x_ad)) x_ad = 0.D0
      IF (ALLOCATED(head_ad)) head_ad = 0.D0
      IF (ALLOCATED(dbc_data_ad)) dbc_data_ad = 0.D0
      IF (ALLOCATED(bcperiod_ad)) bcperiod_ad = 0.D0
      IF (ALLOCATED(tempold_ad)) tempold_ad = 0.D0
      IF (ALLOCATED(propunit_ad)) propunit_ad = 0.D0
      IF (ALLOCATED(presold_ad)) presold_ad = 0.D0
      IF (ALLOCATED(conc_ad)) conc_ad = 0.D0
      IF (ALLOCATED(pres_ad)) pres_ad = 0.D0
      IF (ALLOCATED(a_ad)) a_ad = 0.D0
      IF (ALLOCATED(b_ad)) b_ad = 0.D0
      IF (ALLOCATED(c_ad)) c_ad = 0.D0
    END IF
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 0) THEN
      CALL POPINTEGER8(flag_delt(ismpl))
      CALL POPCONTROL1B(branch)
      IF (branch .EQ. 0) THEN
        CALL POPCONTROL1B(branch)
        IF (branch .EQ. 1) CALL POPREAL8ARRAY(pres, SIZE(pres, 1)*SIZE(&
&                                       pres, 2)*SIZE(pres, 3)*SIZE(pres&
&                                       , 4))
        CALL OLD_RESTORE_AD(cgen_time, ismpl)
      END IF
      CALL POPCONTROL1B(branch)
    END IF
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(delt_old, SIZE(delt_old, 1))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(dbc_data, SIZE(dbc_data, 1)*&
&                                   SIZE(dbc_data, 2)*SIZE(dbc_data, 3))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPINTEGER8ARRAY(flag_1st_timestep, SIZE(&
&                                      flag_1st_timestep, 1))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPINTEGER8ARRAY(delt_count, SIZE(delt_count&
&                                      , 1))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(simtime, SIZE(simtime, 1))
    CALL SAVE_DATA_AD(ismpl)
    CALL POPINTEGER8(iter_nlold)
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(d, SIZE(d, 1)*SIZE(d, 2)*SIZE(&
&                                   d, 3)*SIZE(d, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(e, SIZE(e, 1)*SIZE(e, 2)*SIZE(&
&                                   e, 3)*SIZE(e, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(conv_history, SIZE(&
&                                   conv_history, 1)*SIZE(conv_history, &
&                                   2)*SIZE(conv_history, 3))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(f, SIZE(f, 1)*SIZE(f, 2)*SIZE(&
&                                   f, 3)*SIZE(f, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(concold, SIZE(concold, 1)*SIZE&
&                                   (concold, 2)*SIZE(concold, 3)*SIZE(&
&                                   concold, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(g, SIZE(g, 1)*SIZE(g, 2)*SIZE(&
&                                   g, 3)*SIZE(g, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(temp, SIZE(temp, 1)*SIZE(temp&
&                                   , 2)*SIZE(temp, 3)*SIZE(temp, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPINTEGER8ARRAY(conv_chlen, SIZE(conv_chlen&
&                                      , 1)*SIZE(conv_chlen, 2))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(conc_conv, SIZE(conc_conv, 1)*&
&                                   SIZE(conc_conv, 2))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPBOOLEANARRAY(lcon, SIZE(lcon, 1)*SIZE(&
&                                     lcon, 2))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(w, SIZE(w, 1)*SIZE(w, 2)*SIZE(&
&                                   w, 3)*SIZE(w, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(headold, SIZE(headold, 1)*SIZE&
&                                   (headold, 2)*SIZE(headold, 3))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(x, SIZE(x, 1)*SIZE(x, 2)*SIZE(&
&                                   x, 3)*SIZE(x, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPINTEGER8ARRAY(conv_ipos, SIZE(conv_ipos, &
&                                      1)*SIZE(conv_ipos, 2))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(head, SIZE(head, 1)*SIZE(head&
&                                   , 2)*SIZE(head, 3)*SIZE(head, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(omp_dglobal, SIZE(omp_dglobal&
&                                   , 1)*SIZE(omp_dglobal, 2)*SIZE(&
&                                   omp_dglobal, 3))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(delt_old, SIZE(delt_old, 1))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(dbc_data, SIZE(dbc_data, 1)*&
&                                   SIZE(dbc_data, 2)*SIZE(dbc_data, 3))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPINTEGER8ARRAY(omp_iglobal, SIZE(&
&                                      omp_iglobal, 1)*SIZE(omp_iglobal&
&                                      , 2)*SIZE(omp_iglobal, 3))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(tempold, SIZE(tempold, 1)*SIZE&
&                                   (tempold, 2)*SIZE(tempold, 3))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPINTEGER8ARRAY(flag_1st_timestep, SIZE(&
&                                      flag_1st_timestep, 1))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPINTEGER8ARRAY(flag_delt, SIZE(flag_delt, &
&                                      1))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPINTEGER8ARRAY(delt_count, SIZE(delt_count&
&                                      , 1))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(conc, SIZE(conc, 1)*SIZE(conc&
&                                   , 2)*SIZE(conc, 3)*SIZE(conc, 4)*&
&                                   SIZE(conc, 5))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(pres, SIZE(pres, 1)*SIZE(pres&
&                                   , 2)*SIZE(pres, 3)*SIZE(pres, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(simtime, SIZE(simtime, 1))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(a, SIZE(a, 1)*SIZE(a, 2)*SIZE(&
&                                   a, 3)*SIZE(a, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(b, SIZE(b, 1)*SIZE(b, 2)*SIZE(&
&                                   b, 3)*SIZE(b, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(c, SIZE(c, 1)*SIZE(c, 2)*SIZE(&
&                                   c, 3)*SIZE(c, 4))
    CALL FORWARD_WRAPPER_AD(itimestep, iseed, ismpl)
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 0) THEN
      CALL OLD_SAVE_AD(cgen_time, ismpl)
      CALL POPINTEGER8(flag_delt(ismpl))
      CALL POPINTEGER8(itimestep)
    END IF
  END DO
  CALL POPCONTROL1B(branch)
  IF (branch .EQ. 0) THEN
    CALL POPBOOLEAN(tr_switch(ismpl))
    CALL POPINTEGER8(iter_nlold)
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(d, SIZE(d, 1)*SIZE(d, 2)*SIZE(&
&                                   d, 3)*SIZE(d, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(e, SIZE(e, 1)*SIZE(e, 2)*SIZE(&
&                                   e, 3)*SIZE(e, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(conv_history, SIZE(&
&                                   conv_history, 1)*SIZE(conv_history, &
&                                   2)*SIZE(conv_history, 3))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(f, SIZE(f, 1)*SIZE(f, 2)*SIZE(&
&                                   f, 3)*SIZE(f, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(concold, SIZE(concold, 1)*SIZE&
&                                   (concold, 2)*SIZE(concold, 3)*SIZE(&
&                                   concold, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(g, SIZE(g, 1)*SIZE(g, 2)*SIZE(&
&                                   g, 3)*SIZE(g, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(temp, SIZE(temp, 1)*SIZE(temp&
&                                   , 2)*SIZE(temp, 3)*SIZE(temp, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPINTEGER8ARRAY(conv_chlen, SIZE(conv_chlen&
&                                      , 1)*SIZE(conv_chlen, 2))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(conc_conv, SIZE(conc_conv, 1)*&
&                                   SIZE(conc_conv, 2))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPBOOLEANARRAY(lcon, SIZE(lcon, 1)*SIZE(&
&                                     lcon, 2))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(w, SIZE(w, 1)*SIZE(w, 2)*SIZE(&
&                                   w, 3)*SIZE(w, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(headold, SIZE(headold, 1)*SIZE&
&                                   (headold, 2)*SIZE(headold, 3))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(x, SIZE(x, 1)*SIZE(x, 2)*SIZE(&
&                                   x, 3)*SIZE(x, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPINTEGER8ARRAY(conv_ipos, SIZE(conv_ipos, &
&                                      1)*SIZE(conv_ipos, 2))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(head, SIZE(head, 1)*SIZE(head&
&                                   , 2)*SIZE(head, 3)*SIZE(head, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(omp_dglobal, SIZE(omp_dglobal&
&                                   , 1)*SIZE(omp_dglobal, 2)*SIZE(&
&                                   omp_dglobal, 3))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(delt_old, SIZE(delt_old, 1))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(dbc_data, SIZE(dbc_data, 1)*&
&                                   SIZE(dbc_data, 2)*SIZE(dbc_data, 3))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPINTEGER8ARRAY(omp_iglobal, SIZE(&
&                                      omp_iglobal, 1)*SIZE(omp_iglobal&
&                                      , 2)*SIZE(omp_iglobal, 3))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(tempold, SIZE(tempold, 1)*SIZE&
&                                   (tempold, 2)*SIZE(tempold, 3))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPINTEGER8ARRAY(flag_1st_timestep, SIZE(&
&                                      flag_1st_timestep, 1))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPINTEGER8ARRAY(flag_delt, SIZE(flag_delt, &
&                                      1))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPINTEGER8ARRAY(delt_count, SIZE(delt_count&
&                                      , 1))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(conc, SIZE(conc, 1)*SIZE(conc&
&                                   , 2)*SIZE(conc, 3)*SIZE(conc, 4)*&
&                                   SIZE(conc, 5))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(pres, SIZE(pres, 1)*SIZE(pres&
&                                   , 2)*SIZE(pres, 3)*SIZE(pres, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(simtime, SIZE(simtime, 1))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(a, SIZE(a, 1)*SIZE(a, 2)*SIZE(&
&                                   a, 3)*SIZE(a, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(b, SIZE(b, 1)*SIZE(b, 2)*SIZE(&
&                                   b, 3)*SIZE(b, 4))
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 1) CALL POPREAL8ARRAY(c, SIZE(c, 1)*SIZE(c, 2)*SIZE(&
&                                   c, 3)*SIZE(c, 4))
    CALL FORWARD_WRAPPER_AD(itimestep, iseed, ismpl)
  END IF
END SUBROUTINE FORWARD_ITER_AD

