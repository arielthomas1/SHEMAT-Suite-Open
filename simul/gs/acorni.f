!>Copyright (C) 1996, The Board of Trustees of the Leland Stanford     %\n
!>Junior University.  All rights reserved.                             %\n
!>
!>The programs in GSLIB are distributed in the hope that they will be  %\n
!>useful, but WITHOUT ANY WARRANTY.  No author or distributor accepts  %\n
!>responsibility to anyone for the consequences of using them or for   %\n
!>whether they serve any particular purpose or work at all, unless he  %\n
!>says so in writing.  Everyone is granted permission to copy, modify  %\n
!>and redistribute the programs in GSLIB, but only under the condition %\n
!>that this notice and the above copyright notice remain intact.       %\n
      double precision function acorni(idum)
c-----------------------------------------------------------------------
c
c Fortran implementation of ACORN random number generator of order less
c than or equal to 12 (higher orders can be obtained by increasing the
c parameter value MAXORD).
c
c
c NOTES: 1. The variable idum is a dummy variable. The common block
c           IACO is used to transfer data into the function.
c
c        2. Before the first call to ACORN the common block IACO must
c           be initialised by the user, as follows. The values of
c           variables in the common block must not subsequently be
c           changed by the user.
c
c             KORDEI - order of generator required ( must be =< MAXORD)
c
c             MAXINT - modulus for generator, must be chosen small
c                      enough that 2*MAXINT does not overflow
c
c             ixv(1) - seed for random number generator
c                      require 0 < ixv(1) < MAXINT
c
c             (ixv(I+1),I=1,KORDEI)
c                    - KORDEI initial values for generator
c                      require 0 =< ixv(I+1) < MAXINT
c
c        3. After initialisation, each call to ACORN generates a single
c           random number between 0 and 1.
c
c        4. An example of suitable values for parameters is
c
c             KORDEI   = 10
c             MAXINT   = 2**30
c             ixv(1)   = an odd integer in the (approximate) range 
c                        (0.001 * MAXINT) to (0.999 * MAXINT)
c             ixv(I+1) = 0, I=1,KORDEI
c
c
c
c Author: R.S.Wikramaratna,                           Date: October 1990
c-----------------------------------------------------------------------
      implicit double precision (a-h,o-z)
      include 'gslib.inc'
      parameter (MAXINT=2**30)
      do i=1,KORDEI
            ixv(i+1)=(ixv(i+1)+ixv(i))
            if(ixv(i+1).ge.MAXINT) ixv(i+1)=ixv(i+1)-MAXINT
      end do
      acorni=dble(ixv(KORDEI+1))/dble(MAXINT)
      return
      end

      double precision function acorni2(idum)
      implicit double precision (a-h,o-z)
      include 'gslib.inc'
      parameter (MAXINT=2**30)
      do i=1,KORDEI
            ixv2(i+1)=(ixv2(i+1)+ixv2(i))
            if(ixv2(i+1).ge.MAXINT) ixv2(i+1)=ixv2(i+1)-MAXINT
      end do
      acorni2=dble(ixv2(KORDEI+1))/dble(MAXINT)
      return
      end