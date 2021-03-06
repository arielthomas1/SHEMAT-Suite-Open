!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of buoy in forward (tangent) mode:
!   variations   of useful results: buoy
!   with respect to varying inputs: *propunit
!   Plus diff mem management of: propunit:in
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
!>    @brief calculate buoyancy for head equation
!>    @param[in] i cell index, direction I0
!>    @param[in] j cell index, direction J0
!>    @param[in] k cell index, direction K0
!>    @param[in] ismpl local sample index
!>    @return buoyancy
!>    @details
!>calculate buoyancy for head equation\n
!>sign convention: negative for positive buoyancy\n
DOUBLE PRECISION FUNCTION g_BUOY(i, j, k, ismpl, buoy)
  USE ARRAYS

  USE g_ARRAYS

  USE MOD_GENRL
  USE MOD_FLOW
  IMPLICIT NONE
  INTEGER :: ismpl
  INTEGER :: i, j, k
  DOUBLE PRECISION :: rhor, rhav, hh, h0, h1, prod, summ
  DOUBLE PRECISION :: g_hh, g_h0, g_h1, g_prod, g_summ
  EXTERNAL RHOF, KZ, VISF
  EXTERNAL g_KZ
  DOUBLE PRECISION :: RHOF, KZ, VISF
  DOUBLE PRECISION :: g_KZ
  DOUBLE PRECISION :: result1
  DOUBLE PRECISION :: g_result1
  DOUBLE PRECISION :: result2
  DOUBLE PRECISION :: result3
  DOUBLE PRECISION :: buoy
  result1 = RHOF(i, j, k + 1, ismpl)
  result2 = RHOF(i, j, k, ismpl)
  rhav = 0.5d0*(result1+result2)
  rhor = (rhav-rref)/rref
  hh = 0.d0
  g_result1 = g_KZ(i, j, k, ismpl, result1)
  result2 = RHOF(i, j, k, ismpl)
  result3 = VISF(i, j, k, ismpl)
  g_h0 = result2*grav*g_result1/result3
  h0 = result1*result2*grav/result3
  g_result1 = g_KZ(i, j, k + 1, ismpl, result1)
  result2 = RHOF(i, j, k + 1, ismpl)
  result3 = VISF(i, j, k + 1, ismpl)
  g_h1 = result2*grav*g_result1/result3
  h1 = result1*result2*grav/result3
  g_summ = g_h0 + g_h1
  summ = h0 + h1
  g_prod = h1*g_h0 + h0*g_h1
  prod = h0*h1
  IF (summ .GT. 0.d0) THEN
    g_hh = 2.0d0*(g_prod-prod*g_summ/summ)/summ
    hh = 2.0d0*prod/summ
  ELSE
    g_hh = 0.D0
  END IF
  g_buoy = rhor*g_hh
  buoy = hh*rhor
  RETURN
END FUNCTION g_BUOY

