!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of rhof in reverse (adjoint) mode (with options noISIZE i8):
!   gradient     of useful results: *temp *tsal *pres rhof
!   with respect to varying inputs: *temp *tsal *pres
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
!> @brief rhof(i,j,k,ismpl) calculates the density of the fluid (in kg/m^3),
!> @param[in] i cell index, direction I0
!> @param[in] j cell index, direction J0
!> @param[in] k cell index, direction K0
!> @param[in] ismpl local sample index
!> @return rho  [kg/m^3]
!> @details
!> rhow(i,j,k,ismpl) calculates the density in (in kg/m^3) of brine,
!> given temperature (t, in c) pressure (p,in pa), and salinity (s, in
!> mol/L) at node(i,j,k)\n
!>
!> Source:\n
!> Batzle, M., & Wang, Z., Seismic properties of pore fluids,
!> GEOPHYSICS, 57(11), 1396–1408 (1992).
!> http://dx.doi.org/10.1190/1.1443207 \n\n
!>
!>   Pressures 5-100 MPa, Temperature 20-350°C, Salinity <=320 g/L\n \n
!>
!>  CODE VERIFICATION:\n
!>   INPUT:  TEMP = 298.15K  P =0.1013 MPa  S = 0.25 g/g      OUTPUT: RHO = 1187.35 kg/m3\n
!>   INPUT:  TEMP = 393.15K  P =   30 MPa   S = 0.10 g/g      OUTPUT: RHO = 1027.06 kg/m3\n\n
!>
!> ARGUMENTS NAME    TYPE    UNITS           DESCRIPTION\n
!>     INPUT:        Temp  Real    T                 C       Temperature \n
!>                         Real    P         Pa      Pressure\n
!>                         Real    S         g/g     Salinity in mass fraction\n
!>    OUTPUT:        LABEL            RHO            Real     kg/m3  Density of brine \n
SUBROUTINE RHOF_AD0(i, j, k, ismpl, rhof_ad)
  use arrays

  USE ARRAYS_AD

  USE MOD_FLOW
  IMPLICIT NONE
! Location indices
  INTEGER, INTENT(IN) :: i
  INTEGER, INTENT(IN) :: j
  INTEGER, INTENT(IN) :: k
! Sample index
  INTEGER :: ismpl
! Temperature (degC)
  DOUBLE PRECISION :: t
  DOUBLE PRECISION :: t_ad
! Pressure (MPa)
  DOUBLE PRECISION :: p
  DOUBLE PRECISION :: p_ad
! Salinity (mol/L)
  DOUBLE PRECISION :: s
  DOUBLE PRECISION :: s_ad
! Salinity fraction (g/L)
  DOUBLE PRECISION :: sr
  DOUBLE PRECISION :: sr_ad
! Molar mass of NaCl [g/mol]
! double precision, parameter :: mmnacl = 58.44277d0
  DOUBLE PRECISION, PARAMETER :: mmnacl=58.44d0
! Pure water density (kg/m3)
  DOUBLE PRECISION :: rw
  DOUBLE PRECISION :: rw_ad
  DOUBLE PRECISION, EXTERNAL :: RHOW
! Pure water density (g/cm3)
  DOUBLE PRECISION :: rw_gcm3
  DOUBLE PRECISION :: rw_gcm3_ad
! Fluid density (g/cm3)
  DOUBLE PRECISION :: rhof_gcm3
  DOUBLE PRECISION :: rhof_gcm3_ad
  DOUBLE PRECISION :: temporary_ad
  DOUBLE PRECISION :: temp0
  DOUBLE PRECISION :: temporary_ad0
  DOUBLE PRECISION :: rhof_ad
  DOUBLE PRECISION :: rhof
! Local Temperature (degC)
  t = temp(i, j, k, ismpl)
! Local Pressure [MPa]
  p = pres(i, j, k, ismpl)*pa_conv1
! Local salinity [mol/L]
  s = tsal(i, j, k, ismpl)
! Pure water density [kg/m3]
  rw = RHOW(p, t)
  IF (s .LE. 0.0d0) THEN
    rw_ad = rhof_ad
    p_ad = 0.D0
    s_ad = 0.D0
    t_ad = 0.D0
  ELSE
! mol/L (Molarity) > g/g (Mass fraCtion)
    sr = s*mmnacl/(rw+s*mmnacl)
! Pure water density [g/cm3]
! Batzle, Equation (27b), densities in g/cm3
! Fluid density [kg/m3]
    rhof_gcm3_ad = 1.0d3*rhof_ad
    temp0 = 3.0d0*t - 3.3d3*sr + 47.0d0*p*sr - 13.0d0*p + 80.0d0
    rw_gcm3_ad = rhof_gcm3_ad
    temporary_ad = 1.0d-6*sr*rhof_gcm3_ad
    temporary_ad0 = t*temporary_ad
    sr_ad = (2*0.44d0*sr+1.0d-6*(3.0d2*p-2.4d3*(p*sr)+t*temp0)+0.668d0)*&
&     rhof_gcm3_ad + (p*47.0d0-3.3d3)*temporary_ad0 - p*2.4d3*temporary_ad
    p_ad = (3.0d2-sr*2.4d3)*temporary_ad + (sr*47.0d0-13.0d0)*temporary_ad0
    t_ad = temp0*temporary_ad + 3.0d0*temporary_ad0
    temporary_ad = mmnacl*sr_ad/(rw+mmnacl*s)
    temporary_ad0 = -(s*temporary_ad/(rw+mmnacl*s))
    rw_ad = rw_gcm3_ad/1.0d3 + temporary_ad0
    s_ad = temporary_ad + mmnacl*temporary_ad0
  END IF
  CALL RHOW_AD0(p, p_ad, t, t_ad, rw_ad)
  tsal_ad(i, j, k, ismpl) = tsal_ad(i, j, k, ismpl) + s_ad
  pres_ad(i, j, k, ismpl) = pres_ad(i, j, k, ismpl) + pa_conv1*p_ad
  temp_ad(i, j, k, ismpl) = temp_ad(i, j, k, ismpl) + t_ad
END SUBROUTINE RHOF_AD0

