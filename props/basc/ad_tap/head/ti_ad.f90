!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of ti in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: *temp *propunit *tsal *pres
!                ti
!   with respect to varying inputs: *temp *propunit *tsal *pres
!   Plus diff mem management of: temp:in propunit:in tsal:in pres:in
!>    @brief harmonic mean Kx on cell faces in x direction over delx*
!>    @param[in] i grid indices
!>    @param[in] j grid indices
!>    @param[in] k grid indices
!>    @param[in] ismpl local sample index
!>    @return x hydraulic conductivity over delx*  (1/s)
!>    @details
!>    Compute the harmonic mean of Kx on the cell face in positive
!>    x-direction from the current node (i, j, k) divided by the
!>    x-distance of the current node (i, j, k) to the neighboring node
!>    (i+1, j, k).
!>
!>    delx* = 0.5 ( delx(i) + delx(i+1) )
!>
!>    Kx / delx* = [ 0.5*delx(i+1)/K(i+1) + 0.5*delx(i)/K(i) ]**-1
!>
!>               = [ ( 0.5* K(i)* delx(i+1) + 0.5*K(i+1)* delx(i) ) / ( K(i)*K(i+1) ) ]**-1
!>
!>               = [ ( 0.5 * summ ) / (prod) ]**-1 = 2.0*prod/summ
SUBROUTINE TI_AD(i, j, k, ismpl, ti_adv)
  use arrays

  USE ARRAYS_AD

  USE MOD_GENRL
  USE MOD_FLOW
  IMPLICIT NONE
  double precision :: ti_adv
  INTEGER :: ismpl
  INTEGER :: i, j, k
  EXTERNAL KX, RHOF, VISF
  EXTERNAL KX_AD, RHOF_AD0, VISF_AD
  DOUBLE PRECISION :: f1, f2, prod, summ, KX, RHOF, &
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
  DOUBLE PRECISION :: ti
  IF (i0 .GT. 1 .AND. i .LT. i0) THEN
    result1 = KX(i, j, k, ismpl)
    result2 = RHOF(i, j, k, ismpl)
    result3 = VISF(i, j, k, ismpl)
    f1 = result1*result2*grav/result3
    arg1 = i + 1
    CALL PUSHREAL8(result1)
    result1 = KX(arg1, j, k, ismpl)
    arg2 = i + 1
    CALL PUSHREAL8(result2)
    result2 = RHOF(arg2, j, k, ismpl)
    arg3 = i + 1
    CALL PUSHREAL8(result3)
    result3 = VISF(arg3, j, k, ismpl)
    f2 = result1*result2*grav/result3
    prod = f1*f2
    summ = f1*delx(i+1) + f2*delx(i)
    IF (summ .GT. 0.d0) THEN
      temporary_ad = 2.d0*ti_adv/summ
      prod_ad = temporary_ad
      summ_ad = -(prod*temporary_ad/summ)
    ELSE
      prod_ad = 0.D0
      summ_ad = 0.D0
    END IF
    f1_ad = delx(i+1)*summ_ad + f2*prod_ad
    f2_ad = delx(i)*summ_ad + f1*prod_ad
    temporary_ad = grav*f2_ad/result3
    result1_ad = result2*temporary_ad
    result2_ad = result1*temporary_ad
    result3_ad = -(result1*result2*temporary_ad/result3)
    CALL POPREAL8(result3)
    CALL VISF_AD(arg3, j, k, ismpl, result3_ad)
    CALL POPREAL8(result2)
    CALL RHOF_AD0(arg2, j, k, ismpl, result2_ad)
    CALL POPREAL8(result1)
    CALL KX_AD(arg1, j, k, ismpl, result1_ad)
    temporary_ad = grav*f1_ad/result3
    result1_ad = result2*temporary_ad
    result2_ad = result1*temporary_ad
    result3_ad = -(result1*result2*temporary_ad/result3)
    CALL VISF_AD(i, j, k, ismpl, result3_ad)
    CALL RHOF_AD0(i, j, k, ismpl, result2_ad)
    CALL KX_AD(i, j, k, ismpl, result1_ad)
  END IF
END SUBROUTINE TI_AD

