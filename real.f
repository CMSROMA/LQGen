      subroutine setreal(p,rflav,amp2real)
      implicit none
      include 'nlegborn.h'
      include 'pwhg_flst.h'
      include 'pwhg_math.h'
      include 'pwhg_st.h'
      include 'pwhg_em.h'
      include 'pwhg_physpar.h'      
      include 'PhysPars.h'
      real * 8 msq
      real * 8 p(0:3,nlegreal)
      real * 8 p1(0:3),k(0:3),q(0:3), p2(0:3)
      integer rflav(nlegreal),mcfmflav(nlegreal)
      real * 8 amp2real, y
      real * 8 dotp
      external dotp
      integer i,j
      real * 8 kq,kp1,qp1,s,t,u
      real * 8 qq,ql,qlq 
      real * 8 m2,m4
      logical finalgluon, photon
      data finalgluon/.false./
      save finalgluon
      data photon/.false./
      save photon

      photon = .false.
      finalgluon = .false.

      if (ph_BWgen_finitewidth) then
         m2=p(0,3)**2-p(1,3)**2-p(2,3)**2-p(3,3)**2 
      else
         m2 = ph_mLQ**2
      endif

      m4 = m2**2
      amp2real = 0d0

      if(any(abs(rflav) .eq. 1)) i = 1
      if(any(abs(rflav) .eq. 2)) i = 1
      if(any(abs(rflav) .eq. 3)) i = 2
      if(any(abs(rflav) .eq. 4)) i = 2
      if(any(abs(rflav) .eq. 5)) i = 3
      if(any(abs(rflav) .eq. 6)) i = 3
      if(any(abs(rflav) .eq. 11)) j = 1
      if(any(abs(rflav) .eq. 13)) j = 2
      if(any(abs(rflav) .eq. 15)) j = 3

      y = ph_yLQ(i,j)

C The real amplitude for the processes involving gluons.
      do j=1,nlegreal
         if (rflav(j) .eq. 0) then
            if (j .gt. 2) then
               finalgluon = .true.
               k(:) = p(:,j)
            else
               finalgluon = .false.
               p1(:) = p(:,j)
            endif
         endif
         if (abs(rflav(j)) .le. 6 .and. rflav(j).ne.0) then
            if (j .gt. 2) k = p(:,j)
            if (j .le. 2) p1 = p(:,j)
         endif
         if (abs(rflav(j)) .eq. 42) q = p(:,j)
         if (rflav(j) .eq. 22) then
            if (j .le. 2) photon = .true.
         endif
      enddo
      
      kq  = dotp(k,q)
      kp1 = dotp(k,p1)
      qp1 = dotp(q,p1)

      if (finalgluon) then
         amp2real = 8d0/3d0 *(m4/kq/kp1 -m4/(kq**2) + 2*m2/kp1 +2*kq/kp1
     1        -2*m2/kq -2d0)
         
      else

         amp2real = (m4/qp1/kp1 + m4/(qp1**2) - 2*m2/kp1 
     1        + 2*qp1/kp1 - 2*m2/qp1 + 2d0)
         
      endif

      amp2real = amp2real *y**2 *pi**2  
      
C Real amplitude for processes with photon. 
      if (photon) then
         do j=1, nlegreal
            if (rflav(j) .eq. 22) p1 = p(:,j)
            if (abs(rflav(j)) .le. 6) then
               p2 = p(:,j)
               if((abs(rflav(j)) .eq. 2) .or. (abs(rflav(j)) .eq. 4)) then
                  qq = 2d0/3d0
               else
                  qq = -1d0/3d0
               endif
               if(rflav(j) .lt. 0) qq = -1d0 * qq
            endif
            if (abs(rflav(j)) .gt. 6 .and. (abs(rflav(j)) .le. 15)) then
               k = p(:,j)
               if (rflav(j) .lt. 0) then
                  ql = 1d0
               else
                  ql = -1d0                                 
               endif
            endif
            if (rflav(j) .eq. 42) q = p(:,j)
         enddo

         qlq = qq -ql
                  
         s =  2 *dotp(p1,p2)
         t = -2 *dotp(p1,k)
         u = -2 *dotp(p1,q) + m2

         amp2real = 4*pi**2 *y**2 *(-ql**2 *s/t 
     1   -2*qq*ql*(1+m2*u/s/t) -ql*qlq *u/(s+t) *(1-2*m2/t) -qq**2 *t/s 
     2   +qlq**2 *u**2 /(s+t)**2 *(1+m2/u) + qq*qlq*u/(s+t) *(1-2*m2/s))

         amp2real = amp2real * em_alpha /st_alpha !/(2*pi)**3

      endif


c     correct for running width if BW generation is on
      if (ph_BWgen_finitewidth) then
         amp2real = amp2real * dotp(q,q)/ph_mLQ**2
      endif
      
      end

      subroutine regularcolour_lh
      write(*,*) ' regularcolour_lh: there are no regulars in this process'
      write(*,*) ' exiting ...'
      call exit(-1)
      end
      
