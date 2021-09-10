      subroutine init_processes
      implicit none
      include 'nlegborn.h'
      include 'pwhg_flst.h'
      include 'pwhg_kn.h'
      include 'LesHouches.h'
      include 'pwhg_physpar.h'
      include 'pwhg_st.h'
      include 'pwhg_pdf.h'
      integer id1,id2,j,k,j1,j2,j3,j4
      logical debug
      parameter (debug=.false.)
      real * 8 powheginput
      external powheginput
c     lepton masses
      real *8 lepmass(3),decmass
      common/clepmass/lepmass,decmass
      logical condition
      real * 8 cmass, bmass
      character * 30 proc
      common/cproc/proc
      real * 8 emampsq
      integer idmap(-9:9)/-15,-13,-11,-6,-5,-4,-3,-2,-1,22,
     1     1,2,3,4,5,6,11,13,15/                  
      
      pdf_nparton=22
c     Set here lepton and quark masses for momentum reshuffle in the LHE event file
      do j=1,st_nlight         
         physpar_mq(j)=0d0
      enddo
      do j=1,3
         physpar_ml(j)=lepmass(j)
      enddo
c     read eventual c and b masses from the input file
      cmass=powheginput("#cmass_lhe")
      if (cmass.gt.0d0) physpar_mq(4)=cmass
      bmass=powheginput("#bmass_lhe")
      if (bmass.gt.0d0) physpar_mq(5)=bmass

      call powheginputstring('whichproc',proc)

      flst_nborn=0
      flst_bornres = 0
      if(proc == 'mu-tau-mu-tau') then
*********************************************************************
***********            BORN SUBPROCESSES              ***************
*********************************************************************
         flst_nborn=flst_nborn+1
         flst_born(:,flst_nborn)=(/  13, -15,  13,-15 /)
         flst_nborn=flst_nborn+1
         flst_born(:,flst_nborn)=(/ -15,  13, -15, 13 /)
         flst_nborn=flst_nborn+1
         flst_born(:,flst_nborn)=(/ -13,  15, -13, 15 /)
         flst_nborn=flst_nborn+1
         flst_born(:,flst_nborn)=(/  15, -13,  15, -13 /)
         flst_nborn=flst_nborn+1
         flst_born(:,flst_nborn)=(/  13, -15,  15, -13 /)
         flst_nborn=flst_nborn+1
         flst_born(:,flst_nborn)=(/ -15,  13, -13,  15 /)
         flst_nborn=flst_nborn+1
         flst_born(:,flst_nborn)=(/ -13,  15, -15,  13 /)
         flst_nborn=flst_nborn+1
         flst_born(:,flst_nborn)=(/  15, -13,  13, -15 /)
      endif
      if(proc == 'emscattering' ) then
*********************************************************************
***********            BORN SUBPROCESSES              ***************
*********************************************************************
         do j1=-9,9
            do j2=-9,9
               do j3=-9,9
                  do j4= j3,9
c     Only possibilities:
                     if(.not. (
     1                    (j1==j3 .and. j2==j4) .or.
     2                    (j1==j4 .and. j2==j3) .or.
     3                    (j1==-j2 .and. j3==-j4) ) .or.
     4                    (j1==0 .and. j2==0) .or. (j3==0 .and. j4==0)) cycle
                     if(powheginput("#lepalepdiff")==1 .and. .not. (abs(j1)>6.and. j1==-j2
     1                    .and. abs(j3)>6 .and. j3==-j4 .and. abs(j1) /= abs(j3)) ) then
                        cycle
                     endif
                     if(powheginput("#leptonlepton")==1 .and.
     1                    (abs(j1)<7.or.abs(j2)<7.or.abs(j3)<7 .or.abs(j4)<7) ) then
                        cycle
                     endif
                     if(powheginput("#leptongamma")==1 .and. .not.
     1                    ( (j1 == 0 .and. abs(j2)>6) .or. (j2 == 0 .and. abs(j1)>6) )) then
                        cycle
                     endif
                     if(powheginput("#leptonquark")==1 .and. .not.
     1                    ( (abs(j1) > 6 .and. (j2 /= 0 .and. abs(j2)<7) ) .or.
     2                      (abs(j2) > 6 .and. (j1 /= 0 .and. abs(j1)<7) ) ) ) then
                        cycle
                     endif
                     flst_nborn=flst_nborn+1
                     flst_born(:,flst_nborn)=(/  idmap(j1), idmap(j2),  idmap(j3), idmap(j4) /)
                  enddo
               enddo
            enddo
         enddo
      endif

      if(proc == 'LQumu') then
         flst_nborn=flst_nborn+1
         flst_born(:,flst_nborn)=(/  2, 13,  2, 13 /)
         flst_nborn=flst_nborn+1
         flst_born(:,flst_nborn)=(/  13, 2,  2, 13 /)
      endif

      if(proc == 'LQue') then
         flst_nborn=flst_nborn+1
         flst_born(:,flst_nborn)=(/  2, 11,  2, 11 /)
         flst_nborn=flst_nborn+1
         flst_born(:,flst_nborn)=(/  11, 2,  2, 11 /)
      endif

      if(flst_nborn>maxprocborn) then
         write(*,*) ' init_processes: number of born=',flst_nborn,
     1    ' > maxprocborn=',maxprocborn,' fix nlegborn.h'
         call exit(-1)
      endif
      
*********************************************************************
***********REAL SUBPROCESSES              ***************
*********************************************************************
      flst_nreal=0
      return
 998  write(*,*) 'init_processes: increase maxprocreal'
      stop
 999  write(*,*) 'init_processes: increase maxprocborn'
      stop
      end
 

      block data lepmass_data
      real *8 lepmass(3),decmass
      common/clepmass/lepmass,decmass
      data lepmass /0.51099891d-3,0.1056583668d0,1.77684d0/
      end
