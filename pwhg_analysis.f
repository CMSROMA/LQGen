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
      
      character *9 suffix(3),rsuffix(3)
      common/csuffix/suffix,rsuffix
      integer icut,ircuts
      integer ncuts
      common /ncuts/ncuts


      character * 6 WHCPRG
      common/cWHCPRG/WHCPRG
      
      call inihists

      call bookupeqbins('total',1d0,0d0,1d0)
      call bookupeqbins('y-LQ',0.2d0,-4d0,4d0)   
      call bookupeqbins('m-LQ',20d0,100d0,5000d0)

      call bookupeqbins('pt-lep1',10d0,50d0,2500d0)
      call bookupeqbins('pt-jet1',10d0,50d0,2500d0)
      call bookupeqbins('eta-lep1',0.2d0,-4d0,4d0)
      call bookupeqbins('eta-jet1',0.2d0,-4d0,4d0)

      call bookupeqbins('pt-sys',10d0,50d0,2500d0)
      call bookupeqbins('dphi',0.2d0,0d0,6.4d0)
      call bookupeqbins('dr',0.2d0,0d0,6.4d0)

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

      integer ihep,nleps
      integer ilep(100),iLQ,ijet
      integer itmp
      integer j
      real * 8 pt1,y1,eta1,mass1
      real * 8 pl1(4),ptl1,yl1,etal1,massl1
      real * 8 pl2(4),ptl2,yl2,etal2,massl2
      real * 8 pLQ(4),yLQ,etaLQ,ptLQ,massLQ      
      real * 8 pjet1(4)
      real * 8 powheginput
      integer il1,il2,ih,i,k
      integer,save ::  print_counter=0
      
      real *8 dphi,ptsys,philep1,phijet1,dr
      
      interface 
         subroutine getdphi(p1,p2,dphi,phi1,phi2)
         real(kind=8),intent(in)   :: p1(4),p2(4)
         real(kind=8),intent(out)  :: dphi
         real(kind=8),intent(out),optional :: phi1,phi2
         end subroutine
      end interface

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
         do ihep=1,nhep
            write(*,*) ihep, idhep(ihep), isthep(ihep), phep(1:4,ihep) 
         enddo         
      endif

      call multi_plot_setup(dsig0,dsig,maxweights)

      if (print_counter < 1) then

         write(*,*) '********  Start hep event ********'
         
         do j=1,nhep
            write(*,100)j,isthep(j),idhep(j),jmohep(1,j),
     1           jmohep(2,j),jdahep(1,j),jdahep(2,j), (phep(k,j),k=1,5)
         enddo
         print_counter = print_counter + 1
         write(*,*) '********  End hep event ********'
         
      endif

 100  format(i4,2x,i5,2x,i5,2x,i4,1x,i4,2x,i4,1x,i4,2x,5(d10.4,1x))
      
      nleps=0
      iLQ = 0
      
      do ihep=1,nhep
         
         if(isthep(ihep).eq.1) then
c     the following is no longer necessary for LHE analysis since
c     the LQ always decays to a lepton-jet pair
c$$$            if(  idhep(ihep) == 42 .or. abs(idhep(ihep)) == 9911561
c$$$     1                             .or. abs(idhep(ihep)) == 9921551 ) then
c$$$               iLQ=1
c$$$               pLQ=phep(1:4,ihep)
!     look for leptons in acceptance ( |y_l| < 2.5 )
            if ( abs(idhep(ihep)) == 11 .or.
     1           abs(idhep(ihep)) == 13 .or.
     2           abs(idhep(ihep)) == 15      ) then
               call getyetaptmass(phep(:,ihep),y1,eta1,pt1,mass1)            
               if (abs(y1) .lt. 2.5d0) then 
                  nleps = nleps+1
                  ilep(nleps)=ihep
               endif
            endif
         endif
      enddo
      
      if (nleps<1) return
c     order the leptons in pt 
      call sortbypt(nleps,ilep(1:nleps))
c     pick the hardest lepton
c     so far the selection is charge/flavour blind
      pl1(:) = phep(1:4,ilep(1))
         
c     run jet clustering 
c     jet radius
      rr = 0.4d0
      call buildjets(1,mjets,rr,kt,eta,rap,phi,pjet)

      if (mjets<1) return

      ijet = 0      
c     jets are ordered in pt
      do i = 1,mjets
         if (abs(eta(i)) < 2.5d0) then
            ijet=i
            exit
         endif
      enddo

c     discard the event if there is not jet in the acceptance region
      if (ijet == 0) return
      
c     reconstructed LQ from its decay product      
      pLQ(:) = pjet(:,ijet)+pl1(:)
      
      call filld('total',0.5d0,dsig)
      
      call getyetaptmass(pLQ,yLQ,etaLQ,ptLQ,massLQ)
      call filld('m-LQ',massLQ,dsig)
      call filld('y-LQ',yLQ,dsig)
      
      call getyetaptmass(pl1,yl1,etal1,ptl1,massl1)
      call filld('pt-lep1',ptl1,dsig)
      call filld('eta-lep1',etal1,dsig)
      call filld('pt-jet1',kt(ijet),dsig)
      call filld('eta-jet1',eta(ijet),dsig)

      ptsys = ptl1 + kt(ijet)
      call filld('pt-sys',ptsys,dsig)

      pjet1 = pjet(:,ijet)
      call getdphi(pl1,pjet1,dphi,philep1,phijet1)
      call filld('dphi',dphi,dsig)
      call getdr(etal1,eta(ijet),philep1,phijet1,dr)
      call filld('dr',dphi,dsig)

      end

      subroutine getdr(eta1,eta2,phi1,phi2,dr)
      implicit none
      real(kind=8),intent(in)  :: eta1,eta2,phi1,phi2
      real(kind=8),intent(out) :: dr
      dr = sqrt((eta1-eta2)**2 + (phi1 - phi2)**2)
      end subroutine getdr

      subroutine getdphi(p1,p2,dphi,phi1,phi2)
      implicit none
      include 'pwhg_math.h' 
      real(kind=8),intent(in)   :: p1(4),p2(4)
      real(kind=8),intent(out)  :: dphi
      real(kind=8),intent(out),optional :: phi1,phi2
      real(kind=8) :: phiA, phiB,pt1,pt2

      pt1=sqrt(p1(1)**2+p1(2)**2)
      pt2=sqrt(p2(1)**2+p2(2)**2)
      
      if (p1(2) .ge. 0) then
              phiA = acos(p1(1)/pt1)
      else
              phiA = 2*pi - acos(p1(1)/pt1)
      end if 

      if (p2(2) .ge. 0) then
              phiB = acos(p2(1)/pt2)
      else
              phiB = 2*pi - acos(p2(1)/pt2)
      end if 

      dphi = abs(phiA - phiB)

      if (present(phi1) .and. present(phi2)) then
         phi1 = phiA 
         phi2 = phiB
      end if 
      end subroutine getdphi

      subroutine fillplotcuts(plotname,x,dsig,cuts)
      implicit none
      real *8 x,dsig(*)
      logical cuts(*)
      character *(*) plotname
      character *9 suffix(3),rsuffix(3)
      common/csuffix/suffix,rsuffix
      integer ncuts,icut
      common/ncuts/ncuts      
      
      do icut=1,ncuts
         if(cuts(icut)) call filld(plotname//suffix(icut),x,dsig)
      enddo
      
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
            if (isthep(j).eq.1 .and. .not. (abs(idhep(j))>10
     1           .and. abs(idhep(j))<16) .and. idhep(j) /= 25) then
c               if (isthep(j).eq.1.and..not.islept(idhep(j)).and.idhep(j)/=22) then
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
            if (istup(j).eq.1.and..not.islept(idup(j)).and.idhep(j)/=22) then
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
