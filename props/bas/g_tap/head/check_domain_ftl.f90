!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of check_domain in forward (tangent) mode:
!   variations   of useful results: *temp *conc *pres
!   with respect to varying inputs: *temp *conc *pres
!   Plus diff mem management of: temp:in conc:in pres:in
! MIT License
!
! Copyright (c) 2020 SHEMAT-Suite
!
! Permission is hereby granted, free of charge, to any person obtaining a copy
! of this software and associated documentation files (the "Software"), to deal
! in the Software without restriction, including without limitation the rights
! to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
! copies of the Software, and to permit persons to whom the Software is
! furnished to do so, subject to the following conditions:
!
! The above copyright notice and this permission notice shall be included in all
! copies or substantial portions of the Software.
!
! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
! IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
! FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
! AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
! LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
! OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
! SOFTWARE.
!>    @brief domain of validity for module bas
!>    @param[in] ismpl local sample index
!>    @details
!>    Checking whether pres/temp/(conc) are in domain of props
!>    validity. Version for property module bas. \n
!>    \n
!>    For concentration, an error is thrown and the execution is
!>    stopped if the concentration is outside the physical values.
SUBROUTINE g_CHECK_DOMAIN(ismpl)
  USE ARRAYS

  USE g_ARRAYS

  USE MOD_GENRL
  USE MOD_GENRLC
  USE MOD_CONC
  USE MOD_LINFOS
  IMPLICIT NONE
! Sample index
  INTEGER :: ismpl
! Iteration counters
  INTEGER :: i, j, k, l
! counters for the values outside domain of validity
! pres
  INTEGER :: icountp
! temp
  INTEGER :: icountt
! conc
  INTEGER :: icountc
! min/max boundaries of the domain of validity
! pres
  DOUBLE PRECISION, PARAMETER :: pmin=0.01d6
  DOUBLE PRECISION, PARAMETER :: pmax=110.0d6
! temp
  DOUBLE PRECISION, PARAMETER :: tmin=0.0d0
  DOUBLE PRECISION, PARAMETER :: tmax=350.0d0
! conc
  DOUBLE PRECISION, PARAMETER :: cmin=0.0d0
  DOUBLE PRECISION, PARAMETER :: cmax=1.0d5
! numerical boundary
  DOUBLE PRECISION, PARAMETER :: csmin=1.0d-22
! records the overall min/max of values if they are outside
! domain of validity
  DOUBLE PRECISION :: dpmax, dtmax, dcmax, dhmax
  DOUBLE PRECISION :: dpmin, dtmin, dcmin, dhmin
  INTRINSIC TRIM
  INTRINSIC MIN
  INTRINSIC MAX
! Set counters to zero
  icountp = 0
  icountt = 0
  icountc = 0
! Set overall min/max to boundaries of the domain of validity
  dpmax = pmax
  dpmin = pmin
  dtmax = tmax
  dtmin = tmin
  dcmax = cmax
  dcmin = cmin
! Check pres
  DO k=1,k0
    DO j=1,j0
      DO i=1,i0
        IF (pres(i, j, k, ismpl) .LT. pmin) THEN
! Set min counter
          icountp = icountp + 1
          IF (dpmin .GT. pres(i, j, k, ismpl)) THEN
            dpmin = pres(i, j, k, ismpl)
          ELSE
            dpmin = dpmin
          END IF
! Change pres value to minimum of the domain of validity
          g_pres(i, j, k, ismpl) = 0.D0
          pres(i, j, k, ismpl) = pmin
        END IF
        IF (pres(i, j, k, ismpl) .GT. pmax) THEN
! Set max counter
          icountp = icountp + 1
          IF (dpmax .LT. pres(i, j, k, ismpl)) THEN
            dpmax = pres(i, j, k, ismpl)
          ELSE
            dpmax = dpmax
          END IF
! Change pres value to maximum of the domain of validity
          g_pres(i, j, k, ismpl) = 0.D0
          pres(i, j, k, ismpl) = pmax
        END IF
      END DO
    END DO
  END DO
! Check temp
  DO k=1,k0
    DO j=1,j0
      DO i=1,i0
        IF (temp(i, j, k, ismpl) .LT. tmin) THEN
          icountt = icountt + 1
          IF (dtmin .GT. temp(i, j, k, ismpl)) THEN
            dtmin = temp(i, j, k, ismpl)
          ELSE
            dtmin = dtmin
          END IF
          g_temp(i, j, k, ismpl) = 0.D0
          temp(i, j, k, ismpl) = tmin
        END IF
        IF (temp(i, j, k, ismpl) .GT. tmax) THEN
          icountt = icountt + 1
          IF (dtmax .LT. temp(i, j, k, ismpl)) THEN
            dtmax = temp(i, j, k, ismpl)
          ELSE
            dtmax = dtmax
          END IF
          g_temp(i, j, k, ismpl) = 0.D0
          temp(i, j, k, ismpl) = tmax
        END IF
      END DO
    END DO
  END DO
! Check conc
  DO k=1,k0
    DO j=1,j0
      DO i=1,i0
        DO l=1,ntrac
          IF (conc(i, j, k, l, ismpl) .GT. cmax) THEN
            icountc = icountc + 1
            IF (dcmax .LT. conc(i, j, k, l, ismpl)) THEN
              dcmax = conc(i, j, k, l, ismpl)
            ELSE
              dcmax = dcmax
            END IF
            g_conc(i, j, k, l, ismpl) = 0.D0
            conc(i, j, k, l, ismpl) = cmax
          END IF
          IF (conc(i, j, k, l, ismpl) .LT. cmin .AND. conc(i, j, k, l, &
&             ismpl) .LT. -csmin) THEN
            icountc = icountc + 1
            IF (dcmin .GT. conc(i, j, k, l, ismpl)) THEN
              dcmin = conc(i, j, k, l, ismpl)
            ELSE
              dcmin = dcmin
            END IF
            g_conc(i, j, k, l, ismpl) = 0.D0
            conc(i, j, k, l, ismpl) = cmin
          END IF
          IF (conc(i, j, k, l, ismpl) .LT. csmin) THEN
! very small conc values set to zero to avoid
! numerically instabilities
            g_conc(i, j, k, l, ismpl) = 0.D0
            conc(i, j, k, l, ismpl) = cmin
          END IF
        END DO
      END DO
    END DO
  END DO
!       disable the warning output for linfos(3)==-1
  IF (linfos(3) .GE. 0) THEN
    IF (icountp .NE. 0) WRITE(*, '(3A,1I8,1A,1e16.7,1A,1e16.7,1A)') &
&                  'warning: pres not in domain of validity of module <'&
&                       , TRIM(def_props), '> at ', icountp, &
&                       ' points (min', dpmin, ', max', dpmax, ')!'
    IF (icountt .NE. 0) WRITE(*, '(3A,1I8,1A,1e16.7,1A,1e16.7,1A)') &
&                  'warning: temp not in domain of validity of module <'&
&                       , TRIM(def_props), '> at ', icountt, &
&                       ' points (min', dtmin, ', max', dtmax, ')!'
    IF (icountc .NE. 0) WRITE(*, '(3A,1I8,1A,1e16.7,1A,1e16.7,1A)') &
&                  'warning: conc not in domain of validity of module <'&
&                       , TRIM(def_props), '> at ', icountc, &
&                       ' points (min', dcmin, ', max', dcmax, ')!'
! error outputs for hard physical concentration boundaries
    IF (dcmax .GT. cmax) THEN
      WRITE(unit=*, fmt=*) '[E1] Error in check_domain.f90:', &
&     '  maximum concentration dcmax= ', dcmax, &
&     ' larger than allowed maximum value cmax=', cmax
      STOP
    ELSE IF (dcmin .GT. cmin) THEN
      WRITE(unit=*, fmt=*) '[E2] Error in check_domain.f90:', &
&     '  minimum concentration dcmin= ', dcmin, &
&     ' smaller than allowed minimum value cmin=', cmin
      STOP
    END IF
  END IF
  RETURN
END SUBROUTINE g_CHECK_DOMAIN

