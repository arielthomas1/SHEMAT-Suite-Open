!        Generated by TAPENADE     (INRIA, Tropics team)
!  tapenade 3.x
!
!>    @brief global variables for flow arrays
MODULE MOD_FLOW_AD
  IMPLICIT NONE
!      stopping criteria nonlinear outer loop, head or pressure
      double precision nltolf_ad,nlrelaxf_ad,nlmaxf_ad
!     stopping criteria nonlinear outer loop, saturation
      double precision nltols_ad,nlrelaxs_ad,nlmaxs_ad
!     constant of gravitational force, compressibility of rock
      double precision grav_ad,rref_ad

END MODULE MOD_FLOW_AD