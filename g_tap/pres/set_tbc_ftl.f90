!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of set_tbc in forward (tangent) mode:
!   variations   of useful results: *d *e *f *g *temp *w *a *b
!                *c
!   with respect to varying inputs: *d *e *f *g *temp *w *dbc_data
!                *bcperiod *propunit *tsal *pres *a *b *c
!   Plus diff mem management of: d:in e:in f:in g:in temp:in w:in
!                dbc_data:in bcperiod:in propunit:in tsal:in pres:in
!                simtime:in a:in b:in c:in
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
!>    @brief coefficents for the heat equation
!>    @param[in] ismpl local sample index
!>    @details
!> modify coefficents for the heat equation according to the prescribed sources and sinks.\n
!> coefficients are stored as vectors in the diagonals a-g (d center) and rhs in w.\n
SUBROUTINE g_SET_TBC(ismpl)
  USE ARRAYS

  USE g_ARRAYS

  USE MOD_GENRL
  USE MOD_TEMP
  USE MOD_TIME

  USE g_MOD_TIME

  USE MOD_LINFOS
  IMPLICIT NONE
  INTEGER :: ismpl
  INTEGER :: i, j, k
  INTEGER :: ib
  INTEGER :: bcu
! INTEGER ac, bc
  INTEGER :: tpbcu, bctype, i_dir
  EXTERNAL VX, VY, VZ
  EXTERNAL g_VX, g_VY, g_VZ
  DOUBLE PRECISION :: val, malfa, mbeta, VX, VY, VZ&
& , dv, ds, vv
  DOUBLE PRECISION :: g_val, g_malfa, g_mbeta, g_VX, g_VY, &
& g_VZ, g_dv, g_ds, g_vv
  INTRINSIC MAX
  INTRINSIC ABS
  EXTERNAL DUMMY
  DOUBLE PRECISION :: x1
  DOUBLE PRECISION :: g_x1
  DOUBLE PRECISION :: x2
  DOUBLE PRECISION :: g_x2
  DOUBLE PRECISION :: x3
  DOUBLE PRECISION :: g_x3
  DOUBLE PRECISION :: x4
  DOUBLE PRECISION :: g_x4
  DOUBLE PRECISION :: x5
  DOUBLE PRECISION :: g_x5
  DOUBLE PRECISION :: x6
  DOUBLE PRECISION :: g_x6
  DOUBLE PRECISION :: temp0
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!  flow due to flow neumann nodes / wellars  - - - - - - - - - - - - - -
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
!        "neumann"?, skip otherwise
    IF (bctype .EQ. bt_neum .OR. bctype .EQ. bt_neuw) THEN
!           discrete values
      IF (bcu .LE. 0) THEN
        val = dbc_data(ib, 1, ismpl)
      ELSE
        val = propunit(bcu, idx_hbc, ismpl)
      END IF
      IF (tpbcu .GT. 0 .AND. nbctp .GT. 0) THEN
!               time-dependent bc:  val=ac*val+bc
!               get Alfa and Beta modificators
        CALL GET_TPBCALBE(malfa, mbeta, tpbcu, ismpl)
!               update time dependend modification of the bc-value
        val = malfa + mbeta*val
      END IF
!           wellar test
      IF (val .LT. 0.0d0 .AND. tpbcu .GE. 0) THEN
        ds = 0.d0
        dv = 0.d0
        IF (i .GT. 1) THEN
          g_x1 = g_VX(i - 1, j, k, ismpl, x1)
          IF (x1 .GE. 0.) THEN
            g_vv = g_x1
            vv = x1
          ELSE
            g_vv = -g_x1
            vv = -x1
          END IF
          g_ds = g_vv
          ds = ds + vv
          temp0 = temp(i-1, j, k, ismpl)
          g_dv = vv*g_temp(i-1, j, k, ismpl) + temp0*g_vv
          dv = dv + temp0*vv
!                 write(*,*) 'i- ',vv, temp(i-1,j,k,ismpl)
        ELSE
          g_ds = 0.D0
          g_dv = 0.D0
        END IF
        IF (i .LT. i0) THEN
          g_x2 = g_VX(i, j, k, ismpl, x2)
          IF (x2 .GE. 0.) THEN
            g_vv = g_x2
            vv = x2
          ELSE
            g_vv = -g_x2
            vv = -x2
          END IF
          g_ds = g_ds + g_vv
          ds = ds + vv
          temp0 = temp(i+1, j, k, ismpl)
          g_dv = g_dv + vv*g_temp(i+1, j, k, ismpl) + temp0*g_vv
          dv = dv + temp0*vv
!                 write(*,*) 'i+ ',vv, temp(i+1,j,k,ismpl)
        END IF
        IF (j .GT. 1) THEN
          g_x3 = g_VY(i, j - 1, k, ismpl, x3)
          IF (x3 .GE. 0.) THEN
            g_vv = g_x3
            vv = x3
          ELSE
            g_vv = -g_x3
            vv = -x3
          END IF
          g_ds = g_ds + g_vv
          ds = ds + vv
          temp0 = temp(i, j-1, k, ismpl)
          g_dv = g_dv + vv*g_temp(i, j-1, k, ismpl) + temp0*g_vv
          dv = dv + temp0*vv
!                 write(*,*) 'j- ',vv, temp(i,j-1,k,ismpl)
        END IF
        IF (j .LT. j0) THEN
          g_x4 = g_VY(i, j, k, ismpl, x4)
          IF (x4 .GE. 0.) THEN
            g_vv = g_x4
            vv = x4
          ELSE
            g_vv = -g_x4
            vv = -x4
          END IF
          g_ds = g_ds + g_vv
          ds = ds + vv
          temp0 = temp(i, j+1, k, ismpl)
          g_dv = g_dv + vv*g_temp(i, j+1, k, ismpl) + temp0*g_vv
          dv = dv + temp0*vv
!                 write(*,*) 'j+ ',vv, temp(i,j+1,k,ismpl)
        END IF
        IF (k .GT. 1) THEN
          g_x5 = g_VZ(i, j, k - 1, ismpl, x5)
          IF (x5 .GE. 0.) THEN
            g_vv = g_x5
            vv = x5
          ELSE
            g_vv = -g_x5
            vv = -x5
          END IF
          g_ds = g_ds + g_vv
          ds = ds + vv
          temp0 = temp(i, j, k-1, ismpl)
          g_dv = g_dv + vv*g_temp(i, j, k-1, ismpl) + temp0*g_vv
          dv = dv + temp0*vv
!                 write(*,*) 'k- ',vv, temp(i,j,k-1,ismpl)
        END IF
        IF (k .LT. k0) THEN
          g_x6 = g_VZ(i, j, k, ismpl, x6)
          IF (x6 .GE. 0.) THEN
            g_vv = g_x6
            vv = x6
          ELSE
            g_vv = -g_x6
            vv = -x6
          END IF
          g_ds = g_ds + g_vv
          ds = ds + vv
          temp0 = temp(i, j, k+1, ismpl)
          g_dv = g_dv + vv*g_temp(i, j, k+1, ismpl) + temp0*g_vv
          dv = dv + temp0*vv
!                 write(*,*) 'k+ ',vv, temp(i-1,j,k+1,ismpl)
        END IF
        g_dv = (g_dv-dv*g_ds/ds)/ds
        dv = dv/ds
!              write(*,*) 'val: ',dv,ds
!              apply dirichlet update [dv]
#ifdef BCMY
!              D = D+my
        g_d(i, j, k, ismpl) = g_d(i, j, k, ismpl) - g_dbc_data(ib&
&         , 2, ismpl)
        d(i, j, k, ismpl) = d(i, j, k, ismpl) - dbc_data(ib, 2, ismpl)
        g_w(i, j, k, ismpl) = g_w(i, j, k, ismpl) - dv*g_dbc_data(&
&         ib, 2, ismpl) - dbc_data(ib, 2, ismpl)*g_dv
        w(i, j, k, ismpl) = w(i, j, k, ismpl) - dbc_data(ib, 2, ismpl)*&
&         dv
#else
!              standard boundary condition handling
        g_a(i, j, k, ismpl) = 0.D0
        a(i, j, k, ismpl) = 0.0d0
        g_b(i, j, k, ismpl) = 0.D0
        b(i, j, k, ismpl) = 0.0d0
        g_c(i, j, k, ismpl) = 0.D0
        c(i, j, k, ismpl) = 0.0d0
        g_e(i, j, k, ismpl) = 0.D0
        e(i, j, k, ismpl) = 0.0d0
        g_f(i, j, k, ismpl) = 0.D0
        f(i, j, k, ismpl) = 0.0d0
        g_g(i, j, k, ismpl) = 0.D0
        g(i, j, k, ismpl) = 0.0d0
        g_d(i, j, k, ismpl) = 0.D0
        d(i, j, k, ismpl) = 1.0d0
        g_w(i, j, k, ismpl) = g_dv
        w(i, j, k, ismpl) = dv
        g_temp(i, j, k, ismpl) = g_dv
        temp(i, j, k, ismpl) = dv
!              mark as boundary for normalising the lin. system
        bc_mask(i+(j-1)*i0+(k-1)*i0*j0, ismpl) = '0'
#endif
      END IF
    END IF
  END DO
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
! dirichlet nodes - - - - - - - - - - - - - - - - - - - - - - - - - - -
  DO ib=first_temp,last_temp
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
        g_val = g_propunit(bcu, idx_tbc, ismpl)
        val = propunit(bcu, idx_tbc, ismpl)
      END IF
      IF (tpbcu .GT. 0 .AND. nbctp .GT. 0) THEN
!           time-dependent bc:  val=ac*val+bc
!           get Alfa and Beta modificators
        CALL g_GET_TPBCALBE(malfa, g_malfa, mbeta, g_mbeta, tpbcu&
&                       , ismpl)
!           update time dependend modification of the bc-value
        g_val = g_malfa + val*g_mbeta + mbeta*g_val
        val = malfa + mbeta*val
      END IF
      IF (tpbcu .GE. 0) THEN
#ifdef BCMY
!              D = D+my
        g_d(i, j, k, ismpl) = g_d(i, j, k, ismpl) - g_dbc_data(ib&
&         , 2, ismpl)
        d(i, j, k, ismpl) = d(i, j, k, ismpl) - dbc_data(ib, 2, ismpl)
        g_w(i, j, k, ismpl) = g_w(i, j, k, ismpl) - val*g_dbc_data&
&         (ib, 2, ismpl) - dbc_data(ib, 2, ismpl)*g_val
        w(i, j, k, ismpl) = w(i, j, k, ismpl) - dbc_data(ib, 2, ismpl)*&
&         val
#else
!              standard boundary condition handling
        g_a(i, j, k, ismpl) = 0.D0
        a(i, j, k, ismpl) = 0.0d0
        g_b(i, j, k, ismpl) = 0.D0
        b(i, j, k, ismpl) = 0.0d0
        g_c(i, j, k, ismpl) = 0.D0
        c(i, j, k, ismpl) = 0.0d0
        g_e(i, j, k, ismpl) = 0.D0
        e(i, j, k, ismpl) = 0.0d0
        g_f(i, j, k, ismpl) = 0.D0
        f(i, j, k, ismpl) = 0.0d0
        g_g(i, j, k, ismpl) = 0.D0
        g(i, j, k, ismpl) = 0.0d0
        g_d(i, j, k, ismpl) = 0.D0
        d(i, j, k, ismpl) = 1.0d0
        g_w(i, j, k, ismpl) = g_val
        w(i, j, k, ismpl) = val
        g_temp(i, j, k, ismpl) = g_val
        temp(i, j, k, ismpl) = val
!              mark as boundary for normalising the lin. system
        bc_mask(i+(j-1)*i0+(k-1)*i0*j0, ismpl) = '0'
#endif
      END IF
    END IF
  END DO
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
! neumann  nodes    - - - - - - - - - - - - - - - - - - - - - - - - - -
  DO ib=first_temp,last_temp
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
    i_dir = ibc_data(ib, cbc_dir)
!        "neumann"?, skip otherwise
    IF (bctype .EQ. bt_neum) THEN
!           discrete values
      IF (bcu .LE. 0) THEN
        g_val = g_dbc_data(ib, 1, ismpl)
        val = dbc_data(ib, 1, ismpl)
      ELSE
        g_val = g_propunit(bcu, idx_tbc, ismpl)
        val = propunit(bcu, idx_tbc, ismpl)
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
        IF (i_dir .EQ. 0) THEN
          temp0 = delx(i)*dely(j)*delz(k)
          g_val = g_val/temp0
          val = val/temp0
        END IF
        IF (i_dir .EQ. 1 .OR. i_dir .EQ. 2) THEN
          g_val = g_val/delx(i)
          val = val/delx(i)
        END IF
        IF (i_dir .EQ. 3 .OR. i_dir .EQ. 4) THEN
          g_val = g_val/dely(j)
          val = val/dely(j)
        END IF
        IF (i_dir .EQ. 5 .OR. i_dir .EQ. 6) THEN
          g_val = g_val/delz(k)
          val = val/delz(k)
        END IF
        g_w(i, j, k, ismpl) = g_w(i, j, k, ismpl) - g_val
        w(i, j, k, ismpl) = w(i, j, k, ismpl) - val
      END IF
    END IF
  END DO
  RETURN
END SUBROUTINE g_SET_TBC

