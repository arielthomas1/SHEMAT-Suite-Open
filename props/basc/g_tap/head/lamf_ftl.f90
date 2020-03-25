!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of lamf in forward (tangent) mode:
!   variations   of useful results: lamf
!   with respect to varying inputs: *temp *tsal
!   Plus diff mem management of: temp:in tsal:in pres:in
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
!> @brief calculate the thermal conductivity kf of fluid [W/(m*K)]
!> @param[in] i cell index, direction I0
!> @param[in] j cell index, direction J0
!> @param[in] k cell index, direction K0
!> @param[in] ismpl local sample index
!> @return  thermal conductivity                lamf[W/(m*K)]
!> @details
!> calculate the thermal conductivity kf in W/(m*K) of saline water,
!> given temperature in degC, and salinity in mass fraction (g/g)of
!> NaCl. Thermal conductivity of freshwater, kfw is calculated using
!> the Phillips (1981) formulation (page8). \n \n
!>
!>      C = S./(1 + S)*1.d2;C2=C.*C;    % C=salinity in mol/kg \n\n
!>    kf = kfw.*(1.d0 - (2.3434d-3 - 7.924d-6*T + 3.924d-8*T2).*C ... \n
!>                         + (1.06d-5 - 2.d-8*T - 1.2d-10*T2).*C2) \n\n
!> Source:\n\n
!>
!> Phillips, S., Igbene, A., Fair, J., Ozbek, H., & Tavana, M.,
!> Technical databook for geothermal energy utilization (1981).
!> http://dx.doi.org/10.2172/6301274 \n\n
!>
!> Range of validity:  20 to 330degC and up to 4 molal NaCl\n\n
!> input:\n
!> pressure                             p [MPa]\n
!> temperature                          t in [C]\n
!> salinity                              s in [mol/L]\n
DOUBLE PRECISION FUNCTION g_LAMF(i, j, k, ismpl, lamf)
  USE ARRAYS

  USE g_ARRAYS

  USE MOD_FLOW
  IMPLICIT NONE
! Location indices
  INTEGER, INTENT(IN) :: i
  INTEGER, INTENT(IN) :: j
  INTEGER, INTENT(IN) :: k
! Sample index
  INTEGER :: ismpl
! Local Temperature (degC)
  DOUBLE PRECISION :: t
  DOUBLE PRECISION :: g_t
! Local Pressure (MPa)
  DOUBLE PRECISION :: p
! Local salinity [mol/kg / mol/L]
  DOUBLE PRECISION :: s
  DOUBLE PRECISION :: g_s
! Monomials of temperature
  DOUBLE PRECISION :: t2, t3, t4
  DOUBLE PRECISION :: g_t2
! Salinity from Phillips1981 [-]
  DOUBLE PRECISION :: sr
  DOUBLE PRECISION :: g_sr
! Monomial of salinity from Phillips1981 [-]
  DOUBLE PRECISION :: sr2
  DOUBLE PRECISION :: g_sr2
! Factor for thermal conductivity, Phillips1981 (2)
  DOUBLE PRECISION :: lamfac
  DOUBLE PRECISION :: g_lamfac
! Pure water thermal conductivity [W/(m*K)]
  DOUBLE PRECISION, EXTERNAL :: LAMW
	double precision, external :: g_lamw
  DOUBLE PRECISION :: result1
  DOUBLE PRECISION :: g_result1
  DOUBLE PRECISION :: temp0
  DOUBLE PRECISION :: temp1
  DOUBLE PRECISION :: lamf
! Local pressure [MPa]
  p = pres(i, j, k, ismpl)*pa_conv1
! Local temperature [degC]
  g_t = g_temp(i, j, k, ismpl)
  t = temp(i, j, k, ismpl)
! Local salinity [mol/L / mol/kg]
  g_s = g_tsal(i, j, k, ismpl)
  s = tsal(i, j, k, ismpl)
  IF (s .LE. 0.0d0) THEN
! Pure water conductivity
    g_lamf = g_LAMW(p, t, g_t, lamf)
  ELSE
! Salinity according to Phillips (1981) between (2) and (3)
    temp0 = s/(58.443d0*s+1.0d3)
    g_sr = 5844.3d0*(1.0-temp0*58.443d0)*g_s/(58.443d0*s+1.0d3)
    sr = 5844.3d0*temp0
! Monomials in salinity and temperature
    g_sr2 = 2*sr*g_sr
    sr2 = sr*sr
    g_t2 = 2*t*g_t
    t2 = t*t
    t3 = t2*t
    t4 = t3*t
! Factor lamf/lamw from Phillips1981, eq (2)
    temp0 = 1.2d-10*t2 - 2.0d-8*t + 1.06d-5
    temp1 = 3.924d-8*t2 - 7.924d-6*t + 2.3434d-3
    g_lamfac = sr2*(1.2d-10*g_t2-2.0d-8*g_t) + temp0*g_sr2 - sr*&
&     (3.924d-8*g_t2-7.924d-6*g_t) - temp1*g_sr
    lamfac = temp0*sr2 - temp1*sr + 1.0d0
! Thermal conductivity of fluid
    g_result1 = g_LAMW(p, t, g_t, result1)
    g_lamf = result1*g_lamfac + lamfac*g_result1
    lamf = lamfac*result1
  END IF
  RETURN
END FUNCTION g_LAMF
