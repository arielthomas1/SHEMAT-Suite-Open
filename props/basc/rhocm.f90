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

!> @brief calculates  heat capacity*density of rock.
!> @param[in] i cell index, direction I0
!> @param[in] j cell index, direction J0
!> @param[in] k cell index, direction K0
!> @param[in] ismpl local sample index
!> @return  rhoc [W/(m*K)]
!> @details
!> temperature tlocal in [C]\n\n
!>
!> Under input file "# rhocm", the temperature variation coefficients
!> cma1, cma2, cma3 can be set. \n
!> Default: cma1 = 1.0d0, cma2 = cma3 = 0.0d0
      double precision function rhocm(i,j,k,ismpl)
        use arrays
        use mod_temp

        implicit none

        ! Location indices
        integer, intent (in) :: i
        integer, intent (in) :: j
        integer, intent (in) :: k

        ! Sample index
        integer :: ismpl

        ! Temperature (degC)
        double precision :: tlocal


        ! Local Temperature in degC
        tlocal = temp(i,j,k,ismpl)

        ! Volumetric heat capacity from input file [J/(kg*m3)]
        rhocm = propunit(uindex(i,j,k),idx_rc,ismpl)* &
            (cma1+cma2*tlocal+cma3*tlocal*tlocal)

        return

      end function rhocm
