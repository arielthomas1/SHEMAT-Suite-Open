!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of vz in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: *temp *head *propunit *tsal
!                *pres vz
!   with respect to varying inputs: *temp *head *propunit *tsal
!                *pres
!   Plus diff mem management of: temp:in head:in propunit:in tsal:in
!                pres:in
!>    @brief calculate velocities at cell  faces
!>    @param[in] i grid indices
!>    @param[in] j grid indices
!>    @param[in] k grid indices
!>    @param[in] ismpl local sample index
!>    @return z velocity (m/s)
SUBROUTINE VZ_AD(i, j, k, ismpl, vz_adv)
  use arrays

  USE ARRAYS_AD

  USE MOD_GENRL
  IMPLICIT NONE
  double precision :: vz_adv
  INTEGER :: ismpl
  INTEGER :: i, j, k
  EXTERNAL TK, BUOY
  EXTERNAL TK_AD, BUOY_AD
  DOUBLE PRECISION :: dif, TK, BUOY
  DOUBLE PRECISION :: dif_ad
  DOUBLE PRECISION :: result1
  DOUBLE PRECISION :: result1_ad
  DOUBLE PRECISION :: result2
  DOUBLE PRECISION :: result2_ad
  DOUBLE PRECISION :: vz
  IF (k0 .GT. 1 .AND. k .LT. k0 .AND. head_active) THEN
    dif = head(i, j, k+1, ismpl) - head(i, j, k, ismpl)
    result1 = TK(i, j, k, ismpl)
    result1_ad = -(dif*vz_adv)
    dif_ad = -(result1*vz_adv)
    result2_ad = -vz_adv
    CALL BUOY_AD(i, j, k, ismpl, result2_ad)
    CALL TK_AD(i, j, k, ismpl, result1_ad)
    head_ad(i, j, k+1, ismpl) = head_ad(i, j, k+1, ismpl) + dif_ad
    head_ad(i, j, k, ismpl) = head_ad(i, j, k, ismpl) - dif_ad
  END IF
END SUBROUTINE VZ_AD

