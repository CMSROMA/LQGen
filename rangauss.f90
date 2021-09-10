program test
  implicit none
  integer j
  call inihists
  call bookupeqbins('gaus',0.05d0,-5d0,5d0)
  do j=1,10000
     call filld('gaus',rangauss(),1d0/10000)
     call pwhgaccumup
  enddo

  call pwhgsetout
  call pwhgtopout('gaus')

contains

  function rangauss() result(res)
    implicit none
    real * 8 res,r2,theta,v1,v2
    real * 8, parameter :: pi=3.141592653589793d0
    call random_number(v1)
    call random_number(v2)
    r2=-2*log(v1)
    theta=2*pi*v2
    res = sqrt(r2)*sin(theta)
    if(abs(res)>4) then
       ! we limit to no more than 4 standard deviations (we never know)
       res=0
    endif
  end function rangauss

end program test

