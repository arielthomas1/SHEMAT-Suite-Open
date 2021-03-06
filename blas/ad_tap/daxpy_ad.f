C        Generated by TAPENADE     (INRIA, Ecuador team)
C  Tapenade 3.15 (master) -  8 Jan 2020 10:48
C
C  Differentiation of daxpy in reverse (adjoint) mode (with options noISIZE i8):
C   gradient     of useful results: dx dy
C   with respect to varying inputs: dx dy da
C
C
C> \brief \b DAXPY
C
C  =========== DOCUMENTATION ===========
C
C Online html documentation available at
C            http://www.netlib.org/lapack/explore-html/
C
C  Definition:
C  ===========
C
C       SUBROUTINE DAXPY(N,DA,DX,INCX,DY,INCY)
C
C       .. Scalar Arguments ..
C       DOUBLE PRECISION DA
C       INTEGER INCX,INCY,N
C       ..
C       .. Array Arguments ..
C       DOUBLE PRECISION DX(*),DY(*)
C       ..
C
C
C> \par Purpose:
C  =============
C>
C> \verbatim
C>
C>    DAXPY constant times a vector plus a vector.
C>    uses unrolled loops for increments equal to one.
C> \endverbatim
C
C  Arguments:
C  ==========
C
C> \param[in] N
C> \verbatim
C>          N is INTEGER
C>         number of elements in input vector(s)
C> \endverbatim
C>
C> \param[in] DA
C> \verbatim
C>          DA is DOUBLE PRECISION
C>           On entry, DA specifies the scalar alpha.
C> \endverbatim
C>
C> \param[in] DX
C> \verbatim
C>          DX is DOUBLE PRECISION array, dimension ( 1 + ( N - 1 )*abs( INCX ) )
C> \endverbatim
C>
C> \param[in] INCX
C> \verbatim
C>          INCX is INTEGER
C>         storage spacing between elements of DX
C> \endverbatim
C>
C> \param[in,out] DY
C> \verbatim
C>          DY is DOUBLE PRECISION array, dimension ( 1 + ( N - 1 )*abs( INCY ) )
C> \endverbatim
C>
C> \param[in] INCY
C> \verbatim
C>          INCY is INTEGER
C>         storage spacing between elements of DY
C> \endverbatim
C
C  Authors:
C  ========
C
C> \author Univ. of Tennessee
C> \author Univ. of California Berkeley
C> \author Univ. of Colorado Denver
C> \author NAG Ltd.
C
C> \date November 2017
C
C> \ingroup double_blas_level1
C
C> \par Further Details:
C  =====================
C>
C> \verbatim
C>
C>     jack dongarra, linpack, 3/11/78.
C>     modified 12/3/93, array(1) declarations changed to array(*)
C> \endverbatim
C>
C  =====================================================================
      SUBROUTINE DAXPY_AD(n, da, da_ad, dx, dx_ad, incx, dy, dy_ad, incy
     +)
      IMPLICIT NONE
C
C  -- Reference BLAS level1 routine (version 3.8.0) --
C  -- Reference BLAS is a software package provided by Univ. of Tennessee,    --
C  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
C     November 2017
C
C     .. Scalar Arguments ..
      DOUBLE PRECISION da
      DOUBLE PRECISION da_ad
      INTEGER incx, incy, n
C     ..
C     .. Array Arguments ..
      DOUBLE PRECISION dx(*), dy(*)
      DOUBLE PRECISION dx_ad(*), dy_ad(*)
C     ..
C
C  =====================================================================
C
C     .. Local Scalars ..
      INTEGER i, ix, iy, m, mp1
C     ..
C     .. Intrinsic Functions ..
      INTRINSIC MOD
      INTEGER branch
C     ..
      IF (n .LE. 0) THEN
        da_ad = 0.D0
      ELSE IF (da .EQ. 0.0d0) THEN
        da_ad = 0.D0
      ELSE IF (incx .EQ. 1 .AND. incy .EQ. 1) THEN
C
C        code for both increments equal to 1
C
C
C        clean-up loop
C
        m = MOD(n, 4)
        IF (m .NE. 0) THEN
          CALL PUSHCONTROL1B(0)
        ELSE
          CALL PUSHCONTROL1B(1)
        END IF
        IF (n .LT. 4) THEN
          da_ad = 0.D0
        ELSE
          mp1 = m + 1
          da_ad = 0.D0
          DO i=n-MOD(n-mp1, 4),mp1,-4
            da_ad = da_ad + dx(i+3)*dy_ad(i+3) + dx(i+2)*dy_ad(i+2) + dx
     +        (i+1)*dy_ad(i+1) + dx(i)*dy_ad(i)
            dx_ad(i+3) = dx_ad(i+3) + da*dy_ad(i+3)
            dx_ad(i+2) = dx_ad(i+2) + da*dy_ad(i+2)
            dx_ad(i+1) = dx_ad(i+1) + da*dy_ad(i+1)
            dx_ad(i) = dx_ad(i) + da*dy_ad(i)
          ENDDO
        END IF
        CALL POPCONTROL1B(branch)
        IF (branch .EQ. 0) THEN
          DO i=m,1,-1
            da_ad = da_ad + dx(i)*dy_ad(i)
            dx_ad(i) = dx_ad(i) + da*dy_ad(i)
          ENDDO
        END IF
      ELSE
C
C        code for unequal increments or equal increments
C          not equal to 1
C
        ix = 1
        iy = 1
        IF (incx .LT. 0) ix = (-n+1)*incx + 1
        IF (incy .LT. 0) iy = (-n+1)*incy + 1
        DO i=1,n
          CALL PUSHINTEGER8(ix)
          ix = ix + incx
          CALL PUSHINTEGER8(iy)
          iy = iy + incy
        ENDDO
        da_ad = 0.D0
        DO i=n,1,-1
          CALL POPINTEGER8(iy)
          CALL POPINTEGER8(ix)
          da_ad = da_ad + dx(ix)*dy_ad(iy)
          dx_ad(ix) = dx_ad(ix) + da*dy_ad(iy)
        ENDDO
      END IF
      END

