      subroutine setborn(p,bflav,born,bornjk,bmunu)
      implicit none
      include 'pwhg_math.h'
      include 'nlegborn.h'
      include 'pwhg_flst.h'
      include 'RES.h'
      character * 30 proc
      common/cproc/proc
      
      integer nlegs
      parameter (nlegs=nlegborn)
      real * 8 p(0:3,nlegs),bornjk(nlegs,nlegs)
      integer bflav(nlegs)
      real * 8 bmunu(0:3,0:3,nlegs),bbmunu(0:3,0:3),born
      integer j,k,mu,nu
      real * 8 s,omcth,opcth,den,dotp,emampsq,gamma
c Colour factors for colour-correlated Born amplitudes;
c     Rule from 2.98 in FNO2007, leads to B_i j=B* C_i
      if(proc == 'mu-tau-mu-tau') then
         s=2*dotp(p(:,1),p(:,2))
         omcth=4*dotp(p(:,1),p(:,3))/s
         opcth=4*dotp(p(:,1),p(:,4))/s
         born=(omcth**2*(ph_gr**4+ph_gl**4)+2*opcth**2*ph_gr**2*ph_gl**2)*s**2
c     Denominator
         den=(s-ph_RESmass2)**2+ph_RESmRESw**2
c     Denominator, spin average and flux factor
         born = born/den/4
      elseif(proc == 'LQumu' .or. proc == 'LQue') then
         s=2*dotp(p(:,1),p(:,2))
         den=(s-ph_RESmass2)**2+ph_RESmRESw**2
         gamma=ph_RESwidth
         born = 4*pi*(gamma**2/den)       
c     the numerator is s*ph_RESmass2, which near the resonance is an approximation for s**2;
c     it might be better to restore s**2, as given by a tree-level computation, since
c     it provides a stronger suppresion away from the resonance
c     (no need for a mass window near the resonance)
         born = born * s/ph_RESmass2
c     the above includes the decay phase space. We should divide it out
         born = born/(1/(8*pi))
c     the 1/(2s) factor is provided by powheg, compensate for that
         born = born * 2*s         
      elseif(proc == 'emscattering' .or. proc == 'leptonscattering' ) then
         born = emampsq(bflav,p)
      endif
      bmunu=0
      bbmunu=0
      end


      subroutine borncolour_lh
c Sets up the colour for the given flavour configuration
c already filled in the Les Houches interface.
c In case there are several colour structure, one
c should pick one with a probability proportional to
c the value of the corresponding cross section, for the
c kinematics defined in the Les Houches interface
      implicit none
      character * 30 proc
      common/cproc/proc
      include 'LesHouches.h'
      include 'nlegborn.h'
      include 'pwhg_flst.h'
      integer j
c     neutral particles
      icolup(:,1:4)=0
      if(proc == 'LQumu' .or. proc == 'LQue'  ) then
         do j=1,4
            if(abs(idup(j))>0 .and. abs(idup(j))<7) then
               if(idup(j)>0) then
                  icolup(1,j)=501
               else
                  icolup(2,j)=501
               endif
            endif
         enddo
      endif
      end


      subroutine finalize_lh
c     Set up the resonances whose mass must be preserved
c     on the Les Houches interface.
c     
c     lepton masses
      include 'LesHouches.h'
      real *8 lepmass(3),decmass
      common/clepmass/lepmass,decmass
c     Resonance Z -> e-(3) e+(4)
      real * 8 powheginput
      logical, save :: ini=.true., ingamma
      character * 30 proc
      common/cproc/proc
      integer j
      if(ini) then
c     replace incoming leptons with photons
         ingamma=powheginput("#ingamma") == 1
         ini=.false.
      endif
      if(ingamma) then
         do j=1,2
            if(abs(idup(j))>7) then
               idup(j)=22
            endif
         enddo
      endif
      if(proc=='mu-tau-mu-tau') then
         call add_resonance(23,3,4)
      elseif(proc=='LQumu' .or. proc=='LQue') then
c         call add_resonance(42,3,4)    
         call add_resonance(9911561,3,4)  ! match herwig number scheme for LQ
         icolup(:,3)=icolup(:,1)+icolup(:,2)
c     fix quark flavour to conserve charge if the incoming lepton has been replaced by a photon
         if(ingamma) then
            do j=4,5
               if(idup(j)==2) idup(j)=1
               if(idup(j)==11) idup(j)=-11
            enddo
         endif
      endif

c$$$c     The following routine also performs the reshuffling of momenta if
c$$$c     a massive decay is chosen
c$$$      call momenta_reshuffle(3,4,5,decmass)
      call lhefinitemasses
      end



c     i1<i2
      subroutine momenta_reshuffle(ires,i1,i2,decmass)
      implicit none
      include 'LesHouches.h'
      integer ires,i1,i2,j
      real * 8 ptemp(0:3),ptemp1(0:3),beta(3),betainv(3),modbeta,decmass
      if (i1.ge.i2) then
         write(*,*) 'wrong sequence in momenta_reshuffle'
         stop
      endif
cccccccccccccccccccccccccccccc
c construct boosts from/to vector boson rest frame 
      do j=1,3
         beta(j)=-pup(j,ires)/pup(4,ires)
      enddo
      modbeta=sqrt(beta(1)**2+beta(2)**2+beta(3)**2)
      do j=1,3
         beta(j)=beta(j)/modbeta
         betainv(j)=-beta(j)
      enddo
cccccccccccccccccccccccccccccccccccccccc
c first decay product 
      ptemp(0)=pup(4,i1)
      do j=1,3
         ptemp(j)=pup(j,i1)
      enddo
      call mboost(1,beta,modbeta,ptemp,ptemp)
      ptemp1(0)=0.5d0*pup(5,ires)
      do j=1,3
         ptemp1(j)=ptemp(j)/ptemp(0)*sqrt(ptemp1(0)**2 -decmass**2)
      enddo
      call mboost(1,betainv,modbeta,ptemp1,ptemp)
      do j=1,3
         pup(j,i1)=ptemp(j)
      enddo
      pup(4,i1)=ptemp(0)
c abs to avoid tiny negative values in case of neutrinos
      pup(5,i1)=sqrt(abs(pup(4,i1)**2-pup(1,i1)**2
     $     -pup(2,i1)**2-pup(3,i1)**2))
      
c second decay product 

      ptemp(0)=pup(4,i2)
      do j=1,3
         ptemp(j)=pup(j,i2)
      enddo
      call mboost(1,beta,modbeta,ptemp,ptemp)
      ptemp1(0)=0.5d0*pup(5,ires)
      do j=1,3
         ptemp1(j)=ptemp(j)/ptemp(0)*sqrt(ptemp1(0)**2 -decmass**2)
      enddo
      call mboost(1,betainv,modbeta,ptemp1,ptemp)
      do j=1,3
         pup(j,i2)=ptemp(j)
      enddo
      pup(4,i2)=ptemp(0)
c abs to avoid tiny negative values in case of neutrinos
      pup(5,i2)=sqrt(abs(pup(4,i2)**2-pup(1,i2)**2
     $     -pup(2,i2)**2-pup(3,i2)**2))
cccccccccccccccccccccccccccccccccccccccc
      end



      function emampsq(flav,p)
      implicit none
      integer flav(4)
      double precision emampsq,p(0:3,4)
      integer fl(4),itmp
      double precision p1(0:3),p2(0:3),p3(0:3),p4(0:3),tmp(0:3)
      double precision s,t,u
      double precision chargeofid
      include 'pwhg_em.h'
      include 'pwhg_math.h'
      fl=flav
      p1=p(:,1)
      p2=p(:,2)
      p3=p(:,3)
      p4=p(:,4)
      if(fl(1) == 22 .and. fl(2) /= 22) then
c     we want the photon to be 2
         itmp = fl(2)
         fl(2) = fl(1)
         fl(1) = itmp
         tmp = p2
         p2 = p1
         p1 = tmp
      endif
      if(fl(1) == fl(4) .and. fl(3) /= fl(4)) then
c     we want 1 and 3 to be the same quark, if possible         
         itmp = fl(3)
         fl(3) = fl(4)
         fl(4) = itmp
         tmp = p3
         p3 = p4
         p4 = tmp
      endif
      s = sq(p1+p2)
      t = sq(p1-p3)
      u = sq(p1-p4)
      if(fl(2) == 22 .and. fl(1) /=22) then
c     l g -> l g
         if(fl(1).ne.fl(3).or.fl(4).ne.22) goto 999
         emampsq = (u**2+s**2)/(s**2*u)
         emampsq = emampsq * chargeofid(fl(1))**4
      elseif(abs(fl(1)) /= abs(fl(2)) ) then
c     Scattering of different leptons
         if(fl(1) .ne. fl(3) .or. fl(2) .ne. fl(4)) goto 999
         emampsq = (u**2+s**2)/(s*t**2)
         emampsq = emampsq * ( chargeofid(fl(1))*chargeofid(fl(2)) )**2
      elseif(fl(1)==fl(2).and.fl(1)==fl(3).and.fl(1)==fl(4)) then
c     Scattering of equal leptons
         emampsq =
     1    (2*((u**2+s**2)/t**2+(t**2+s**2)/u**2)+(4*s**2)/(t*u))/s/4
         emampsq = emampsq * chargeofid(fl(1))**4
      elseif(fl(1)+fl(2)==0 .and. fl(3)+fl(4)==0) then
         if(fl(1) /= fl(3)) then
c q qbar into different q qbar
            emampsq = (u**2+t**2)/s**3
            emampsq = emampsq * chargeofid(fl(1))**4
         else
c q qbar into same q qbar
            emampsq =
     1    (2*((u**2+t**2)/s**2+(u**2+s**2)/t**2)+(4*u**2)/(s*t))/s/2
            emampsq =
     1       emampsq * ( chargeofid(fl(1))*chargeofid(fl(3)) )**2
         endif
      else
         goto 999
      endif
c     POWHEG supplies the 1/(2s) factor.
      emampsq = emampsq * (2 * s) * (4*pi*em_alpha)**2
      
      return
 999  continue
      write(*,*) ' unforseen flavour structure:',flav
      call exit(-1)
      contains
      double precision function sq(p) result(res)
      double precision p(0:3)
      res = p(0)**2 - p(1)**2 - p(2)**2 - p(3)**2
      end function sq
      end
      
