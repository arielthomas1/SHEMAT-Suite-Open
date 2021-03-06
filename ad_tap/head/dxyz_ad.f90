!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of dxyz in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: x y z
!   with respect to varying inputs: x y z
!>    @brief BLAS adapting : z=x*y
!>    @param[in] N length of vectors [z],[x],[y]
!>    @param[in] x vector [x]
!>    @param[in] y vector [y]
!>    @param[out] z vector [z]
SUBROUTINE DXYZ_AD(n, x, x_ad, y, y_ad, z, z_ad)
  IMPLICIT NONE
  INTEGER :: n, i, m
  DOUBLE PRECISION :: x(n), y(n), z(n)
  DOUBLE PRECISION :: x_ad(n), y_ad(n), z_ad(n)
  INTRINSIC MOD
  INTEGER :: ad_to
  m = MOD(n, 4)
  i = m + 1
  CALL PUSHINTEGER8(i - 1)
  m = m + 1
  DO i=n-MOD(n-m, 4),m,-4
    x_ad(i+3) = x_ad(i+3) + y(i+3)*z_ad(i+3)
    y_ad(i+3) = y_ad(i+3) + x(i+3)*z_ad(i+3)
    z_ad(i+3) = 0.D0
    x_ad(i+2) = x_ad(i+2) + y(i+2)*z_ad(i+2)
    y_ad(i+2) = y_ad(i+2) + x(i+2)*z_ad(i+2)
    z_ad(i+2) = 0.D0
    x_ad(i+1) = x_ad(i+1) + y(i+1)*z_ad(i+1)
    y_ad(i+1) = y_ad(i+1) + x(i+1)*z_ad(i+1)
    z_ad(i+1) = 0.D0
    x_ad(i+0) = x_ad(i+0) + y(i+0)*z_ad(i+0)
    y_ad(i+0) = y_ad(i+0) + x(i+0)*z_ad(i+0)
    z_ad(i+0) = 0.D0
  END DO
  CALL POPINTEGER8(ad_to)
  DO i=ad_to,1,-1
    x_ad(i) = x_ad(i) + y(i)*z_ad(i)
    y_ad(i) = y_ad(i) + x(i)*z_ad(i)
    z_ad(i) = 0.D0
  END DO
END SUBROUTINE DXYZ_AD

