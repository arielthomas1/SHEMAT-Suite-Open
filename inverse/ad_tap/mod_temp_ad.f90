!        Generated by TAPENADE     (INRIA, Tropics team)
!  tapenade 3.x
!
!>    @brief global variables for heat transport
MODULE MOD_TEMP_AD
  IMPLICIT NONE
! linear solver
!
! stopping criteria  nonlinear outer loop
  DOUBLE PRECISION :: nltolt_ad, nlrelaxt_ad, nlmaxt_ad
!
! rock  heat capacity, density ,conductivity
  DOUBLE PRECISION :: hpf_ad
END MODULE MOD_TEMP_AD
