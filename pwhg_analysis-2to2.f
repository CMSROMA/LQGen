c  The next subroutines, open some histograms and prepare them 
c      to receive data 
c  You can substitute these  with your favourite ones
c  bookup  : opens histograms
c  filld   : fills histograms with data

c  init   :  opens the histograms
c  topout :  closes them
c  pwhgfill  :  fills the histograms with data

      subroutine init_hist
      implicit none
      include  'LesHouches.h'
      include  'pwhg_math.h'
      character * 30 proc
      common/cproc/proc
      real * 8 ptcut
      common/cptcut/ptcut
      real * 8 powheginput
      logical flagsmear
      common/cflagsmear/flagsmear
      logical ptmissh
      common/cptmissh/ptmissh
      integer lqlep
      common/clqlep/lqlep
      call powheginputstring('whichproc',proc)
      if(proc == 'LQumu') then
         lqlep = 13
         if(powheginput('#ingamma')==1) lqlep=-lqlep
      elseif(proc == 'LQue') then
         lqlep = 11
         if(powheginput('#ingamma')==1) lqlep=-lqlep
      endif
      
      flagsmear = .not. (powheginput('#smear') == 0)
      ptmissh   = .not. (powheginput('#ptmissh') == 0)
      call inihists

      if(proc=='emscattering') then
         call bookupeqbins('total',1d0,0d0,14d0)
      elseif(proc == 'LQumu' .or. proc == 'LQue') then
         ptcut=powheginput('LQptcut')
         call bookupeqbins('total',1d0,0d0,2d0)
         call bookupeqbins('mrec0',100d0,0d0,4000d0)
         call bookupeqbins('mrec',10d0,0d0,4000d0)
         call bookupeqbins('mrecz1',50d0,0d0,4000d0)
         call bookupeqbins('mrecz2',100d0,0d0,4000d0)

         call bookupeqbins('mrecLep0',100d0,0d0,4000d0)
         call bookupeqbins('mrecLep',10d0,0d0,4000d0)
         call bookupeqbins('mrecLepz1',50d0,0d0,4000d0)
         call bookupeqbins('mrecLepz2',100d0,0d0,4000d0)

         call bookupeqbins('mrecJet0',100d0,0d0,4000d0)
         call bookupeqbins('mrecJet',10d0,0d0,4000d0)
         call bookupeqbins('mrecJetz1',50d0,0d0,4000d0)
         call bookupeqbins('mrecJetz2',100d0,0d0,4000d0)

         call bookupeqbins("Resy",0.25d0,-5d0,5d0)
      endif

      end


      subroutine analysis(dsig0)
      implicit none
      real * 8 dsig0
      integer, parameter :: maxweights=200
      real * 8 dsig(maxweights)
      include 'hepevt.h'
      include 'pwhg_math.h' 
      include  'LesHouches.h'
      integer, parameter :: maxjet=2048

      logical, save :: ini = .true.

      real * 8 rr,kt(maxjet),eta(maxjet),rap(maxjet),
     1     phi(maxjet),pjet(4,maxjet)
      integer mjets
      
      character * 6 WHCPRG
      common/cWHCPRG/WHCPRG
      data WHCPRG/'NLO   '/

      integer ihep,nlepgams,i1,i2,id1,id2
      integer, parameter :: maxlepgams=500
      integer ilepgam(maxlepgams)
      integer itmp
      integer j
      real * 8 powheginput,y1,eta1,pt1,mass1,y2,eta2,pt2,
     1     mass2,mrec,ptmiss,yjet1,etajet1,ptjet1,massjet1,
     2     yjet2,etajet2,ptjet2,massjet2
      character * 30 proc
      common/cproc/proc
      real * 8 ptcut
      common/cptcut/ptcut
      real * 8 pp1(4),pp2(4),ppjet(4),ppjet2(4),
     1     massofvector,recmass,mreclep,mrecjet,
     2     yresrec,etaresrec,ptresrec
      logical flagsmear
      common/cflagsmear/flagsmear
      integer lqlep
      common/clqlep/lqlep

      if (ini) then
         write (*,*)
         write (*,*) '********************************************'
         if(whcprg.eq.'NLO') then
            write(*,*) '       NLO analysis'
         elseif(WHCPRG.eq.'LHE   ') then
            write(*,*) '       LHE analysis'
         elseif(WHCPRG.eq.'HERWIG') then
            write (*,*) '           HERWIG ANALYSIS            '
            write(*,*) 'not implemented analysis'
            write(*,*) 'no plots will be present at the end of the run'
          elseif(WHCPRG.eq.'PYTHIA') then
            write (*,*) '           PYTHIA ANALYSIS            '
            write(*,*) 'not implemented analysis'
            write(*,*) 'no plots will be present at the end of the run'
         endif
         write(*,*) '*****************************'
         ini=.false.
      endif

      call multi_plot_setup(dsig0,dsig,maxweights)
      
      call filld('total',0.5d0,dsig)

      nlepgams=0
      do ihep=1,nhep
         if(isthep(ihep).eq.1) then
            if(  abs(idhep(ihep)) == 11 .or.
     1           abs(idhep(ihep)) == 13 .or.
     2           abs(idhep(ihep)) == 15 .or.
     3           abs(idhep(ihep)) == 22 ) then
               if(nlepgams<maxlepgams) then
                  nlepgams = nlepgams+1
                  ilepgam(nlepgams)=ihep
               else
                  write(*,*) ' analysis:  too many leptons or photons'
                  write(*,*) ' increase maxlepgams.'
                  write(*,*) ' exiting ...'
                  call exit(-1)
               endif
            endif
         endif
      enddo

c     jet radius
      rr = 0.4d0
      mjets = 10
      call buildjets(1,mjets,rr,kt,eta,rap,phi,pjet)

      
      if(nlepgams>1) call sortbypt(nlepgams,ilepgam(1:nlepgams))

      if(nlepgams > 0) then
         i1 = ilepgam(1)
         pp1 = phep(1:4,i1)
         if(flagsmear) call smearmom(pp1,idhep(i1))
         call getyetaptmass(pp1,y1,eta1,pt1,mass1)
      endif
      if(nlepgams > 1) then
         i2 = ilepgam(2)
         pp2 = phep(1:4,i2)
         if(flagsmear) call smearmom(pp2,idhep(i2))
         call getyetaptmass(pp2,y2,eta2,pt2,mass2)
      endif
      if(proc == 'emscattering' .and. nlepgams>1) then
         if(abs(eta1)<2.4 .and. abs(eta2)<2.4 .and. pt1>20 .and. pt2>20) then
            id1=idhep(i1)
            id2=idhep(i2)
            if(id1*id2<0) then
               id1=abs(id1)
               id2=abs(id2)
               if(id1>id2) then
                  itmp=id1
                  id1=id2
                  id2=itmp
               endif
               if(id1==11) then
                  if(id2==13) then
c     os e mu                  
                     call filld('total',1.5d0,dsig)
                  elseif(id2==15) then
c     os e tau                  
                     call filld('total',2.5d0,dsig)
                  endif
               elseif(id1==13) then
                  if(id2==15) then
                     call filld('total',3.5d0,dsig)
c     os mu tau                  
                  endif
               endif
            elseif(id1*id2>0) then
               id1=abs(id1)
               id2=abs(id2)
               if(id1>id2) then
                  itmp=id1
                  id1=id2
                  id2=itmp
               endif
               if(id1==11) then
                  if(id2==11) then
c     ss el                  
                     call filld('total',4.5d0,dsig)
                  elseif(id2==13) then
c     ss e mu
                     call filld('total',5.5d0,dsig)
                  elseif(id2==15) then
c     ss e tau
                     call filld('total',6.5d0,dsig)
                  endif
               elseif(id1==13) then
                  if(id2==13) then
c     ss mu mu
                     call filld('total',7.5d0,dsig)
                  elseif(id2==15) then
c     ss mu tau
                     call filld('total',8.5d0,dsig)
                  endif
               elseif(id1==15) then
c     ss tau tau
                  call filld('total',9.5d0,dsig)
               endif
            else
               if(id1 == 0) then
                  id1=abs(id2)
                  id2=0
               endif
               if(id1 == 11) then
c     gamma el               
                  call filld('total',10.5d0,dsig)
               elseif(id1==13) then
c     gamma mu
                  call filld('total',11.5d0,dsig)
               elseif(id1==13) then
c     gamma tau
                  call filld('total',12.5d0,dsig)
               endif
            endif
         endif
c*********************************************************
c     LEPTOQUARK
c*********************************************************         
      elseif( (proc == 'LQumu' .or. proc == 'LQue')
     1        .and. ( mjets > 0 .and. nlepgams > 0 )
     2        .and. ( idhep(i1) == lqlep )
     3   ) then
         ppjet=pjet(:,1)
         if(flagsmear) then
            call smearmom(ppjet,2)
         endif
         call getyetaptmass(pp1+ppjet,yresrec,etaresrec,ptresrec,mrec)
         mreclep=recmass(pp1,ppjet)
         mrecjet=recmass(ppjet,pp1)
         call missingpt(ptmiss)

         call filld('Resy',yresrec,dsig)
         call filld('mrec0',mrec,dsig)
         call filld('mrecLep0',mreclep,dsig)
         call filld('mrecJet0',mrecjet,dsig)
         call getyetaptmass(ppjet,yjet1,etajet1,ptjet1,massjet1)
         if(mjets>1) then
            ppjet2=pjet(:,2)
            if(flagsmear) then
               call smearmom(ppjet2,2)
            endif
            call getyetaptmass(ppjet2,yjet2,etajet2,ptjet2,massjet2)
         else
c just so that is out of acceptance
            etajet2=100
         endif

         if(abs(eta1)<2.5 .and. abs(etajet1)<2.5 .and.
     1        pt1>ptcut .and. ptjet1 > ptcut
c     Extra lepton from Zj or ttbar
     2        .and. .not. (nlepgams > 1 .and. idhep(i2) /= 22
     3        .and. pt2>7 .and. abs(eta2)<2.5)
c     This may have little effects on Wj background, but may
c     count for t tbar, etc.
     4        .and. .not. (ptjet2 > 30 .and. abs(etajet2) < 2.5)
     5        .and. ptmiss < 50) then
            call filld('total',1.5d0,dsig)
            call filld('mrec',mrec,dsig)
            call filld('mrecz1',mrec,dsig)
            call filld('mrecz2',mrec,dsig)
            
            call filld('mrecLep',mreclep,dsig)
            call filld('mrecLepz1',mreclep,dsig)
            call filld('mrecLepz2',mreclep,dsig)
            
            call filld('mrecJet',mrecjet,dsig)
            call filld('mrecJetz1',mrecjet,dsig)
            call filld('mrecJetz2',mrecjet,dsig)
         endif
      endif


      end

      function massofvector(p)
      implicit none
      real * 8 massofvector,p(4)
      massofvector = sqrt(p(4)**2-p(1)**2-p(2)**2-p(3)**2)
      end


      function recmass(p1,p2)
      implicit none
      real * 8 recmass,p1(4),p2(4)
      real * 8 pt1,pt2,pp(4)
      real * 8 massofvector
      pt1=sqrt(p1(1)**2+p1(2)**2)
      pt2=sqrt(p2(1)**2+p2(2)**2)
      pp = p2*pt1/pt2
      recmass = massofvector(p1+pp)
c     alternative
c     recmass = 2*sqrt(dotp(p1,pp)**2/(dotp(p2,p2)+2*(dotp(p1,pp)**2)))
      end

      subroutine getyetaptmass(p,y,eta,pt,mass)
      implicit none
      real * 8 p(*),y,eta,pt,mass,pv
      y=0.5d0*log((p(4)+p(3))/(p(4)-p(3)))
      pt=sqrt(p(1)**2+p(2)**2)
      pv=sqrt(pt**2+p(3)**2)
      eta=0.5d0*log((pv+p(3))/(pv-p(3)))
      mass=sqrt(abs(p(4)**2-pv**2))
      end

      subroutine getdydetadphidr(p1,p2,dy,deta,dphi,dr)
      implicit none
      include 'pwhg_math.h' 
      real * 8 p1(*),p2(*),dy,deta,dphi,dr
      real * 8 y1,eta1,pt1,mass1,phi1
      real * 8 y2,eta2,pt2,mass2,phi2
      call getyetaptmass(p1,y1,eta1,pt1,mass1)
      call getyetaptmass(p2,y2,eta2,pt2,mass2)
      dy=y1-y2
      deta=eta1-eta2
      phi1=atan2(p1(1),p1(2))
      phi2=atan2(p2(1),p2(2))
      dphi=abs(phi1-phi2)
      dphi=min(dphi,2d0*pi-dphi)
      dr=sqrt(deta**2+dphi**2)
      end

      subroutine getrapidity(p,y)
      implicit none
      real * 8 p(0:3),y
      y=0.5d0*log((p(0)+p(3))/(p(0)-p(3)))
      end

      subroutine getinvmass(p,m)
      implicit none
      real * 8 p(0:3),m
      m=sqrt(abs(p(0)**2-p(1)**2-p(2)**2-p(3)**2))
      end

      subroutine get_pseudorap(p,eta)
      implicit none
      real*8 p(0:3),eta,pt,th
      real *8 tiny
      parameter (tiny=1.d-5)

      pt=sqrt(p(1)**2+p(2)**2)
      if(pt.lt.tiny.and.abs(p(3)).lt.tiny)then
         eta=sign(1.d0,p(3))*1.d8
      elseif(pt.lt.tiny) then   !: added this elseif
         eta=sign(1.d0,p(3))*1.d8
      else
         th=atan2(pt,p(3))
         eta=-log(tan(th/2.d0))
      endif
      end



      subroutine buildjets(iflag,mjets,rr,kt,eta,rap,phi,pjet)
c     arrays to reconstruct jets, radius parameter rr
      implicit none
      integer iflag,mjets
      real * 8  rr,kt(*),eta(*),rap(*),
     1     phi(*),pjet(4,*)
      include   'hepevt.h'
      include  'LesHouches.h'
      integer   maxtrack,maxjet
      parameter (maxtrack=2048,maxjet=2048)
      real * 8  ptrack(4,maxtrack),pj(4,maxjet)
      integer   jetvec(maxtrack),itrackhep(maxtrack)
      integer   ntracks,njets
      integer   j,k,mu,jb
      real * 8 r,palg,ptmin,pp,tmp
      logical islept
      external islept
C - Initialize arrays and counters for output jets
      do j=1,maxtrack
         do mu=1,4
            ptrack(mu,j)=0d0
         enddo
         jetvec(j)=0
      enddo      
      ntracks=0
      do j=1,maxjet
         do mu=1,4
            pjet(mu,j)=0d0
            pj(mu,j)=0d0
         enddo
      enddo
      if(iflag.eq.1) then
C     - Extract final state particles to feed to jet finder
         do j=1,nhep
            if (isthep(j).eq.1.and..not.islept(idhep(j))) then
               if(ntracks.eq.maxtrack) then
                  write(*,*) 'analyze: need to increase maxtrack!'
                  write(*,*) 'ntracks: ',ntracks
                  stop
               endif
               ntracks=ntracks+1
               do mu=1,4
                  ptrack(mu,ntracks)=phep(mu,j)
               enddo
               itrackhep(ntracks)=j
            endif
         enddo
      else
         do j=1,nup
            if (istup(j).eq.1.and..not.islept(idup(j))) then
               if(ntracks.eq.maxtrack) then
                  write(*,*) 'analyze: need to increase maxtrack!'
                  write(*,*) 'ntracks: ',ntracks
                  stop
               endif
               ntracks=ntracks+1
               do mu=1,4
                  ptrack(mu,ntracks)=pup(mu,j)
               enddo
               itrackhep(ntracks)=j
            endif
         enddo
      endif
      if (ntracks.eq.0) then
         mjets=0
         return
      endif
C --------------------------------------------------------------------- C
C - Inclusive jet pT and Y spectra are to be compared to CDF data:    - C    
C --------------------------------------------------------------------- C
C     R = 0.7   radius parameter
C     f = 0.75  overlapping fraction
c palg=1 is standard kt, -1 is antikt
      palg=-1
      r=rr
c      ptmin=20
      ptmin=0.1d0
      call fastjetppgenkt(ptrack,ntracks,r,palg,ptmin,pjet,njets,
     $                        jetvec)
      mjets=njets
      if(njets.eq.0) return
c check consistency
      do k=1,ntracks
         if(jetvec(k).gt.0) then
            do mu=1,4
               pj(mu,jetvec(k))=pj(mu,jetvec(k))+ptrack(mu,k)
            enddo
         endif
      enddo
      tmp=0
      do j=1,mjets
         do mu=1,4
            tmp=tmp+abs(pj(mu,j)-pjet(mu,j))
         enddo
      enddo
      if(tmp.gt.1d-4) then
         write(*,*) ' bug!'
      endif
C --------------------------------------------------------------------- C
C - Computing arrays of useful kinematics quantities for hardest jets - C
C --------------------------------------------------------------------- C
      do j=1,mjets
         kt(j)=sqrt(pjet(1,j)**2+pjet(2,j)**2)
         pp = sqrt(kt(j)**2+pjet(3,j)**2)
         eta(j)=0.5d0*log((pjet(4,j)+pjet(3,j))/(pjet(4,j)-pjet(3,j)))
         rap(j)=0.5d0*log((pjet(4,j)+pjet(3,j))/(pjet(4,j)-pjet(3,j)))
         phi(j)=atan2(pjet(2,j),pjet(1,j))
      enddo
      end



      subroutine sortbypt(n,iarr)
      implicit none
      integer n,iarr(n)
      include 'hepevt.h'
      integer j,k
      real * 8 tmp,pt(nmxhep)
      logical touched
      do j=1,n
         pt(j)=sqrt(phep(1,iarr(j))**2+phep(2,iarr(j))**2)
      enddo
c bubble sort
      touched=.true.
      do while(touched)
         touched=.false.
         do j=1,n-1
            if(pt(j).lt.pt(j+1)) then
               k=iarr(j)
               iarr(j)=iarr(j+1)
               iarr(j+1)=k
               tmp=pt(j)
               pt(j)=pt(j+1)
               pt(j+1)=tmp
               touched=.true.
            endif
         enddo
      enddo
      end



      function islept(j)
      implicit none
      logical islept
      integer j
      if(abs(j).ge.11.and.abs(j).le.15) then
         islept = .true.
      else
         islept = .false.
      endif
      end


c$$$      subroutine boostx(p_in,pt,ptt,p_out)
c$$$      implicit none
c$$$c--- Boost input vector p_in to output vector p_out using the same
c$$$c--- transformation as required to boost massive vector pt to ptt
c$$$      double precision p_in(4),pt(4),ptt(4),p_out(4),
c$$$     . p_tmp(4),beta(3),mass,gam,bdotp
c$$$      integer j
c$$$
c$$$      mass=pt(4)**2-pt(1)**2-pt(2)**2-pt(3)**2  
c$$$      if (mass .lt. 0d0) then
c$$$        write(6,*) 'mass**2 .lt. 0 in boostx.f, mass**2=',mass,pt
c$$$        stop
c$$$      endif
c$$$      mass=dsqrt(mass)
c$$$
c$$$c--- boost to the rest frame of pt
c$$$      gam=pt(4)/mass
c$$$
c$$$      bdotp=0d0
c$$$      do j=1,3
c$$$        beta(j)=-pt(j)/pt(4)
c$$$        bdotp=bdotp+beta(j)*p_in(j)
c$$$      enddo
c$$$      p_tmp(4)=gam*(p_in(4)+bdotp)
c$$$      do j=1,3
c$$$        p_tmp(j)=p_in(j)+gam*beta(j)/(1d0+gam)*(p_in(4)+p_tmp(4))
c$$$      enddo     
c$$$
c$$$c--- boost from rest frame of pt to frame in which pt is identical
c$$$c--- with ptt, thus completing the transformation          
c$$$      gam=ptt(4)/mass
c$$$
c$$$      bdotp=0d0
c$$$      do j=1,3
c$$$        beta(j)=+ptt(j)/ptt(4)
c$$$        bdotp=bdotp+beta(j)*p_tmp(j)
c$$$      enddo
c$$$      p_out(4)=gam*(p_tmp(4)+bdotp)
c$$$      do j=1,3
c$$$        p_out(j)=p_tmp(j)+gam*beta(j)/(1d0+gam)*(p_out(4)+p_tmp(4))
c$$$      enddo
c$$$
c$$$      return
c$$$      end
      

c$$$c test resten      
c$$$      implicit none
c$$$      real * 8 resten,p1(4),p2(4)
c$$$ 1    continue
c$$$      p1=0
c$$$      p2=0
c$$$      write(*,*) ' enter p1 x, z component'
c$$$      read(*,*) p1(1),p1(3)
c$$$      write(*,*) ' enter p2 z componen'
c$$$      read(*,*) p2(3)
c$$$      p2(1)=-p1(1)
c$$$      p1(4)=sqrt(p1(1)**2+p1(2)**2+p1(3)**2)
c$$$      p2(4)=sqrt(p2(1)**2+p2(2)**2+p2(3)**2)
c$$$      write(*,*) sqrt((p1(4)+p2(4))**2-(p1(1)+p2(1))**2
c$$$     1     -(p1(2)+p2(2))**2-(p1(3)+p2(3))**2)
c$$$      p2=2.345*p2
c$$$      write(*,*) resten(p1,p2)
c$$$      goto 1
c$$$      end
      
      function resten(p1,p2)
      implicit none
      real * 8 resten,p1(4),p2(4),beta,gamma,c1,c2,pt1,pt2
c     take two momenta p1,p2; assuming they are massless,
c     assuming that they are back-to-back in the transverse plane
c     compute the longitudinal boost beta that makes them back to back
      pt1=sqrt(p1(1)**2+p1(2)**2)
      pt2=sqrt(p2(1)**2+p2(2)**2)
      c1=p1(3)/pt1
      c2=p2(3)/pt2
      beta=-(c1+c2)/(sqrt(c1**2+1)+sqrt(c2**2+1))
      gamma=1/sqrt(1-beta**2)
      resten=2*gamma*(p1(4)+beta*p1(3))
      end
      



      subroutine missingpt(ptmiss)
      implicit none
      double precision ptmiss
      double precision ptmissv(2),pp(4)
      logical flagsmear
      common/cflagsmear/flagsmear
      logical ptmissh
      common/cptmissh/ptmissh
      include 'hepevt.h'
      double precision yp,etap,ptp,mass
      integer ihep
      ptmissv = 0
      do ihep=1,nhep
         if(isthep(ihep).eq.1) then
            call getyetaptmass(phep(1:4,ihep),yp,etap,ptp,mass)
            if( ptmissh .and. abs(etap)>2.5 ) cycle
            select case(abs(idhep(ihep)))
            case(12,14,16)
               if(ptmissh) then
                  cycle
               else
                  ptmissv = ptmissv + phep(1:2,ihep)
               endif
            case default
               if(ptmissh) then
                  pp=phep(1:4,ihep)
                  if(flagsmear) then
                     call smearmom(pp,idhep(ihep))
                  endif
                  ptmissv = ptmissv - pp(1:2)
               endif
            end select
         endif
      enddo
      ptmiss=sqrt(ptmissv(1)**2+ptmissv(2)**2)
      end
      
