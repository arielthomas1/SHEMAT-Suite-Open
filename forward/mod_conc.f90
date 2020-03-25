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

!>    @brief global variables for transport
module mod_conc

  !> @brief Number of tracers.
  !> @details
  !> Number of tracers. \n
  !>
  !> Read under `# ntrans`, first entry.
  integer :: ntrac

  !> @brief Number of reactive components.
  !> @details
  !> Number of reactive components. \n
  !>
  !> Read under `# ntrans`, second entry.
  integer :: nchem

  !> @brief Number of transport species.
  !> @details
  !> Number of transport species. \n
  !> Sum of number of tracers and number of reactive components. \n
  !>
  !> Read under `# ntrans`, first entry.
  integer :: ntrans

! linear solver
      double precision errc,aparc,nlmaxc
      integer controlc,lmaxitc
!
! stopping criteria  nonlinear outer loop
      double precision nltolc,nlrelaxc
      double precision mmas_nacl
        parameter (mmas_nacl = 58.443d0)
end module mod_conc
