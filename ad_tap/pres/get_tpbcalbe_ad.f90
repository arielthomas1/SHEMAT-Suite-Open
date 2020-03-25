!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of get_tpbcalbe in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: *bcperiod mbeta malfa
!   with respect to varying inputs: *bcperiod
!   Plus diff mem management of: bcperiod:in simtime:in
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
!>    @brief time depended boundary condition modificators
!>    @param[out] malfa alfa modificator
!>    @param[out] mbeta beta modificator
!>    @param[in] tpbcu time period BC table index
!>    @param[in] ismpl local sample index
!>    @details
!> "GET Time Periods Boundary Condition ALfa & BEta"\n
!> get the alfa and beta modificators for time dependend bc-values\n
SUBROUTINE GET_TPBCALBE_AD(malfa, malfa_ad, mbeta, mbeta_ad, tpbcu, &
& ismpl)
  use arrays

  USE ARRAYS_AD

  USE MOD_GENRL
  use mod_time

  USE MOD_TIME_AD

  USE MOD_LINFOS
  IMPLICIT NONE
  INTEGER :: ismpl
  INTEGER :: k
  INTEGER :: tpbcu, imt
  DOUBLE PRECISION :: malfa, mbeta, mtime
  DOUBLE PRECISION :: malfa_ad, mbeta_ad
  INTRINSIC ABS
  INTEGER :: abs0
  INTEGER :: branch
  INTEGER :: ad_count
  INTEGER :: i
!       default - when not time depended
!
  IF (tpbcu .GT. 0) THEN
    imt = 0
    ad_count = 1
!         next bc-tp entry
 100 CALL PUSHINTEGER8(imt)
    imt = imt + 1
    mtime = bcperiod(imt, 1, tpbcu, ismpl)
    IF (mtime .LE. simtime(ismpl)) THEN
      CALL PUSHCONTROL1B(0)
    ELSE
      CALL PUSHCONTROL1B(1)
    END IF
!
!         !!! this IF statement (with the GOTO) needs to be outside of the
!             other "mtime<=simtime(ismpl)" scopes, to generate reverse-mode code !!!
    IF (mtime .LE. simtime(ismpl) .AND. imt .LT. ibcperiod(tpbcu)) THEN
      ad_count = ad_count + 1
      GOTO 100
    END IF
    CALL PUSHINTEGER8(ad_count)
    CALL POPINTEGER8(ad_count)
    DO i=1,ad_count
      CALL POPCONTROL1B(branch)
      IF (branch .EQ. 0) THEN
        bcperiod_ad(imt, 3, tpbcu, ismpl) = bcperiod_ad(imt, 3, tpbcu, &
&         ismpl) + mbeta_ad
        bcperiod_ad(imt, 2, tpbcu, ismpl) = bcperiod_ad(imt, 2, tpbcu, &
&         ismpl) + malfa_ad
        mbeta_ad = 0.D0
        malfa_ad = 0.D0
      END IF
      CALL POPINTEGER8(imt)
    END DO
  END IF
END SUBROUTINE GET_TPBCALBE_AD

