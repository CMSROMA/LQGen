      subroutine init_couplings
      implicit none
c      include 'PhysPars.h'
      include 'pwhg_st.h'
      include 'pwhg_math.h'
      include 'nlegborn.h'
      include 'pwhg_kn.h'
      include 'pwhg_em.h'
      include 'RES.h'
      real * 8 mass_low,mass_high,tmpwidth
      real * 8 powheginput
      external powheginput
      logical verbose
      parameter(verbose=.true.)
      character * 30 proc
      common/cproc/proc
      call powheginputstring('whichproc',proc)
c     Just a value
      st_alpha=0.12
      if(proc == 'mu-tau-mu-tau') then
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccc   INDEPENDENT QUANTITIES       
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
         ph_RESmass = powheginput("ZPmass")

         ph_gr=powheginput("#gr")
         ph_gl=powheginput("#gl")

         ph_RESwidth = powheginput("#ZPwidth")

         if(  ph_gr==-1000000 .and.
     1        ph_gl==-1000000 .and.
     2        ph_RESwidth < 0) then
            write(*,*) ' must enter at least one of gr, gl, ZPwidth'
            write(*,*) ' exiting ...'
            call exit(-1)
         endif
         
         if(  ph_gr/=-1000000 .and.
     1        ph_gl/=-1000000 .and.
     2        ph_RESwidth > 0) then
            write(*,*) ' must enter at only one of gr, gl, ZPwidth'
            write(*,*) ' exiting ...'
            call exit(-1)
         endif
         
 
         
         if (ph_RESwidth.le.0d0) then
            if(ph_gr==-1000000) ph_gr=0
            if(ph_gl==-1000000) ph_gl=0
            ph_RESwidth = (ph_gr**2+ph_gl**2)/(12*pi) * ph_RESmass
         else
c     rescale gr and gl to match the ZPwidth
            tmpwidth=(ph_gr**2+ph_gl**2)/(12*pi) * ph_RESmass
            ph_gr=ph_gr*sqrt(ph_RESwidth/tmpwidth)
            ph_gl=ph_gl*sqrt(ph_RESwidth/tmpwidth)
            write(*,*) 'gr and gl rescaled to match the input width'
            write(*,*) 'width=',
     1           (ph_gr**2+ph_gl**2)/(12*pi) * ph_RESmass, ph_RESwidth
         endif
      elseif(proc == 'LQumu' .or. proc == 'LQue') then
         
         ph_RESmass = powheginput("LQmass")

         ph_yLQ=powheginput("#yLQ")
         
         ph_RESwidth = powheginput("#LQwidth")
         if(  ph_yLQ==-1000000 .and.
     2        ph_RESwidth == -1000000) then
            write(*,*) ' must enter at least one of yLQ or LQwidth'
            write(*,*) ' exiting ...'
            call exit(-1)
         endif

         if(  ph_yLQ/=-1000000 .and.
     2        ph_RESwidth /= -1000000) then
            write(*,*) ' must enter only one of yLQ or LQwidth'
            write(*,*) ' exiting ...'
            call exit(-1)
         endif

         if (ph_RESwidth.le.0d0) then
            ph_RESwidth = ph_yLQ**2/(16*pi) * ph_RESmass
         else
            ph_yLQ = sqrt( 16 * pi* ph_RESwidth/ph_RESmass )
            write(*,*) 'yLQ computed from width'
            write(*,*) 'width=',
     1          ph_yLQ**2/(16*pi) * ph_RESmass , ph_RESwidth
         endif
      else
         em_alpha = 1/137.035999084d0
c     No resonances; impose a ktmin
         ph_RESmass = 0
         ph_RESwidth = 0
         kn_ktmin=powheginput("bornktmin")
         if(kn_ktmin<0) then
            write(*,*) ' You must specify a ktmin for this kind of processes!'
            write(*,*) ' Exiting ...'
            call exit(-1)
         endif
      endif

      ph_RESmass2 = ph_RESmass**2
      ph_RESmRESw = ph_RESmass * ph_RESwidth
      
      
c     number of light flavors
      st_nlight = 5

c     mass window
      mass_low = powheginput("#mass_low")
      if (mass_low.lt.0d0) mass_low=1
      mass_high = powheginput("#mass_high")
      if (mass_high.lt.0d0) mass_high=sqrt(kn_sbeams)   

      if(kn_ktmin>0) then
         mass_low = max(mass_low, 2*kn_ktmin)
      endif
      
      ph_RESmass2low=mass_low**2
      ph_RESmass2high=min(kn_sbeams,mass_high**2)

      if( ph_RESmass2low.ge.ph_RESmass2high ) then
         write(*,*) "Error in init_couplings: mass_low >= mass_high"
         call exit(1)
      endif

      if(verbose) then
      write(*,*) '*************************************'
      write(*,*) 'RES mass = ',ph_RESmass
      write(*,*) 'RES width = ',ph_RESwidth
      write(*,*) '*************************************'
      write(*,*)
      write(*,*) '*************************************'
      write(*,*) sqrt(ph_RESmass2low),'< M_Z <',sqrt(ph_RESmass2high)
      write(*,*) '*************************************'
      endif
      end

