!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of vz in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: *temp *propunit *pres vz
!   with respect to varying inputs: *temp *propunit *pres
!   Plus diff mem management of: temp:in propunit:in pres:in
!>    @brief calculate velocities at cell faces
!>    @param[in] i grid indices
!>    @param[in] j grid indices
!>    @param[in] k grid indices
!>    @param[in] ismpl local sample index
!>    @return z velocity (m/(Pa s))
SUBROUTINE VZ_AD(i, j, k, ismpl, vz_adv)
  use arrays

  USE ARRAYS_AD

  USE MOD_GENRL
  USE MOD_FLOW
  IMPLICIT NONE
  double precision :: vz_adv
  INTEGER :: ismpl
  INTEGER :: i, j, k
  EXTERNAL GK, RHOF, POR
  EXTERNAL GK_AD0, RHOF_AD
  DOUBLE PRECISION :: f1, f2, dif, GK, vbuoy, POR, &
& RHOF, rhav
  DOUBLE PRECISION :: dif_ad, rhav_ad
  DOUBLE PRECISION :: result1
  DOUBLE PRECISION :: result1_ad
  INTEGER :: arg1
  INTEGER :: branch
  DOUBLE PRECISION :: vz
  IF (k0 .GT. 1 .AND. k .LT. k0) THEN
!          rhav = 0.5D0*(rhof(i,j,k+1,ismpl)+rhof(i,j,k,ismpl))&
!                *(delza(k+1 )-delza(k))
    dif = pres(i, j, k+1, ismpl) - pres(i, j, k, ismpl)
    result1 = POR(i, j, k, ismpl)
    IF (result1 .GT. 1.e-19) THEN
      rhav = RHOF(i, j, k, ismpl)
      CALL PUSHCONTROL1B(0)
    ELSE
      CALL PUSHCONTROL1B(1)
      rhav = 1.29e0
    END IF
    arg1 = k + 1
    result1 = POR(i, j, arg1, ismpl)
    IF (result1 .GT. 1.e-19) THEN
      arg1 = k + 1
      result1 = RHOF(i, j, arg1, ismpl)
      rhav = rhav + result1
      CALL PUSHCONTROL1B(0)
    ELSE
      CALL PUSHCONTROL1B(1)
      rhav = rhav + 1.29e0
    END IF
    rhav = 0.5*rhav*(delza(k+1)-delza(k))
    dif = dif + rhav*grav
! - vbuoy(i,j,k,ismpl)
    result1 = GK(i, j, k, ismpl)
    result1_ad = -(dif*vz_adv)
    dif_ad = -(result1*vz_adv)
    CALL GK_AD0(i, j, k, ismpl, result1_ad)
    rhav_ad = grav*dif_ad
    rhav_ad = 0.5*(delza(k+1)-delza(k))*rhav_ad
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 0) THEN
      result1_ad = rhav_ad
      CALL RHOF_AD(i, j, arg1, ismpl, result1_ad)
    END IF
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 0) CALL RHOF_AD(i, j, k, ismpl, rhav_ad)
    pres_ad(i, j, k+1, ismpl) = pres_ad(i, j, k+1, ismpl) + dif_ad
    pres_ad(i, j, k, ismpl) = pres_ad(i, j, k, ismpl) - dif_ad
  END IF
END SUBROUTINE VZ_AD

