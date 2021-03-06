!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of omp_old_restore in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: *concold *temp *headold *head
!                *tempold *presold *conc *pres
!   with respect to varying inputs: *concold *temp *headold *head
!                *tempold *presold *conc *pres
!   Plus diff mem management of: concold:in temp:in headold:in
!                head:in tempold:in presold:in conc:in pres:in
!>    @brief restores an old state/version
!>    @param[in] level level number (which old version)
!>    @param[in] ismpl local sample index
SUBROUTINE OMP_OLD_RESTORE_AD(level, ismpl)
  use arrays

  USE ARRAYS_AD

  USE MOD_GENRL
  USE MOD_CONC
  IMPLICIT NONE
  INTEGER :: ismpl
  INTEGER :: i, j, k, l
  INTEGER :: level, tpos, tanz
  INTRINSIC ABS, MAX
  INTEGER :: abs0
  INTEGER :: abs1
  INTEGER :: abs2
  INTEGER :: abs3
  INTEGER :: max1
  INTEGER :: max2
  INTEGER :: max3
  INTEGER :: max4
  INTEGER :: branch
  CALL OMP_PART(i0*j0*k0, tpos, tanz)
  CALL IJK_M(tpos, i, j, k)
  IF (ismpl .GE. 0.) THEN
    abs0 = ismpl
  ELSE
    abs0 = -ismpl
  END IF
  IF (1 .LT. ismpl) THEN
    max1 = ismpl
  ELSE
    max1 = 1
  END IF
!     save state (before)
  IF (ismpl .GE. 0.) THEN
    abs1 = ismpl
  ELSE
    abs1 = -ismpl
  END IF
  IF (1 .LT. ismpl) THEN
    max2 = ismpl
  ELSE
    max2 = 1
  END IF
  IF (ismpl .GE. 0.) THEN
    abs2 = ismpl
  ELSE
    abs2 = -ismpl
  END IF
  IF (1 .LT. ismpl) THEN
    max3 = ismpl
  ELSE
    max3 = 1
  END IF
  DO l=1,ntrans
    IF (ismpl .GE. 0.) THEN
      CALL PUSHINTEGER8(abs3)
      abs3 = ismpl
      CALL PUSHCONTROL1B(1)
    ELSE
      CALL PUSHINTEGER8(abs3)
      abs3 = -ismpl
      CALL PUSHCONTROL1B(0)
    END IF
    IF (1 .LT. ismpl) THEN
      CALL PUSHINTEGER8(max4)
      max4 = ismpl
      CALL PUSHCONTROL1B(0)
    ELSE
      CALL PUSHINTEGER8(max4)
      max4 = 1
      CALL PUSHCONTROL1B(1)
    END IF
  END DO
  DO l=ntrans,1,-1
    CALL DCOPY_AD(tanz, concold(tpos, l, level, abs3), concold_ad(tpos, &
&           l, level, abs3), 1, conc(i, j, k, l, max4), conc_ad(i, j, k&
&           , l, max4), 1)
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 0) THEN
      CALL POPINTEGER8(max4)
    ELSE
      CALL POPINTEGER8(max4)
    END IF
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 0) THEN
      CALL POPINTEGER8(abs3)
    ELSE
      CALL POPINTEGER8(abs3)
    END IF
  END DO
  CALL DCOPY_AD(tanz, presold(tpos, level, abs2), presold_ad(tpos, level&
&         , abs2), 1, pres(i, j, k, max3), pres_ad(i, j, k, max3), 1)
  CALL DCOPY_AD(tanz, tempold(tpos, level, abs1), tempold_ad(tpos, level&
&         , abs1), 1, temp(i, j, k, max2), temp_ad(i, j, k, max2), 1)
  CALL DCOPY_AD(tanz, headold(tpos, level, abs0), headold_ad(tpos, level&
&         , abs0), 1, head(i, j, k, max1), head_ad(i, j, k, max1), 1)
END SUBROUTINE OMP_OLD_RESTORE_AD

