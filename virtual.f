c     returns 2 Re(M_B * M_V)/(as/(2pi)), 
c     where M_B is the Born amplitude and 
c     M_V is the finite part of the virtual amplitude
c     The as/(2pi) factor is attached at a later point
      subroutine setvirtual(p,vflav,virtual)
      implicit none
      include 'nlegborn.h'
      include 'pwhg_st.h'
      include 'pwhg_physpar.h'
      include 'pwhg_math.h'
      include 'pwhg_kn.h'
      include 'PhysPars.h'
      include 'pwhg_flg.h'
      real * 8 p(0:3,nlegborn)
      integer vflav(nlegborn)
      integer i,j
      real * 8 virtual,y,s
      real * 8 born,dummy(0:3,0:3)
      
c include your virtual depending upon the flavour

ccc   scale dependence to be checked
      
      if(any(abs(vflav) .eq. 1)) i = 1
      if(any(abs(vflav) .eq. 2)) i = 1
      if(any(abs(vflav) .eq. 3)) i = 2
      if(any(abs(vflav) .eq. 4)) i = 2
      if(any(abs(vflav) .eq. 5)) i = 3
      if(any(abs(vflav) .eq. 6)) i = 3
      if(any(abs(vflav) .eq. 11)) j = 1
      if(any(abs(vflav) .eq. 13)) j = 2
      if(any(abs(vflav) .eq. 15)) j = 3

      y = ph_yLQ(i,j)

      if (flg_QEDonly) then
c     if only QED, virtual is zero
         virtual = 0d0 

      else
         
         if (ph_BWgen_finitewidth) then
            s = p(0,3)**2-p(1,3)**2-p(2,3)**2-p(3,3)**2
            virtual= -y**2/3d0 * s *( 2d0 + pi**2/6d0
     1           + dlog(st_muren2/s) *
     2           (1d0 + 0.5d0*dlog(st_muren2/s)) )

c     correct for 'running' width         
            virtual = virtual * s / ph_mLQ**2         
            
         else
            virtual= -y**2/3d0 * ph_mLQ**2 *( 2d0 + pi**2/6d0
     1           + dlog(st_muren2/ph_mLQ**2) *
     2           (1d0 + 0.5d0*dlog(st_muren2/ph_mLQ**2)) )
         endif

      endif

      end

