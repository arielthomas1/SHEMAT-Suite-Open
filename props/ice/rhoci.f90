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

!>    @brief calculates  heat capacity*density of ice .
!>    @param[in] i cell index, direction I0
!>    @param[in] j cell index, direction J0
!>    @param[in] k cell index, direction K0
!>    @param[in] ismpl local sample index
!>    @return  rhoci                              rc[J / (m^3 * K)]
!>    @details
!>    input:\n
!>      heat capacity of ice                cpi [J / kg / K]\n
!>      density                             rhoi [kg/m^3]\n
!>      temperature                         tlocal [C]\n
      DOUBLE PRECISION FUNCTION rhoci(i,j,k,ismpl)


        use arrays
        IMPLICIT NONE

        INTEGER i, j, k, ismpl
        DOUBLE PRECISION tlocal, rhoi, cpi
        EXTERNAL rhoi, cpi

        tlocal = temp(i,j,k,ismpl)
        IF (tlocal>0.D0) tlocal = 0.D0

        rhoci = rhoi(i,j,k,ismpl)*cpi(i,j,k,ismpl)

        RETURN
      END
