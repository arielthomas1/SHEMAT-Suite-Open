!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of vy in forward (tangent) mode:
!   variations   of useful results: vy
!   with respect to varying inputs: *temp *head *propunit *tsal
!                *pres
!   Plus diff mem management of: temp:in head:in propunit:in tsal:in
!                pres:in
!>    @brief calculate velocities at cell  faces
!>    @param[in] i grid indices
!>    @param[in] j grid indices
!>    @param[in] k grid indices
!>    @param[in] ismpl local sample index
!>    @return y velocity (m/s)
DOUBLE PRECISION FUNCTION g_VY(i, j, k, ismpl, vy)
  USE ARRAYS

  USE g_ARRAYS

  USE MOD_GENRL
  IMPLICIT NONE
  INTEGER :: ismpl
  INTEGER :: i, j, k
  EXTERNAL TJ
  EXTERNAL g_TJ
  DOUBLE PRECISION :: dif, TJ
  DOUBLE PRECISION :: g_dif, g_TJ
  EXTERNAL DUMMY
  DOUBLE PRECISION :: result1
  DOUBLE PRECISION :: g_result1
  DOUBLE PRECISION :: vy
  vy = 0.d0
  IF (.NOT.head_active .AND. vdefaultswitch) vy = vdefault(2, ismpl)
  IF (j0 .GT. 1 .AND. j .LT. j0 .AND. head_active) THEN
#ifdef head_base
    g_dif = g_head(i, j+1, k, ismpl) - g_head(i, j, k, ismpl)
    dif = head(i, j+1, k, ismpl) - head(i, j, k, ismpl)
    g_result1 = g_TJ(i, j, k, ismpl, result1)
    g_vy = -(dif*g_result1+result1*g_dif)
    vy = -(result1*dif)
#endif
  ELSE
    g_vy = 0.D0
  END IF
  RETURN
END FUNCTION g_VY

