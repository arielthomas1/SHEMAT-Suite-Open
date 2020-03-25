!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of visf in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: *temp *pres visf
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
!>          at 1 atm. Journal of Physical Chemistry, 91: 3354–3358.
!>    range of validity:\n
!>      pressures   0.01 - 110 mpa,\n
!>      temperature   15 - 350 °c and -46°c - 0°c\n
!>    input:\n
!>      pressure                            plocal [Pa]\n
!>      temperature                         tlocal in [C]\n
SUBROUTINE VISF_AD(i, j, k, ismpl, visf_adv)
  use arrays

  USE ARRAYS_AD

  USE MOD_FLOW
  IMPLICIT NONE
  double precision :: visf_adv
  INTEGER :: i, j, k, ismpl
  DOUBLE PRECISION :: cf(20), bf(6)
  DOUBLE PRECISION :: ta, tb, tlocal, plocal, t, t2, t3, tred, p, p2, p3&
& , p4, tp, t2p, tp2
  DOUBLE PRECISION :: ta_ad, tb_ad, tlocal_ad, plocal_ad, t_ad, t2_ad, &
& t3_ad, tred_ad, p_ad, p2_ad, p3_ad, tp_ad, t2p_ad, tp2_ad
  INTRINSIC SQRT
  DOUBLE PRECISION :: temp0
  INTEGER :: branch
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
  plocal = pres(i, j, k, ismpl)*pa_conv1
  tlocal = temp(i, j, k, ismpl)
  IF (tlocal .LT. -45d0) THEN
    tlocal = -45.d0
    CALL PUSHCONTROL1B(0)
  ELSE
    CALL PUSHCONTROL1B(1)
  END IF
  IF (tlocal .LT. 0.d0) THEN
! tloCal = 0.d0
!     new: after Speedy (1987) for T < 0 to -46 C
    tred = (tlocal+273.15d0-227.15d0)/227.15d0
    visf_adv = 0.001*visf_adv
    temp0 = SQRT(tred)
    IF (tred .EQ. 0.0) THEN
      tred_ad = (bf(3)+2*tred*bf(4)+3*tred**2*bf(5)+4*tred**3*bf(6))*&
&       visf_adv
    ELSE
      tred_ad = (bf(3)+2*tred*bf(4)+3*tred**2*bf(5)+4*tred**3*bf(6)-bf(1&
&       )/(2.0*temp0**3))*visf_adv
    END IF
    tlocal_ad = tred_ad/227.15d0
    plocal_ad = 0.D0
  ELSE
!     end new
    IF (tlocal .GT. 300.d0) THEN
      tlocal = 300.d0
      CALL PUSHCONTROL1B(0)
    ELSE
      CALL PUSHCONTROL1B(1)
    END IF
    p = plocal
    t = tlocal
    p2 = p*p
    p3 = p2*p
    t2 = t*t
    t3 = t2*t
    tp = p*t
    t2p = t2*p
    tp2 = t*p2
    ta = cf(1) + cf(2)*p + cf(3)*p2 + cf(4)*p3 + cf(5)*t + cf(6)*t2 + cf&
&     (7)*t3 + cf(8)*tp + cf(10)*t2p + cf(9)*tp2
    tb = cf(11) + cf(12)*p + cf(13)*p2 + cf(14)*p3 + cf(15)*t + cf(16)*&
&     t2 + cf(17)*t3 + cf(18)*tp + cf(20)*t2p + cf(19)*tp2
    ta_ad = visf_adv/tb
    tb_ad = -(ta*visf_adv/tb**2)
    p3_ad = cf(14)*tb_ad + cf(4)*ta_ad
    t3_ad = cf(17)*tb_ad + cf(7)*ta_ad
    tp_ad = cf(18)*tb_ad + cf(8)*ta_ad
    t2p_ad = cf(20)*tb_ad + cf(10)*ta_ad
    t2_ad = cf(16)*tb_ad + cf(6)*ta_ad + p*t2p_ad + t*t3_ad
    tp2_ad = cf(19)*tb_ad + cf(9)*ta_ad
    p2_ad = cf(13)*tb_ad + cf(3)*ta_ad + t*tp2_ad + p*p3_ad
    p_ad = cf(12)*tb_ad + cf(2)*ta_ad + t2*t2p_ad + t*tp_ad + p2*p3_ad +&
&     2*p*p2_ad
    t_ad = cf(15)*tb_ad + cf(5)*ta_ad + p2*tp2_ad + p*tp_ad + t2*t3_ad +&
&     2*t*t2_ad
    tlocal_ad = t_ad
    plocal_ad = p_ad
    CALL POPCONTROL1B(branch)
    IF (branch .EQ. 0) tlocal_ad = 0.D0
  END IF
  CALL POPCONTROL1B(branch)
  IF (branch .EQ. 0) tlocal_ad = 0.D0
  temp_ad(i, j, k, ismpl) = temp_ad(i, j, k, ismpl) + tlocal_ad
  pres_ad(i, j, k, ismpl) = pres_ad(i, j, k, ismpl) + pa_conv1*plocal_ad
END SUBROUTINE VISF_AD

