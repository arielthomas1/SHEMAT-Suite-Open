!        Generated by TAPENADE     (INRIA, Tropics team)
!  Tapenade 3.6 (r4512) -  3 Aug 2012 15:11
!
!>    @brief declaration of all main variables, arrays and constants
!>    @details
!> definition of global (dynamic) arrays, constants and main descriptions\n
MODULE ARRAYS_AD
  IMPLICIT NONE
! hydraulic potential,pressure,epot-pressure
  DOUBLE PRECISION, ALLOCATABLE :: head_ad(:, :, :, :)
  DOUBLE PRECISION, ALLOCATABLE :: pres_ad(:, :, :, :)
! temperature
  DOUBLE PRECISION, ALLOCATABLE :: temp_ad(:, :, :, :)
! concentrations
  DOUBLE PRECISION, ALLOCATABLE :: conc_ad(:, :, :, :, :)
! total salinity
  DOUBLE PRECISION, ALLOCATABLE :: tsal_ad(:,:,:,:)

!       cell index number, no assignment - only for output (grouping)
  DOUBLE PRECISION, ALLOCATABLE :: propunit_ad(:, :, :)
!     disable additional hdf5-output
!     boundary-condition structures
  DOUBLE PRECISION, ALLOCATABLE :: dbc_data_ad(:, :, :)
!     save the computed values to compare it with 'ddata(*,cid_pv)'
  DOUBLE PRECISION, ALLOCATABLE :: sdata_ad(:, :)
!     coefficients for linear system solver
  DOUBLE PRECISION, ALLOCATABLE :: a_ad(:, :, :, :)
  DOUBLE PRECISION, ALLOCATABLE :: b_ad(:, :, :, :)
  DOUBLE PRECISION, ALLOCATABLE :: c_ad(:, :, :, :)
  DOUBLE PRECISION, ALLOCATABLE :: d_ad(:, :, :, :)
  DOUBLE PRECISION, ALLOCATABLE :: e_ad(:, :, :, :)
  DOUBLE PRECISION, ALLOCATABLE :: f_ad(:, :, :, :)
  DOUBLE PRECISION, ALLOCATABLE :: g_ad(:, :, :, :)
  DOUBLE PRECISION, ALLOCATABLE :: w_ad(:, :, :, :)
  DOUBLE PRECISION, ALLOCATABLE :: x_ad(:, :, :, :)
! storing old temp,head,conc,epot,pres for iteration
! [I0*J0*K0,3] 2&3 used for forward newton iteration
  DOUBLE PRECISION, ALLOCATABLE :: headold_ad(:, :, :)
  DOUBLE PRECISION, ALLOCATABLE :: tempold_ad(:, :, :)
  DOUBLE PRECISION, ALLOCATABLE :: presold_ad(:, :, :)
  DOUBLE PRECISION, ALLOCATABLE :: concold_ad(:, :, :, :)

!     BC time period: (period-index,value-type,TP-ID,sample)
!     - value-type: time, BC-value
  DOUBLE PRECISION, ALLOCATABLE :: bcperiod_ad(:, :, :, :)
!     simulation time
  DOUBLE PRECISION, ALLOCATABLE :: simtime_ad(:)

! additional ad related variables
  DOUBLE PRECISION, ALLOCATABLE :: adm_ad(:, :, :, :)
  DOUBLE PRECISION, ALLOCATABLE :: dms_ad(:, :, :, :)
  DOUBLE PRECISION, ALLOCATABLE :: ctgt_ad(:, :, :, :)
  DOUBLE PRECISION, ALLOCATABLE :: gravm_ad(:, :, :, :)
  DOUBLE PRECISION, ALLOCATABLE :: gram_ad(:, :, :, :)

END MODULE ARRAYS_AD
