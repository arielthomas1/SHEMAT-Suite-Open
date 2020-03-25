!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of stab_param in forward (tangent) mode:
!   variations   of useful results: value
!   with respect to varying inputs: value
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
!>    @brief stabilise paramter (cutting to its limits)
!>    @param[in] value paramter value
!>    @param[in] s_k component index (parameter type)
!>    @param[in] s_u unit index
SUBROUTINE g_STAB_PARAM(value, g_value, s_k, s_u)
  USE ARRAYS

  USE g_ARRAYS

  IMPLICIT NONE
  DOUBLE PRECISION :: value
  DOUBLE PRECISION :: g_value
  INTEGER :: s_k, s_u
!
  IF (s_k .GT. nprop_load) THEN
    WRITE(*, '(1A,2I4,1A)') &
&   'error: component index out of range (component,unit)=', s_k, s_u, &
&   '!'
    STOP
  ELSE IF (s_u .GT. nunits) THEN
    WRITE(*, '(1A,2I4,1A)') &
&   'error: unit index out of range (component,unit)=', s_k, s_u, '!'
    STOP
  ELSE
    IF (value .GT. prop_max(s_k)) THEN
      WRITE(*, '(3A,1I4.4,1A,2(1e16.8,1A))') 'warning: cut ', properties&
&     (s_k), '_unit', s_u, ' =', value, ' to ', prop_max(s_k), ' !'
      value = prop_max(s_k)
      g_value = 0.D0
    END IF
    IF (value .LT. prop_min(s_k)) THEN
      WRITE(*, '(3A,1I4.4,1A,2(1e16.8,1A))') 'warning: cut ', properties&
&     (s_k), '_unit', s_u, ' =', value, ' to ', prop_min(s_k), ' !'
      value = prop_min(s_k)
      g_value = 0.D0
    END IF
    RETURN
  END IF
END SUBROUTINE g_STAB_PARAM

