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

!>    @brief wrapper for preparation of forward run, mostly input
!>    @param[in] filename input filename as read from shemade.job
!>    @param[inout] ismpl local sample index
!>    @details
!>    This input wrapper calls the read-in routines and initializes
!>    first output to the status log and the command line.
subroutine forward_preparation(filename, ismpl)

  use arrays
  use mod_genrl
  use mod_genrlc
  use mod_time
#ifndef noHDF
  use mod_input_file_parser_hdf5
#endif
  
  implicit none

  integer :: ismpl

  character (len=80), intent (in) :: filename

  integer, external :: lblank
  logical, external :: test_option

#ifndef noHDF
  CALL h5parse_open_datafile(filename)
#endif

  !     read forward model
  CALL read_model(filename,ismpl)
  CALL read_control(filename,ismpl)
  !     only forward propcessing =<1
  runmode = min(runmode,1)
  !     read timestep parameter
  CALL read_time(filename,ismpl)
  !     read data
  IF (runmode>0) CALL read_data(filename_data,ismpl)
  !     split units
  CALL read_split(filename,ismpl)

  IF (test_option('restart')) THEN
    restart_name = filename(1:lblank(filename)) // '_restart'
  !       read all necessary data from last save point
    CALL read_restartfw(restart_name,simtime(ismpl),itimestep_0, &
        ismpl)
  END IF

  ! First status log output
  call write_status_log(filename, ismpl)

#ifndef noHDF
  CALL h5parse_close_datafile()
#endif

end subroutine forward_preparation
