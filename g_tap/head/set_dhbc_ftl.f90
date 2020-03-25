!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of set_dhbc in forward (tangent) mode:
!   variations   of useful results: *head
!   with respect to varying inputs: *head *dbc_data *bcperiod *propunit
!   Plus diff mem management of: head:in dbc_data:in bcperiod:in
!                propunit:in simtime:in
!>    @brief modify HEAD for the head equation according to the boundary conditions
!>    @param[in] ismpl local sample index
!>    @details
!> modify HEAD for the head equation according to the boundary conditions\n
SUBROUTINE g_SET_DHBC(ismpl)
  USE ARRAYS

  USE g_ARRAYS

  USE MOD_GENRL
  USE MOD_GENRLC
  USE MOD_TEMP
  USE MOD_FLOW
  USE MOD_TIME

  USE g_MOD_TIME

  USE MOD_LINFOS
  IMPLICIT NONE
  INTEGER :: ismpl
  INTEGER :: i, j, k
  INTEGER :: ib
  INTEGER :: bcu, tpbcu, bctype
  DOUBLE PRECISION :: val, malfa, mbeta
  DOUBLE PRECISION :: g_val, g_malfa, g_mbeta
  INTRINSIC MAX
  EXTERNAL DUMMY
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
! dirichlet nodes - - - - - - - - - - - - - - - - - - - - - - - - - - -
!$OMP do schedule(static)
  DO ib=first_flow,last_flow
    i = ibc_data(ib, cbc_i)
    j = ibc_data(ib, cbc_j)
    k = ibc_data(ib, cbc_k)
    bcu = ibc_data(ib, cbc_bcu)
    IF (ibc_data(ib, cbc_bctp) .LT. 0) THEN
      tpbcu = 0
    ELSE
      tpbcu = ibc_data(ib, cbc_bctp)
    END IF
    bctype = ibc_data(ib, cbc_bt)
!        "dirichlet"?, skip otherwise
    IF (bctype .EQ. bt_diri) THEN
!           discrete values
      IF (bcu .LE. 0) THEN
        g_val = g_dbc_data(ib, 1, ismpl)
        val = dbc_data(ib, 1, ismpl)
      ELSE
        g_val = g_propunit(bcu, idx_hbc, ismpl)
        val = propunit(bcu, idx_hbc, ismpl)
      END IF
      IF (tpbcu .GT. 0 .AND. nbctp .GT. 0) THEN
!               time-dependent bc:  val=ac*val+bc
!               get Alfa and Beta modificators
        CALL g_GET_TPBCALBE(malfa, g_malfa, mbeta, g_mbeta, tpbcu&
&                       , ismpl)
!               update time dependend modification of the bc-value
        g_val = g_malfa + val*g_mbeta + mbeta*g_val
        val = malfa + mbeta*val
      END IF
      IF (tpbcu .GE. 0) THEN
        g_head(i, j, k, ismpl) = g_val
        head(i, j, k, ismpl) = val
      END IF
    END IF
  END DO
!$OMP end do nowait
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  RETURN
END SUBROUTINE g_SET_DHBC

