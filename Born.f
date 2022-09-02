      subroutine setborn(p,bflav,born,bornjk,bmunu)
      implicit none
      include 'pwhg_math.h'
      include 'pwhg_st.h'
      include 'nlegborn.h'
      include 'pwhg_flst.h'
      include 'pwhg_em.h'
      include 'PhysPars.h'
      integer nlegs
      parameter (nlegs=nlegborn)
      real * 8 p(0:3,nlegs),bornjk(nlegs,nlegs)
      integer bflav(nlegs)
      real * 8 bmunu(0:3,0:3,nlegs),born,s
      logical islepton
      integer i,j,k,iq,il
      real * 8 y
      real * 8 powheginput
      external powheginput


c     Colour factors for colour-correlated Born amplitudes;
c     p(0:3,i) are the 0,1,2,3 components of the momenta
c     of the ith particle.
c     i=1,2 are the incoming particles (momenta are incoming)
c     i=3 is the outgoing particle  (momenta are outgoing)

c     compute your cross section here as a function of the momentum
c     and of the flavours of the particles, avalable in the
c     bflav (integer) array
      
      if (abs(bflav(1)) .eq. 11 .or. abs(bflav(2)) .eq. 11) then
         j = 1
      elseif (abs(bflav(1)) .eq. 13 .or. abs(bflav(2)) .eq. 13) then
         j = 2
      elseif (abs(bflav(1)) .eq. 15 .or. abs(bflav(2)) .eq. 15) then
         j = 3
      elseif (abs(bflav(1)) .eq. 0 .or. abs(bflav(2)) .eq. 0) then
         y = 0d0
      else
         WRITE(*,*) "Coupling is set to zero for this process.", bflav
      endif

      if (abs(bflav(1)) .eq. 1 .or. abs(bflav(2)) .eq. 1) then
         i = 1
      elseif (abs(bflav(1)) .eq. 2 .or. abs(bflav(2)) .eq. 2) then
         i = 1
      elseif (abs(bflav(1)) .eq. 3 .or. abs(bflav(2)) .eq. 3) then
         i = 2
      elseif (abs(bflav(1)) .eq. 4 .or. abs(bflav(2)) .eq. 4) then
         i = 2
      elseif (abs(bflav(1)) .eq. 5 .or. abs(bflav(2)) .eq. 5) then
         i = 3
      elseif (abs(bflav(1)) .eq. 6 .or. abs(bflav(2)) .eq. 6) then
         i = 3
      elseif (abs(bflav(1)) .eq. 0 .or. abs(bflav(2)) .eq. 0) then
         y = 0d0
      else
         write(*,*) "Coupling is set to zero for this process.", bflav
      endif
      
      y = ph_yLQ(i,j)
      if (ph_BWgen_finitewidth) then
         s = p(0,3)**2-p(1,3)**2-p(2,3)**2-p(3,3)**2
         born = y**2 * s /4d0

c     correct for 'running' width         
         born = born * s / ph_mLQ**2         
      else
         born = y**2 * ph_mLQ**2 /4d0
      endif

      bmunu=0

      bornjk(1,2) = 0d0
      bornjk(2,1) = 0d0

      if (abs(bflav(1)) .le. 6 ) then
         iq = 1
         il = 2
      else
         iq = 2
         il = 1
      endif

      bornjk(il,3) = 0d0
      bornjk(3,il) = 0d0

      bornjk(iq,3) = born * 4d0/3d0
      bornjk(3,iq) = born * 4d0/3d0

      end

      subroutine borncolour_lh
c Sets up the colour for the given flavour configuration
c already filled in the Les Houches interface.
c In case there are several colour structure, one
c should pick one with a probability proportional to
c the value of the corresponding cross section, for the
c kinematics defined in the Les Houches interface
      implicit none
      include 'LesHouches.h'
      integer j
c     neutral particles
      icolup(1:2,1:3)=0
c     colored particles
      do j=1,2
         if((idup(j).gt.0).and.(idup(j).le.6)) then
            icolup(1,j)=501
            icolup(2,j)=0
            icolup(1,3)=501
            icolup(2,3)=0
         elseif((idup(j).lt.0).and.(idup(j).ge.-6)) then
            icolup(1,j)=0
            icolup(2,j)=501
            icolup(1,3)=0
            icolup(2,3)=501
         endif
      enddo
      if(sum(abs(icolup)) == 0) then
         write(*,*) ' borncolour_lh: invalid flavours ',idup(1:3)
         call exit(-1)
      endif
      end

      subroutine finalize_lh
      implicit none 
      include 'LesHouches.h'
      include 'pwhg_math.h'
      real *8 lepmass(3),decmass,chargeofparticle_all,qlq
      real *8 mLQ,ctheta,stheta,phi,random
      integer j, id_quark, id_lep

c     TODO : check the assignment of the decay channel if multiple choice is available 
c     according to the relative BRs 
      
c     replace pdg number of LQ from 42 to Herwig convention
      if (nup == 3 ) then   ! born event
         qlq= chargeofparticle_all(idup(1))+chargeofparticle_all(idup(2))
      else                  ! real event
         qlq= chargeofparticle_all(idup(1))+chargeofparticle_all(idup(2))
     &        - chargeofparticle_all(idup(4))          
      endif
      
      select case ( int(qlq*3d0) ) 
      case(-1)
         idup(3) = 9911561
      case(-2)
         idup(3) = -9941561
      case(-4)
         idup(3) = 9921561
      case(-5)
         idup(3) = -9941561
      case(1)
         idup(3) = -9911561
      case(2)
         idup(3) = 9941561
      case(4)
         idup(3) = -9921561
      case(5)
         idup(3) = 9941561
      end select            
      
      mLQ = dsqrt(pup(4,3)**2-pup(1,3)**2-pup(2,3)**2-pup(3,3)**2)

      nup = nup+2
      istup(3) = 2 ! LQ marked as resonances

c$$$      do j=1,2
c$$$         if ( is_lepton(idup(j)) ) then
c$$$            idup(nup) = idup(j)
c$$$         elseif(is_quark(idup(j))) then
c$$$            idup(nup-1) = idup(j)            
c$$$         endif
c$$$         if (idup(j)==22) then
c$$$            idup(nup) = -idup(4)
c$$$         elseif (idup(j)==21) then 
c$$$            idup(nup-1) = -idup(4)            
c$$$         endif
c$$$      enddo

      call pick_decay_channel(random(), qlq, id_quark,id_lep)
      idup(nup) = id_lep
      idup(nup-1) = id_quark 
      
      mothup(1,nup) = 3
      mothup(2,nup) = 3

      mothup(1,nup-1) = 3       ! quark
      mothup(2,nup-1) = 3
            
      icolup(1:2,nup-1) = icolup(1:2,3)
      icolup(1:2,nup) = 0

      spinup(nup-1) = 9d0
      spinup(nup) = 9d0

      istup(nup) = 1
      istup(nup-1) = 1
      
      ctheta = 2d0*random()-1d0
      stheta = dsqrt(1d0-ctheta**2)
      phi = 2d0*pi*random()

      pup(3,nup) = mLQ/2*ctheta
      pup(1,nup) = mLQ/2*stheta*cos(phi)
      pup(2,nup) = mLQ/2*stheta*sin(phi)
      pup(4,nup) = mLQ/2
      pup(5,nup) = 0d0
      
      pup(1:3,nup-1) = -pup(1:3,nup)
      pup(4,nup-1) = mLQ/2
      pup(5,nup-1) = 0d0

      
      call boost2resoninv4(pup(1:4,3),1,pup(1:4,nup-1),pup(1:4,nup-1))
      call boost2resoninv4(pup(1:4,3),1,pup(1:4,nup),pup(1:4,nup))
      
      call lhefinitemasses
      
      contains

      logical function is_lepton(id)
      integer :: id

      if ( abs(id)>= 11 .and. abs(id) <= 15) then
         is_lepton = .true.
      else
         is_lepton = .false.
      endif      
      end 

      logical function is_quark(id)
      integer :: id

      if ( abs(id)<= 6 .and. abs(id) > 0) then
         is_quark = .true.
      else
         is_quark = .false.
      endif      
      end 
      
      end


      subroutine pick_decay_channel(xr,LQ_charge,idq,idl)      
      implicit none
      include 'PhysPars.h'
      real * 8, intent(in) :: xr , LQ_charge
      integer, intent(out) :: idl,idq
      real * 8,save :: tot_width_lq
      real * 8 :: xn, xnp1
      integer :: i,j
      logical,save :: ini=.true.
      integer :: to_flavs(4,2,3,3)
      integer, parameter :: c1 = 1 , c5=2 , cd2=3, c4=4, q=1, l=2
      
      if (ini) then
         tot_width_lq = 0d0
         do i=1,3
            do j=1,3
c     uses LO formula for BRs, only squared couplings matter here
               tot_width_lq = tot_width_lq + ph_yLQ(i,j)**2 
            enddo
         enddo
         ini = .false.
      endif
      
c     pick decay channel

      xn = 0d0           
      do i=1,3
         do j=1,3
            xnp1 = xn + ph_yLQ(i,j)**2/tot_width_lq
            if (xr >xn .and. xr <= xnp1) then               
               goto 10
            endif
            xn = xnp1
         enddo
      enddo
      
 10   continue
            
      idl = 11+2*(j-1)
      select case( -int(abs(LQ_charge*3))  )
      case(-1)               
         idq = 2+2*(i-1)
      case(-5)
         idq = -(2+2*(i-1))
      case(-2)
         idq = -(1+2*(i-1))
      case(-4)
         idq = 1+2*(i-1)         
      end select

      if (LQ_charge>0) then
         idq = -idq
         idl = -idl
      endif
      
      end

      
      subroutine rmn_suppression(fact)
      implicit none
      real * 8 fact
      include 'nlegborn.h'
      include 'pwhg_kn.h'
      real * 8 spart,pairmass,dotp
      integer j,k
      fact = 1
      end


      subroutine regular_suppression(fact)
      implicit none
      real * 8 fact
      call rmn_suppression(fact)
      end


      subroutine global_suppression(c,fact)
      implicit none
      character * 1 c
      real * 8 fact
      fact=1
      end


      function chargeofparticle_all(id)
c Returns the electric charge (in units of the positron charge)
c of particle id (pdg conventions, gluon is zero)
      implicit none
      include 'pwhg_flg.h'
      real * 8 chargeofparticle_all
      integer id
      if(abs(id).gt.0.and.abs(id).le.6) then
         if(mod(abs(id),2).eq.0) then
            chargeofparticle_all =  2d0/3
         else
            chargeofparticle_all = -1d0/3
         endif
      elseif(abs(id).gt.10.and.abs(id).le.16) then
         if(mod(abs(id),2).ne.0) then
            chargeofparticle_all = -1d0
         else
            chargeofparticle_all = 0
         endif
      else
         chargeofparticle_all=0
      endif
      if(id<0) chargeofparticle_all = - chargeofparticle_all
      end
      
