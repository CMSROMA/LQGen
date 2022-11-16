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
      real * 8 ptcut,etacut,ptcutjet,ptcutlep,etacutjet,etacutlep,
     1         mLQcuthi,mLQcutlo,phirec
      common/ccuts/ptcut,etacut,ptcutjet,ptcutlep,etacutjet,etacutlep,
     1             mLQcuthi,mLQcutlo,phirec
      real * 8 powheginput
      logical flagsmear
      common/cflagsmear/flagsmear
      logical ptmissh
      common/cptmissh/ptmissh
      integer lqlep
      common/clqlep/lqlep
      logical recombination
      common/crecombination/recombination

      call inihists

      call bookupeqbins('total',1d0,0d0,1d0)

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

      integer ihep,nleps,i1,i2,id1,id2,nphoton
      integer, parameter :: maxleps=500
      integer ilep(maxleps),iphoton(maxleps)
      integer itmp
      integer i,j
      real * 8 powheginput,y1,eta1,pt1,mass1,y2,eta2,pt2,
     1     mass2,mrec,ptmiss,yjet1,etajet1,ptjet1,massjet1,
     2     yjet2,etajet2,ptjet2,massjet2,yleprec,etaleprec,
     3     ptleprec,massleprec,dphileprec,drphoton,
     4     yphoton,etaphoton,ptphoton,massphoton
      character * 30 proc
      common/cproc/proc
      real * 8 ptcut,etacut,ptcutjet,ptcutlep,etacutjet,etacutlep,
     1         mLQcuthi,mLQcutlo,phirec
      common/ccuts/ptcut,etacut,ptcutjet,ptcutlep,etacutjet,etacutlep,
     1             mLQcuthi,mLQcutlo,phirec
      real * 8 pp1(4),pp2(4),ppjet(4),ppjet2(4),pleprec(4),
     1     massofvector,recmass,mreclep,mrecjet,
     2     yresrec,etaresrec,ptresrec
      logical flagsmear
      common/cflagsmear/flagsmear
      integer lqlep
      common/clqlep/lqlep
      logical recombination
      common/crecombination/recombination

      logical dosmear
      common/cdosmear/dosmear
      
      real *8 dphi,ptsys,philep1,phijet1,dr,phiphoton

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

      end subroutine

