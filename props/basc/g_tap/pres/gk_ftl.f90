!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of gk in forward (tangent) mode:
!   variations   of useful results: gk
!   with respect to varying inputs: *temp *propunit *tsal *pres
!   Plus diff mem management of: temp:in propunit:in tsal:in pres:in
!>    @brief average  conductivities on cell faces in z direction
!>    @param[in] i grid indices
!>    @param[in] j grid indices
!>    @param[in] k grid indices
!>    @param[in] ismpl local sample index
!>    @return z  conductivity (m/(Pa s))
DOUBLE PRECISION FUNCTION g_GK(i, j, k, ismpl, gk)
  USE ARRAYS

  USE g_ARRAYS

  USE MOD_GENRL
  USE MOD_FLOW
  IMPLICIT NONE
  INTEGER :: ismpl
  INTEGER :: i, j, k
  EXTERNAL KZ, RHOF, VISF
  EXTERNAL g_KZ, g_VISF
  DOUBLE PRECISION :: f1, f2, prod, summ, KZ, RHOF, VISF
  DOUBLE PRECISION :: g_f1, g_f2, g_prod, g_summ, g_KZ, &
& g_VISF
  DOUBLE PRECISION :: result1
  DOUBLE PRECISION :: g_result1
  DOUBLE PRECISION :: result2
  DOUBLE PRECISION :: g_result2
  DOUBLE PRECISION :: gk
  gk = 0.d0
  IF (k0 .GT. 1 .AND. k .LT. k0) THEN
    g_result1 = g_KZ(i, j, k, ismpl, result1)
    g_result2 = g_VISF(i, j, k, ismpl, result2)
    g_f1 = (g_result1-result1*g_result2/result2)/result2
    f1 = result1/result2
    g_result1 = g_KZ(i, j, k + 1, ismpl, result1)
    g_result2 = g_VISF(i, j, k + 1, ismpl, result2)
    g_f2 = (g_result1-result1*g_result2/result2)/result2
    f2 = result1/result2
    g_prod = f2*g_f1 + f1*g_f2
    prod = f1*f2
    g_summ = delz(k+1)*g_f1 + delz(k)*g_f2
    summ = f1*delz(k+1) + f2*delz(k)
    IF (summ .GT. 0.d0) THEN
      g_gk = 2.d0*(g_prod-prod*g_summ/summ)/summ
      gk = 2.d0*prod/summ
    ELSE
      g_gk = 0.D0
    END IF
  ELSE
    g_gk = 0.D0
  END IF
  RETURN
END FUNCTION g_GK

