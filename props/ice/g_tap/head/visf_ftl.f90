!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of visf in forward (tangent) mode:
!   variations   of useful results: visf
!   with respect to varying inputs: *temp *pres
!   Plus diff mem management of: temp:in pres:in
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
!>    @brief rhof(i,j,k,ismpl) calculates the viscosity in (in Pa s) of  pure water,
!>    @param[in] i cell index, direction I0
!>    @param[in] j cell index, direction J0
!>    @param[in] k cell index, direction K0
!>    @param[in] ismpl local sample index
!>    @return visf  [Pa s]
!>    @details
!>    rhof(i,j,k,ismpl) calculates the viscosity in (in Pa s) of  pure water,\n
!>    given temperature (t, in C), and pressure (p,in Pa) at node(i,j,k)\n
!>    derived from the formulation given in:\n
!>          zylkovskij et al: models and methods summary for\n
!>          the fehmn application,\n
!>           ecd 22, la-ur-94-3787, los alamos nl, 1994.\n
!>    Speedy, R.J. (1987) Thermodynamic properties of supercooled water\n
!>          at 1 atm. Journal of Physical Chemistry, 91: 3354???3358.
!>    range of validity:\n
!>      pressures   0.01 - 110 mpa,\n
!>      temperature   15 - 350 ??c and -46??c - 0??c\n
!>    input:\n
!>      pressure                            plocal [Pa]\n
!>      temperature                         tlocal in [C]\n
DOUBLE PRECISION FUNCTION g_VISF(i, j, k, ismpl, visf)
  USE ARRAYS

  USE g_ARRAYS

  USE MOD_FLOW
  IMPLICIT NONE
  INTEGER :: i, j, k, ismpl
  DOUBLE PRECISION :: cf(20), bf(6)
  DOUBLE PRECISION :: ta, tb, tlocal, plocal, t, t2, t3, tred, p, p2, p3&
& , p4, tp, t2p, tp2
  DOUBLE PRECISION :: g_ta, g_tb, g_tlocal, g_plocal, g_t, &
& g_t2, g_t3, g_tred, g_p, g_p2, g_p3, g_tp, g_t2p, &
& g_tp2
  INTRINSIC SQRT
  DOUBLE PRECISION :: result1
  DOUBLE PRECISION :: g_result1
  DOUBLE PRECISION :: temp0
  DOUBLE PRECISION :: visf
  DATA cf /0.17409149d-02, 0.18894882d-04, -0.66439332d-07, -&
&      0.23122388d-09, -0.31534914d-05, 0.11120716d-07, -0.48576020d-10&
&      , 0.28006861d-07, 0.23225035d-09, 0.47180171d-10, 0.10000000d+01&
&      , 0.10523153d-01, -0.22658391d-05, -0.31796607d-06, &
&      0.29869141d-01, 0.21844248d-03, -0.87658855d-06, 0.41690362d-03, &
&      -0.25147022d-05, 0.22144660d-05/
!     new: after Speedy (1987) for T < 0 to -46 C
  DATA bf /26.312d0, -144.565d0, 1239.075d0, -8352.579d0, 31430.760, -&
&      48576.798d0/
!     end new
  g_plocal = pa_conv1*g_pres(i, j, k, ismpl)
  plocal = pres(i, j, k, ismpl)*pa_conv1
  g_tlocal = g_temp(i, j, k, ismpl)
  tlocal = temp(i, j, k, ismpl)
  IF (tlocal .LT. -45d0) THEN
    tlocal = -45.d0
    g_tlocal = 0.D0
  END IF
  IF (tlocal .LT. 0.d0) THEN
! tloCal = 0.d0
!     new: after Speedy (1987) for T < 0 to -46 C
    g_tred = g_tlocal/227.15d0
    tred = (tlocal+273.15d0-227.15d0)/227.15d0
    temp0 = SQRT(tred)
    IF (tred .EQ. 0.0) THEN
      g_result1 = 0.D0
    ELSE
      g_result1 = g_tred/(2.0*temp0)
    END IF
    result1 = temp0
    temp0 = bf(1)/result1
    g_visf = (bf(3)+bf(4)*2*tred+bf(5)*3*tred**2+bf(6)*4*tred**3)*&
&     g_tred - temp0*g_result1/result1
    visf = bf(2) + temp0 + bf(3)*tred + bf(4)*(tred*tred) + bf(5)*(tred*&
&     tred*tred) + bf(6)*tred**4
    g_visf = 0.001*g_visf
    visf = visf*0.001
  ELSE
!     end new
    IF (tlocal .GT. 300.d0) THEN
      tlocal = 300.d0
      g_tlocal = 0.D0
    END IF
    g_p = g_plocal
    p = plocal
    g_t = g_tlocal
    t = tlocal
    g_p2 = 2*p*g_p
    p2 = p*p
    g_p3 = p*g_p2 + p2*g_p
    p3 = p2*p
    p4 = p3*p
    g_t2 = 2*t*g_t
    t2 = t*t
    g_t3 = t*g_t2 + t2*g_t
    t3 = t2*t
    g_tp = t*g_p + p*g_t
    tp = p*t
    g_t2p = p*g_t2 + t2*g_p
    t2p = t2*p
    g_tp2 = p2*g_t + t*g_p2
    tp2 = t*p2
    g_ta = cf(2)*g_p + cf(3)*g_p2 + cf(4)*g_p3 + cf(5)*g_t + &
&     cf(6)*g_t2 + cf(7)*g_t3 + cf(8)*g_tp + cf(10)*g_t2p + cf(9&
&     )*g_tp2
    ta = cf(1) + cf(2)*p + cf(3)*p2 + cf(4)*p3 + cf(5)*t + cf(6)*t2 + cf&
&     (7)*t3 + cf(8)*tp + cf(10)*t2p + cf(9)*tp2
    g_tb = cf(12)*g_p + cf(13)*g_p2 + cf(14)*g_p3 + cf(15)*g_t&
&     + cf(16)*g_t2 + cf(17)*g_t3 + cf(18)*g_tp + cf(20)*g_t2p +&
&     cf(19)*g_tp2
    tb = cf(11) + cf(12)*p + cf(13)*p2 + cf(14)*p3 + cf(15)*t + cf(16)*&
&     t2 + cf(17)*t3 + cf(18)*tp + cf(20)*t2p + cf(19)*tp2
    g_visf = (g_ta-ta*g_tb/tb)/tb
    visf = ta/tb
  END IF
  RETURN
END FUNCTION g_VISF

