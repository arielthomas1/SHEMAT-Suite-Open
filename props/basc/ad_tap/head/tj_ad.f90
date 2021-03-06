!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of tj in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: *temp *propunit *tsal *pres
!                tj
!   with respect to varying inputs: *temp *propunit *tsal *pres
!   Plus diff mem management of: temp:in propunit:in tsal:in pres:in
!>    @brief harmonic mean Ky on cell faces in y direction over dely*
!>    @param[in] i grid indices
!>    @param[in] j grid indices
!>    @param[in] k grid indices
!>    @param[in] ismpl local sample index
!>    @return y hydraulic conductivity over dely*  (1/s)
!>    @details
!>    Compute the harmonic mean of Ky on the cell face in positive
!>    y-direction from the current node (i, j, k) divided by the
!>    y-distance of the current node (i, j, k) to the neighboring node
!>    (i, j+1, k).
!>
!>    dely* = 0.5 ( dely(j) + dely(j+1) )
!>
!>    Ky / dely* = [ 0.5*dely(j+1)/K(j+1) + 0.5*dely(j)/K(j) ]**-1
!>
!>               = [ ( 0.5* K(j)* dely(j+1) + 0.5*K(j+1)* dely(j) ) / ( K(j)*K(j+1) ) ]**-1
!>
!>               = [ ( 0.5 * summ ) / (prod) ]**-1 = 2.0*prod/summ
SUBROUTINE TJ_AD(i, j, k, ismpl, tj_adv)
  use arrays

  USE ARRAYS_AD

  USE MOD_GENRL
  USE MOD_FLOW
  IMPLICIT NONE
  double precision :: tj_adv
  INTEGER :: ismpl
  INTEGER :: i, j, k
  EXTERNAL KY, RHOF, VISF
  EXTERNAL KY_AD, RHOF_AD0, VISF_AD
  DOUBLE PRECISION :: f1, f2, prod, summ, KY, RHOF, &
& VISF
  DOUBLE PRECISION :: f1_ad, f2_ad, prod_ad, summ_ad
  DOUBLE PRECISION :: result1
  DOUBLE PRECISION :: result1_ad
  DOUBLE PRECISION :: result2
  DOUBLE PRECISION :: result2_ad
  DOUBLE PRECISION :: result3
  DOUBLE PRECISION :: result3_ad
  INTEGER :: arg1
  INTEGER :: arg2
  INTEGER :: arg3
  DOUBLE PRECISION :: temporary_ad
  DOUBLE PRECISION :: tj
  IF (j0 .GT. 1 .AND. j .LT. j0) THEN
    result1 = KY(i, j, k, ismpl)
    result2 = RHOF(i, j, k, ismpl)
    result3 = VISF(i, j, k, ismpl)
    f1 = result1*result2*grav/result3
    arg1 = j + 1
    CALL PUSHREAL8(result1)
    result1 = KY(i, arg1, k, ismpl)
    arg2 = j + 1
    CALL PUSHREAL8(result2)
    result2 = RHOF(i, arg2, k, ismpl)
    arg3 = j + 1
    CALL PUSHREAL8(result3)
    result3 = VISF(i, arg3, k, ismpl)
    f2 = result1*result2*grav/result3
    prod = f1*f2
    summ = f1*dely(j+1) + f2*dely(j)
    IF (summ .GT. 0.d0) THEN
      temporary_ad = 2.d0*tj_adv/summ
      prod_ad = temporary_ad
      summ_ad = -(prod*temporary_ad/summ)
    ELSE
      prod_ad = 0.D0
      summ_ad = 0.D0
    END IF
    f1_ad = dely(j+1)*summ_ad + f2*prod_ad
    f2_ad = dely(j)*summ_ad + f1*prod_ad
    temporary_ad = grav*f2_ad/result3
    result1_ad = result2*temporary_ad
    result2_ad = result1*temporary_ad
    result3_ad = -(result1*result2*temporary_ad/result3)
    CALL POPREAL8(result3)
    CALL VISF_AD(i, arg3, k, ismpl, result3_ad)
    CALL POPREAL8(result2)
    CALL RHOF_AD0(i, arg2, k, ismpl, result2_ad)
    CALL POPREAL8(result1)
    CALL KY_AD(i, arg1, k, ismpl, result1_ad)
    temporary_ad = grav*f1_ad/result3
    result1_ad = result2*temporary_ad
    result2_ad = result1*temporary_ad
    result3_ad = -(result1*result2*temporary_ad/result3)
    CALL VISF_AD(i, j, k, ismpl, result3_ad)
    CALL RHOF_AD0(i, j, k, ismpl, result2_ad)
    CALL KY_AD(i, j, k, ismpl, result1_ad)
  END IF
END SUBROUTINE TJ_AD

