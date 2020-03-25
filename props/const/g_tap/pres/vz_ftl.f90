!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of vz in forward (tangent) mode:
!   variations   of useful results: vz
!   with respect to varying inputs: *propunit *pres
!   Plus diff mem management of: propunit:in pres:in
!>    @brief calculate velocities at cell faces
!>    @param[in] i grid indices
!>    @param[in] j grid indices
!>    @param[in] k grid indices
!>    @param[in] ismpl local sample index
!>    @return z velocity (m/(Pa s))
DOUBLE PRECISION FUNCTION g_VZ(i, j, k, ismpl, vz)
  USE ARRAYS

  USE g_ARRAYS

  USE MOD_GENRL
  USE MOD_FLOW
  IMPLICIT NONE
  INTEGER :: ismpl
  INTEGER :: i, j, k
  EXTERNAL GK, RHOF, POR
  EXTERNAL g_GK
  DOUBLE PRECISION :: f1, f2, dif, GK, vbuoy, POR, RHOF, &
& rhav
  DOUBLE PRECISION :: g_dif, g_GK
  DOUBLE PRECISION :: result1
  DOUBLE PRECISION :: g_result1
  DOUBLE PRECISION :: vz
  vz = 0.d0
  IF (k0 .GT. 1 .AND. k .LT. k0) THEN
!          rhav = 0.5D0*(rhof(i,j,k+1,ismpl)+rhof(i,j,k,ismpl))&
!                *(delza(k+1 )-delza(k))
    g_dif = g_pres(i, j, k+1, ismpl) - g_pres(i, j, k, ismpl)
    dif = pres(i, j, k+1, ismpl) - pres(i, j, k, ismpl)
    result1 = POR(i, j, k, ismpl)
    IF (result1 .GT. 1.e-19) THEN
      rhav = RHOF(i, j, k, ismpl)
    ELSE
      rhav = 1.29e0
    END IF
    result1 = POR(i, j, k + 1, ismpl)
    IF (result1 .GT. 1.e-19) THEN
      result1 = RHOF(i, j, k + 1, ismpl)
      rhav = rhav + result1
    ELSE
      rhav = rhav + 1.29e0
    END IF
    rhav = 0.5*rhav*(delza(k+1)-delza(k))
    dif = dif + rhav*grav
! - vbuoy(i,j,k,ismpl)
    g_result1 = g_GK(i, j, k, ismpl, result1)
    g_vz = -(dif*g_result1+result1*g_dif)
    vz = -(result1*dif)
  ELSE
    g_vz = 0.D0
  END IF
  RETURN
END FUNCTION g_VZ

