!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of amean in forward (tangent) mode:
!   variations   of useful results: amean
!   with respect to varying inputs: x1 x2
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
!>    @brief calculate the arithmetic mean between x1 and x2
!>    @param[in] x1 first value
!>    @param[in] x2 second value
!>    @return arithmetic mean
DOUBLE PRECISION FUNCTION g_AMEAN(x1, g_x1, x2, g_x2, amean)
  IMPLICIT NONE
  DOUBLE PRECISION :: x1, x2
  DOUBLE PRECISION :: g_x1, g_x2
  DOUBLE PRECISION :: amean
!
  g_amean = 0.5d0*(g_x1+g_x2)
  amean = 0.5d0*(x1+x2)
!
  RETURN
END FUNCTION g_AMEAN

