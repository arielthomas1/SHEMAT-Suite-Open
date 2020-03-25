!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of hstor in forward (tangent) mode:
!   variations   of useful results: hstor
!   with respect to varying inputs: *temp *propunit *pres
!   Plus diff mem management of: temp:in propunit:in pres:in
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
!>    @brief calculates the bulk storativity
!>    @param[in] i cell index, direction I0
!>    @param[in] j cell index, direction J0
!>    @param[in] k cell index, direction K0
!>    @param[in] ismpl local sample index
!>    @return bulk storativity
!>    @details
!>    storb(i,j,k,ismpl) calculates the bulk storativity \n
!>    at node(i,j,k).\n
DOUBLE PRECISION FUNCTION g_HSTOR(i, j, k, ismpl, hstor)
  USE ARRAYS

  USE g_ARRAYS

  USE MOD_FLOW
  IMPLICIT NONE
  INTEGER :: i, j, k, ismpl
  EXTERNAL RHOF, COMPM, COMPF, POR
  EXTERNAL g_RHOF, g_COMPM, g_COMPF, g_POR
  DOUBLE PRECISION :: RHOF, COMPM, COMPF, &
& POR
  DOUBLE PRECISION :: g_RHOF, g_COMPM, g_COMPF, g_POR
  DOUBLE PRECISION :: result1
  DOUBLE PRECISION :: g_result1
  DOUBLE PRECISION :: result2
  DOUBLE PRECISION :: g_result2
  DOUBLE PRECISION :: result3
  DOUBLE PRECISION :: g_result3
  DOUBLE PRECISION :: result4
  DOUBLE PRECISION :: g_result4
  DOUBLE PRECISION :: hstor
  g_result1 = g_RHOF(i, j, k, ismpl, result1)
  g_result2 = g_COMPM(i, j, k, ismpl, result2)
  g_result3 = g_POR(i, j, k, ismpl, result3)
  g_result4 = g_COMPF(i, j, k, ismpl, result4)
  g_hstor = grav*((result2+result3*result4)*g_result1+result1*(&
&   g_result2+result4*g_result3+result3*g_result4))
  hstor = grav*result1*(result2+result3*result4)
  RETURN
END FUNCTION g_HSTOR

