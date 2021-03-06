!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of lamm in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: lamm
!   with respect to varying inputs: tlocal solid
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
!>    @brief calculate temperature dependent thermal conductivity
!>    @param[in,out] solid thermal conductivity at reference temperature given in input file [W / (m K)]
!>    @param[in,out] tlocal temperature at this sample index [degree Celsius]
!>    @param[in,out] tref reference temperature [degree Celsius]
!>    @param[in] ismpl local sample index
!>    @return thermal conductivity [W / (m K)]
!>    @details
!>    calculate temperature dependent thermal conductivity of the stony matrix\n
!>    (zoth & haenel, 1988)\n
SUBROUTINE LAMM_AD(solid, solid_ad, tlocal, tlocal_ad, tref, ismpl, &
& lamm_adv)
  IMPLICIT NONE
  double precision :: lamm_adv
  INTEGER :: ismpl
  DOUBLE PRECISION :: solid, tlocal, tref, tlimit
  DOUBLE PRECISION :: solid_ad, tlocal_ad
  DOUBLE PRECISION :: cddz, cddz0, cgt0, wgt, cgt
  DOUBLE PRECISION :: cddz_ad, cgt0_ad, wgt_ad, cgt_ad
  PARAMETER (tlimit=800.d0)
  DOUBLE PRECISION :: lamm
  IF (tlocal .GT. tlimit) THEN
    tlocal_ad = -(770.0d0*lamm_adv/(tlocal+350.0d0)**2)
    solid_ad = 0.D0
  ELSE
    cddz = 770.0d0/(350.0d0+tlocal) + 0.7d0
    cddz0 = 770.0d0/(350.0d0+tref) + 0.7d0
    cgt0 = solid/cddz0
    wgt = (tlocal-tref)/(tlimit-tref)
    cgt = cgt0 - (cgt0-1.0d0)*wgt
    cgt_ad = cddz*lamm_adv
    cddz_ad = cgt*lamm_adv
    cgt0_ad = (1.0-wgt)*cgt_ad
    wgt_ad = -((cgt0-1.0d0)*cgt_ad)
    tlocal_ad = wgt_ad/(tlimit-tref) - 770.0d0*cddz_ad/(tlocal+350.0d0)&
&     **2
    solid_ad = cgt0_ad/cddz0
  END IF
END SUBROUTINE LAMM_AD

