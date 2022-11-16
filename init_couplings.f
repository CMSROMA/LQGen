      subroutine init_couplings
      implicit none
      include 'PhysPars.h'
      include 'pwhg_st.h'
      include 'pwhg_math.h'
      include 'nlegborn.h'
      include 'pwhg_kn.h'
      include 'pwhg_em.h'
      include 'pwhg_physpar.h'
      include 'pwhg_flst.h'
      real * 8 mass_low,mass_high,tmpwidth
      real * 8 powheginput,alphaqed
      real * 8, parameter :: em_alpha0 = 1/137.035999084d0
      external powheginput
      logical verbose
      parameter(verbose=.true.)
      integer i,j
      logical withtops
      
c     Just a value
      st_alpha =0.118
      em_alpha = powheginput("#alphaQED")
      if (em_alpha<0d0) em_alpha = em_alpha0

      kn_ktmin=0

      ph_mLQ=powheginput("#mLQ")
      if (ph_mLQ < 0) ph_mLQ = 500d0
      write(*,*) 'leptoquark mass set to ',ph_mLQ
      physpar_phspmasses(42)=ph_mLQ
           
      if (powheginput("#BWgen") == 1) then
         ph_BWgen_finitewidth = .true.
      else
         ph_BWgen_finitewidth = .false.
      endif

      ph_LQmasslow = powheginput("#LQmasslow")
      ph_LQmasshigh= powheginput("#LQmasshigh")
      if (ph_LQmasslow<0d0) ph_LQmasslow = 1d0
      if (ph_LQmasshigh<0d0) ph_LQmasslow = 2*ph_mLQ
      
C TODO should check, that there is a value for each coupling. If not
C present then automatically set to zero. Same for the charge of LQ.

      ph_yLQ(1,1) = powheginput("#y_1e")
      ph_yLQ(1,2) = powheginput("#y_1m")
      ph_yLQ(1,3) = powheginput("#y_1t")

      ph_yLQ(2,1) = powheginput("#y_2e")
      ph_yLQ(2,2) = powheginput("#y_2m")
      ph_yLQ(2,3) = powheginput("#y_2t")
      
      ph_yLQ(3,1) = powheginput("#y_3e")
      ph_yLQ(3,2) = powheginput("#y_3m")
      ph_yLQ(3,3) = powheginput("#y_3t")

      ph_LQc = powheginput("#charge") 

c     switch off top couplings unless explicitly asked
      withtops =.false.
      if(powheginput("#withtops") == 1) then
         withtops =.true.
      endif
      
      if ( (.not.withtops) .and.
     1     (abs(ph_LQc) == 1d0 .or. abs(ph_LQc) ==5d0)   ) then
         ph_yLQ(3,:)= 0d0
      endif

c     the user can provide the LQ width by theirself
c     otherwise it is computed without assuming any SU(2) relations
      
      ph_wLQ=powheginput("#widthLQ")
      if (ph_wLQ < 0) then
         ph_wLQ = 0d0
         do i=1,3
            do j=1,3
c     LO partial width
               ph_wLQ = ph_wLQ +
     1              ph_yLQ(i,j)**2 * ph_mLQ/16/pi
            enddo
         enddo         
      endif
      
      write(*,*) 'leptoquark width set to ',ph_wLQ
      physpar_phspwidths(42)=ph_wLQ
      
c      quark and lepton masses

      physpar_mq(1:3) = 0d0
      physpar_mq(4) = 1.5d0
      physpar_mq(5) = 4.75d0
      physpar_mq(6) = 172d0
      physpar_ml(1) = 0.000511d0 
      physpar_ml(2) = 0.105d0
      physpar_ml(3) = 1.77d0
      
c     number of light flavors
c     if withtops, add the top quark to the list of collinear particles
      if (withtops) then
         st_nlight = 6
         flst_ncollparticles = 12
         flst_collparticles(1:flst_ncollparticles)=
     1        (/ 0,1,2,3,4,5,6,11,13,15,21,22 /)
         
      else         
         st_nlight = 5
      endif
      
      end

