!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of gj in forward (tangent) mode:
!   variations   of useful results: gj
!   with respect to varying inputs: *temp *propunit *pres
!   Plus diff mem management of: temp:in propunit:in pres:in
!>    @brief average  conductivities on cell faces in y direction
!>    @param[in] i grid indices
!>    @param[in] j grid indices
!>    @param[in] k grid indices
!>    @param[in] ismpl local sample index
!>    @return y  conductivity (m/(Pa s))
DOUBLE PRECISION FUNCTION g_GJ(i, j, k, ismpl, gj)
  USE ARRAYS

  USE g_ARRAYS

  USE MOD_GENRL
  USE MOD_FLOW
  IMPLICIT NONE
  INTEGER :: ismpl
  INTEGER :: i, j, k
  EXTERNAL KY, RHOF, VISF
  EXTERNAL g_KY, g_VISF
  DOUBLE PRECISION :: f1, f2, prod, summ, KY, RHOF, VISF
  DOUBLE PRECISION :: g_f1, g_f2, g_prod, g_summ, g_KY, &
& g_VISF
  DOUBLE PRECISION :: result1
  DOUBLE PRECISION :: g_result1
  DOUBLE PRECISION :: result2
  DOUBLE PRECISION :: g_result2
  DOUBLE PRECISION :: gj
  gj = 0.d0
  IF (j0 .GT. 1 .AND. j .LT. j0) THEN
    g_result1 = g_KY(i, j, k, ismpl, result1)
    g_result2 = g_VISF(i, j, k, ismpl, result2)
    g_f1 = (g_result1-result1*g_result2/result2)/result2
    f1 = result1/result2
    g_result1 = g_KY(i, j + 1, k, ismpl, result1)
    g_result2 = g_VISF(i, j + 1, k, ismpl, result2)
    g_f2 = (g_result1-result1*g_result2/result2)/result2
    f2 = result1/result2
    g_prod = f2*g_f1 + f1*g_f2
    prod = f1*f2
    g_summ = dely(j+1)*g_f1 + dely(j)*g_f2
    summ = f1*dely(j+1) + f2*dely(j)
    IF (summ .GT. 0.d0) THEN
      g_gj = 2.d0*(g_prod-prod*g_summ/summ)/summ
      gj = 2.d0*prod/summ
    ELSE
      g_gj = 0.D0
    END IF
  ELSE
    g_gj = 0.D0
  END IF
  RETURN
END FUNCTION g_GJ

