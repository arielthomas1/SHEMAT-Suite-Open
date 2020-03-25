!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of dj in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: *head *propunit dj
!   with respect to varying inputs: *head *propunit
!   Plus diff mem management of: head:in propunit:in
!>    @brief average effective diffusivities on cell faces in y direction
!>    @param[in] i grid indices
!>    @param[in] j grid indices
!>    @param[in] k grid indices
!>    @param[in] spec species
!>    @param[in] ismpl local sample index
!>    @return effective diffusivities (J/mK)
SUBROUTINE DJ_AD(i, j, k, spec, ismpl, dj_adv)
  use arrays

  USE ARRAYS_AD

  USE MOD_GENRL
  IMPLICIT NONE
  double precision :: dj_adv
  INTEGER :: ismpl
  INTEGER :: i, j, k
  INTEGER :: spec
  DOUBLE PRECISION :: f1, f2, prod, summ, betx, bety, betz, bet
  DOUBLE PRECISION :: f1_ad, f2_ad, prod_ad, summ_ad, betx_ad, bety_ad, &
& betz_ad, bet_ad
  EXTERNAL POR, DISP, VY, VX, VZ
  EXTERNAL POR_AD0, DISP_AD0, VY_AD, VX_AD, VZ_AD
  DOUBLE PRECISION :: POR, DISP, VY, VX, &
& VZ
  INTRINSIC SQRT
  DOUBLE PRECISION :: result1
  DOUBLE PRECISION :: result1_ad
  DOUBLE PRECISION :: result2
  DOUBLE PRECISION :: result2_ad
  INTEGER :: arg1
  INTEGER :: arg2
  DOUBLE PRECISION :: temporary_ad
  INTEGER :: branch
  DOUBLE PRECISION :: dj
  betx = 0.d0
  betz = 0.d0
  IF (k0 .GT. 1 .AND. k .LT. k0) THEN
    betz = VZ(i, j, k, ismpl)
    CALL PUSHREAL8(betz)
    betz = betz*betz
    CALL PUSHCONTROL1B(0)
  ELSE
    CALL PUSHCONTROL1B(1)
  END IF
  IF (i0 .GT. 1 .AND. i .LT. i0) THEN
    betx = VX(i, j, k, ismpl)
    CALL PUSHREAL8(betx)
    betx = betx*betx
    CALL PUSHCONTROL1B(0)
  ELSE
    CALL PUSHCONTROL1B(1)
  END IF
  IF (j0 .GT. 1 .AND. j .LT. j0) THEN
    bety = VY(i, j, k, ismpl)
    CALL PUSHREAL8(bety)
    bety = bety*bety
    bet = SQRT(betx + bety + betz)
    result1 = POR(i, j, k, ismpl)
    result2 = DISP(i, j, k, ismpl)
    f1 = result1*diff_c(spec) + result2*bet
    arg1 = j + 1
    result1 = POR(i, arg1, k, ismpl)
    arg2 = j + 1
    CALL PUSHREAL8(result2)
    result2 = DISP(i, arg2, k, ismpl)
    f2 = result1*diff_c(spec) + result2*bet
    prod = f1*f2
    summ = f1*dely(j+1) + f2*dely(j)
    IF (summ .GT. 0.d0) THEN
      temporary_ad = 2.d0*dj_adv/summ
      prod_ad = temporary_ad
      summ_ad = -(prod*temporary_ad/summ)
    ELSE
      prod_ad = 0.D0
      summ_ad = 0.D0
    END IF
    f1_ad = dely(j+1)*summ_ad + f2*prod_ad
    f2_ad = dely(j)*summ_ad + f1*prod_ad
    result1_ad = diff_c(spec)*f2_ad
    result2_ad = bet*f2_ad
    bet_ad = result2*f2_ad
    CALL POPREAL8(result2)
    CALL DISP_AD0(i, arg2, k, ismpl, result2_ad)
    CALL POR_AD0(i, arg1, k, ismpl, result1_ad)
    result1_ad = diff_c(spec)*f1_ad
    result2_ad = bet*f1_ad
    bet_ad = bet_ad + result2*f1_ad
    CALL DISP_AD0(i, j, k, ismpl, result2_ad)
    CALL POR_AD0(i, j, k, ismpl, result1_ad)
    IF (betx + bety + betz .EQ. 0.0) THEN
      temporary_ad = 0.D0
    ELSE
      temporary_ad = bet_ad/(2.0*SQRT(betx+bety+betz))
    END IF
    betx_ad = temporary_ad
    bety_ad = temporary_ad
    betz_ad = temporary_ad
    CALL POPREAL8(bety)
    bety_ad = 2*bety*bety_ad
    CALL VY_AD(i, j, k, ismpl, bety_ad)
  ELSE
    betx_ad = 0.D0
    betz_ad = 0.D0
  END IF
  CALL POPCONTROL1B(branch)
  IF (branch .EQ. 0) THEN
    CALL POPREAL8(betx)
    betx_ad = 2*betx*betx_ad
    CALL VX_AD(i, j, k, ismpl, betx_ad)
  END IF
  CALL POPCONTROL1B(branch)
  IF (branch .EQ. 0) THEN
    CALL POPREAL8(betz)
    betz_ad = 2*betz*betz_ad
    CALL VZ_AD(i, j, k, ismpl, betz_ad)
  END IF
END SUBROUTINE DJ_AD

