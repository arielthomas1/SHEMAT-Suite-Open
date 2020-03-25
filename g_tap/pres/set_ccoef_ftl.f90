!        Generated by TAPENADE     (INRIA, Ecuador team)
!  tapenade 3.x
!
!  Differentiation of set_ccoef in forward (tangent) mode:
!   variations   of useful results: *d *e *f *g *a *b *c
!   with respect to varying inputs: *d *e *f *g *temp *propunit
!                *tsal *pres *a *b *c
!   Plus diff mem management of: d:in e:in f:in g:in temp:in propunit:in
!                tsal:in pres:in a:in b:in c:in
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
!>    @brief calculate coefficents for the transport equation
!>    @param[in] spec species index
!>    @param[in] ismpl local sample index
!>    @details
!> calculate coefficents for the transport equation\n
!> coefficients are stored as vectors in the diagonals a-g (d center) and rhs in w.\n
SUBROUTINE g_SET_CCOEF(spec, ismpl)
  USE ARRAYS

  USE g_ARRAYS

  USE MOD_GENRL
  USE MOD_GENRLC
  USE MOD_FLOW
  USE MOD_CONC
  USE MOD_TIME

  USE g_MOD_TIME

  USE MOD_LINFOS
  IMPLICIT NONE
  INTEGER :: i, j, k
  INTEGER :: ismpl
  EXTERNAL DI, DJ, DK, POR, VX, VY, &
&     VZ, ALFA
  EXTERNAL g_DI, g_DJ, g_DK, g_VX, g_VY, g_VZ, g_ALFA
  DOUBLE PRECISION :: DI, DJ, DK, POR, VX, &
& VY, VZ, ALFA
  DOUBLE PRECISION :: g_DI, g_DJ, g_DK, g_VX, g_VY, g_VZ, &
& g_ALFA
  DOUBLE PRECISION :: v2, de, alf, p2
  DOUBLE PRECISION :: g_v2, g_de, g_alf, g_p2
  INTEGER :: spec
  EXTERNAL DUMMY
  DOUBLE PRECISION :: result1
  DOUBLE PRECISION :: g_result1
!debug      write(99,'(a,3i4)') 'ShemSUITE i0,j0,k0:',i0,j0,k0
!$OMP master
  IF (linfos(3) .GE. 2) WRITE(*, *) ' ... ccoef'
!$OMP end master
! inner points of grid - - - - - - - - - - - - - - - - - - - - - - - - -
!$OMP do schedule(static) collapse(3)
  DO k=1,k0
    DO j=1,j0
      DO i=1,i0
        IF (i0 .GT. 1) THEN
          IF (i .LT. i0) THEN
            g_de = g_DI(i, j, k, spec, ismpl, de)
            g_result1 = g_VX(i, j, k, ismpl, result1)
            g_v2 = 0.5d0*g_result1
            v2 = 0.5d0*result1
            IF (de .GT. 0.d0) THEN
              g_p2 = (g_v2-v2*g_de/de)/de
              p2 = v2/de
              g_alf = g_ALFA(p2, g_p2, alf)
            ELSE
              alf = 0.d0
              IF (v2 .LT. 0.d0) alf = -1.d0
              IF (v2 .GT. 0.d0) THEN
                alf = 1.d0
                g_alf = 0.D0
              ELSE
                g_alf = 0.D0
              END IF
            END IF
            g_e(i, j, k, ismpl) = (g_de-(1.d0-alf)*g_v2+v2*g_alf&
&             )/delx(i)
            e(i, j, k, ismpl) = (de-(1.d0-alf)*v2)/delx(i)
            g_d(i, j, k, ismpl) = g_d(i, j, k, ismpl) - (g_de+v2*&
&             g_alf+(alf+1.d0)*g_v2)/delx(i)
            d(i, j, k, ismpl) = d(i, j, k, ismpl) - (de+(1.d0+alf)*v2)/&
&             delx(i)
          END IF
          IF (i .GT. 1) THEN
            g_de = g_DI(i - 1, j, k, spec, ismpl, de)
            g_result1 = g_VX(i - 1, j, k, ismpl, result1)
            g_v2 = 0.5*g_result1
            v2 = 0.5*result1
            alf = 0.d0
            IF (v2 .EQ. 0.d0) THEN
              alf = 0.d0
              g_alf = 0.D0
            ELSE IF (de .GT. 0.d0) THEN
              g_p2 = (g_v2-v2*g_de/de)/de
              p2 = v2/de
              g_alf = g_ALFA(p2, g_p2, alf)
            ELSE
              IF (v2 .LT. 0.d0) alf = -1.d0
              IF (v2 .GT. 0.d0) THEN
                alf = 1.d0
                g_alf = 0.D0
              ELSE
                g_alf = 0.D0
              END IF
            END IF
            g_c(i, j, k, ismpl) = (g_de+v2*g_alf+(alf+1.d0)*g_v2&
&             )/delx(i)
            c(i, j, k, ismpl) = (de+(1.d0+alf)*v2)/delx(i)
            g_d(i, j, k, ismpl) = g_d(i, j, k, ismpl) - (g_de-(&
&             1.d0-alf)*g_v2+v2*g_alf)/delx(i)
            d(i, j, k, ismpl) = d(i, j, k, ismpl) - (de-(1.d0-alf)*v2)/&
&             delx(i)
          END IF
        END IF
        IF (j0 .GT. 1) THEN
          IF (j .LT. j0) THEN
            g_de = g_DJ(i, j, k, spec, ismpl, de)
            g_result1 = g_VY(i, j, k, ismpl, result1)
            g_v2 = 0.5*g_result1
            v2 = 0.5*result1
            alf = 0.d0
            IF (v2 .EQ. 0.d0) THEN
              alf = 0.d0
              g_alf = 0.D0
            ELSE IF (de .GT. 0.d0) THEN
              g_p2 = (g_v2-v2*g_de/de)/de
              p2 = v2/de
              g_alf = g_ALFA(p2, g_p2, alf)
            ELSE
              IF (v2 .LT. 0.d0) alf = -1.d0
              IF (v2 .GT. 0.d0) THEN
                alf = 1.d0
                g_alf = 0.D0
              ELSE
                g_alf = 0.D0
              END IF
            END IF
            g_f(i, j, k, ismpl) = (g_de-(1.d0-alf)*g_v2+v2*g_alf&
&             )/dely(j)
            f(i, j, k, ismpl) = (de-(1.d0-alf)*v2)/dely(j)
            g_d(i, j, k, ismpl) = g_d(i, j, k, ismpl) - (g_de+v2*&
&             g_alf+(alf+1.d0)*g_v2)/dely(j)
            d(i, j, k, ismpl) = d(i, j, k, ismpl) - (de+(1.d0+alf)*v2)/&
&             dely(j)
          END IF
          IF (j .GT. 1) THEN
            g_de = g_DJ(i, j - 1, k, spec, ismpl, de)
            g_result1 = g_VY(i, j - 1, k, ismpl, result1)
            g_v2 = 0.5*g_result1
            v2 = 0.5*result1
            alf = 0.d0
            IF (v2 .EQ. 0.d0) THEN
              alf = 0.d0
              g_alf = 0.D0
            ELSE IF (de .GT. 0.d0) THEN
              g_p2 = (g_v2-v2*g_de/de)/de
              p2 = v2/de
              g_alf = g_ALFA(p2, g_p2, alf)
            ELSE
              IF (v2 .LT. 0.d0) alf = -1.d0
              IF (v2 .GT. 0.d0) THEN
                alf = 1.d0
                g_alf = 0.D0
              ELSE
                g_alf = 0.D0
              END IF
            END IF
            g_b(i, j, k, ismpl) = (g_de+v2*g_alf+(alf+1.d0)*g_v2&
&             )/dely(j)
            b(i, j, k, ismpl) = (de+(1.d0+alf)*v2)/dely(j)
            g_d(i, j, k, ismpl) = g_d(i, j, k, ismpl) - (g_de-(&
&             1.d0-alf)*g_v2+v2*g_alf)/dely(j)
            d(i, j, k, ismpl) = d(i, j, k, ismpl) - (de-(1.d0-alf)*v2)/&
&             dely(j)
          END IF
        END IF
        IF (k0 .GT. 1) THEN
          IF (k .LT. k0) THEN
            g_de = g_DK(i, j, k, spec, ismpl, de)
            g_result1 = g_VZ(i, j, k, ismpl, result1)
            g_v2 = 0.5d0*g_result1
            v2 = 0.5d0*result1
            alf = 0.d0
            IF (v2 .EQ. 0.d0) THEN
              alf = 0.d0
              g_alf = 0.D0
            ELSE IF (de .GT. 0.d0) THEN
              g_p2 = (g_v2-v2*g_de/de)/de
              p2 = v2/de
              g_alf = g_ALFA(p2, g_p2, alf)
            ELSE
              IF (v2 .LT. 0.d0) alf = -1.d0
              IF (v2 .GT. 0.d0) THEN
                alf = 1.d0
                g_alf = 0.D0
              ELSE
                g_alf = 0.D0
              END IF
            END IF
            g_g(i, j, k, ismpl) = (g_de-(1.d0-alf)*g_v2+v2*g_alf&
&             )/delz(k)
            g(i, j, k, ismpl) = (de-(1.d0-alf)*v2)/delz(k)
            g_d(i, j, k, ismpl) = g_d(i, j, k, ismpl) - (g_de+v2*&
&             g_alf+(alf+1.d0)*g_v2)/delz(k)
            d(i, j, k, ismpl) = d(i, j, k, ismpl) - (de+(1.d0+alf)*v2)/&
&             delz(k)
          END IF
          IF (k .GT. 1) THEN
            g_de = g_DK(i, j, k - 1, spec, ismpl, de)
            g_result1 = g_VZ(i, j, k - 1, ismpl, result1)
            g_v2 = 0.5d0*g_result1
            v2 = 0.5d0*result1
            alf = 0.d0
            IF (v2 .EQ. 0.d0) THEN
              alf = 0.d0
              g_alf = 0.D0
            ELSE IF (de .GT. 0.d0) THEN
              g_p2 = (g_v2-v2*g_de/de)/de
              p2 = v2/de
              g_alf = g_ALFA(p2, g_p2, alf)
            ELSE
              IF (v2 .LT. 0.d0) alf = -1.d0
              IF (v2 .GT. 0.d0) THEN
                alf = 1.d0
                g_alf = 0.D0
              ELSE
                g_alf = 0.D0
              END IF
            END IF
            g_a(i, j, k, ismpl) = (g_de+v2*g_alf+(alf+1.d0)*g_v2&
&             )/delz(k)
            a(i, j, k, ismpl) = (de+(1.d0+alf)*v2)/delz(k)
            g_d(i, j, k, ismpl) = g_d(i, j, k, ismpl) - (g_de-(&
&             1.d0-alf)*g_v2+v2*g_alf)/delz(k)
            d(i, j, k, ismpl) = d(i, j, k, ismpl) - (de-(1.d0-alf)*v2)/&
&             delz(k)
          END IF
        END IF
      END DO
    END DO
  END DO
!$OMP end do nowait
  RETURN
END SUBROUTINE g_SET_CCOEF

