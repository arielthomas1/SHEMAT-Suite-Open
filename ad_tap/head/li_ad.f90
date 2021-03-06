!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of li in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: *temp *propunit *tsal li
!   with respect to varying inputs: *temp *propunit *tsal
!   Plus diff mem management of: temp:in propunit:in tsal:in pres:in
!>    @brief average thermal conductivities on cell faces in x direction
!>    @param[in] i grid indices
!>    @param[in] j grid indices
!>    @param[in] k grid indices
!>    @param[in] ismpl local sample index
!>    @return x thermal conductivity (J/mK)
SUBROUTINE LI_AD(i, j, k, ismpl, li_adv)
  use arrays

  USE ARRAYS_AD

  USE MOD_GENRL
  USE MOD_TEMP
  IMPLICIT NONE
  double precision :: li_adv
  INTEGER :: ismpl
  INTEGER :: i, j, k
  EXTERNAL LX
  EXTERNAL LX_AD
  DOUBLE PRECISION :: f1, f2, prod, summ, LX
  DOUBLE PRECISION :: f1_ad, f2_ad, prod_ad, summ_ad
  INTEGER :: arg1
  DOUBLE PRECISION :: temporary_ad
  DOUBLE PRECISION :: li
  IF (i0 .GT. 1 .AND. i .LT. i0) THEN
    f1 = LX(i, j, k, ismpl)
    arg1 = i + 1
    f2 = LX(arg1, j, k, ismpl)
    prod = f1*f2
    summ = f1*delx(i+1) + f2*delx(i)
    IF (summ .GT. 0.d0) THEN
      temporary_ad = 2.d0*li_adv/summ
      prod_ad = temporary_ad
      summ_ad = -(prod*temporary_ad/summ)
    ELSE
      prod_ad = 0.D0
      summ_ad = 0.D0
    END IF
    f1_ad = delx(i+1)*summ_ad + f2*prod_ad
    f2_ad = delx(i)*summ_ad + f1*prod_ad
    CALL LX_AD(arg1, j, k, ismpl, f2_ad)
    CALL LX_AD(i, j, k, ismpl, f1_ad)
  END IF
END SUBROUTINE LI_AD

