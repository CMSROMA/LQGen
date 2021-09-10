c     gfortran -ggdb FindWidth.f -ffixed-line-length-none ~/Pheno/POWHEG-BOX-RES/pwhg_bookhist-multi-extra.f ~/Pheno/POWHEG-BOX-RES/pwhg_bookhist-multi.f ~/Pheno/POWHEG-BOX-RES/newunit.f -I ~/Pheno/POWHEG-BOX-RES/include -o FindWidth
c      
      implicit none
      include 'pwhg_bookhist-multi.h'
      character * 200 fname
      integer nbins
      double precision :: x(1:500),y(0:501),er(0:501)
      double precision peak,vpeak,hwidthl,hwidthr
      integer j,icut
      character * 1 cicut
      write(*,*) 'enter file'
      read(*,'(a)') fname
      call pwhgloadhistos(fname)
      do icut=3,3
         nbins=500
         write(cicut,'(i1)') icut
         call pwhggethisto('MmuTau-cut'//cicut//'-zoom',
     1        1,nbins,x,y,er)
         vpeak=0
         do j=1,nbins
            if(y(j)>vpeak) then
               vpeak=y(j)
               peak=(x(j+1)+x(j))/2
            endif
         enddo
         do j=1,nbins
            if(y(j)>vpeak/2) then
               hwidthl=(x(j+1)+x(j))/2
               exit
            endif
         enddo
         do j=nbins,1,-1
            if(y(j)>vpeak/2) then
               hwidthr=(x(j+1)+x(j))/2
               exit
            endif
         enddo
         write(*,*) 'half width ',(hwidthr-hwidthl)/2
c     find efficiencies
         nbins=500
         call pwhggethisto('total',1,nbins,x,y,er)
         write(*,*) 'efficiency ', y(2:nbins)/y(1)
      enddo
      end
      
      
