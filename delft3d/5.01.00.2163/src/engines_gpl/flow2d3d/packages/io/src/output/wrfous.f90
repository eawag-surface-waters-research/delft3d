subroutine wrfous(nmax      ,mmax      ,nmaxus    ,kmax      ,lmax      , &
                & nofou     ,ifou      ,lunfou    ,dtsec     ,namcon    , &
                & kcs       ,xz        ,yz        ,xcor      ,ycor      , &
                & kfu       ,kfv       ,itdate    ,gdp       )
!----- GPL ---------------------------------------------------------------------
!                                                                               
!  Copyright (C)  Stichting Deltares, 2011-2012.                                
!                                                                               
!  This program is free software: you can redistribute it and/or modify         
!  it under the terms of the GNU General Public License as published by         
!  the Free Software Foundation version 3.                                      
!                                                                               
!  This program is distributed in the hope that it will be useful,              
!  but WITHOUT ANY WARRANTY; without even the implied warranty of               
!  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                
!  GNU General Public License for more details.                                 
!                                                                               
!  You should have received a copy of the GNU General Public License            
!  along with this program.  If not, see <http://www.gnu.org/licenses/>.        
!                                                                               
!  contact: delft3d.support@deltares.nl                                         
!  Stichting Deltares                                                           
!  P.O. Box 177                                                                 
!  2600 MH Delft, The Netherlands                                               
!                                                                               
!  All indications and logos of, and references to, "Delft3D" and "Deltares"    
!  are registered trademarks of Stichting Deltares, and remain the property of  
!  Stichting Deltares. All rights reserved.                                     
!                                                                               
!-------------------------------------------------------------------------------
!  $Id: wrfous.f90 1180 2012-01-13 17:05:48Z mourits $
!  $HeadURL: https://svn.oss.deltares.nl/repos/delft3d/tags/5.01.00.2163/src/engines_gpl/flow2d3d/packages/io/src/output/wrfous.f90 $
!!--description-----------------------------------------------------------------
!
!    Function: - writes results of fourier analysis to output
!                file lunfou for scalair quantities
!
!!--pseudo code and references--------------------------------------------------
! NONE
!!--declarations----------------------------------------------------------------
    use precision
    use mathconsts
    use globaldata
    !
    implicit none
    !
    type(globdat),target :: gdp
    !
    ! The following list of pointer parameters is used to point inside the gdp structure
    !
    integer        , dimension(:)        , pointer :: fconno
    integer        , dimension(:)        , pointer :: flayno
    integer        , dimension(:)        , pointer :: fnumcy
    integer        , dimension(:)        , pointer :: ftmsto
    integer        , dimension(:)        , pointer :: ftmstr
    integer                              , pointer :: iblwl
    integer                              , pointer :: iblcn
    real(fp)       , dimension(:)        , pointer :: fknfac
    real(fp)       , dimension(:)        , pointer :: foufas
    real(fp)       , dimension(:,:,:)    , pointer :: fousma
    real(fp)       , dimension(:,:,:)    , pointer :: fousmb
    real(fp)       , dimension(:)        , pointer :: fv0pu
    character(1)   , dimension(:)        , pointer :: fouelp
    character(16)  , dimension(:)        , pointer :: founam
    real(fp)                             , pointer :: tzone
    real(fp)                             , pointer :: hdt
!
! Global variables
!
    integer                                                              , intent(in) :: ifou   !!  Fourier counter
    integer                                                                           :: itdate !  Reference time in YYYYMMDD
    integer                                                              , intent(in) :: kmax   !  Description and declaration in esm_alloc_int.f90
    integer                                                              , intent(in) :: lmax   !  Description and declaration in dimens.igs
    integer                                                              , intent(in) :: lunfou !!  Unit number fourier output file
    integer                                                              , intent(in) :: mmax   !  Description and declaration in esm_alloc_int.f90
    integer                                                                           :: nmax   !  Description and declaration in esm_alloc_int.f90
    integer                                                              , intent(in) :: nmaxus !  Description and declaration in esm_alloc_int.f90
    integer                                                              , intent(in) :: nofou  !  Description and declaration in dimens.igs
    integer       , dimension(gdp%d%nlb:gdp%d%nub, gdp%d%mlb:gdp%d%mub)  , intent(in) :: kcs    !  Description and declaration in esm_alloc_int.f90
    integer       , dimension(gdp%d%nlb:gdp%d%nub, gdp%d%mlb:gdp%d%mub)  , intent(in) :: kfu    !  Description and declaration in esm_alloc_int.f90
    integer       , dimension(gdp%d%nlb:gdp%d%nub, gdp%d%mlb:gdp%d%mub)  , intent(in) :: kfv    !  Description and declaration in esm_alloc_int.f90
    real(fp)                                                             , intent(in) :: dtsec  !!  Integration time step [in seconds]
    real(fp)      , dimension(gdp%d%nlb:gdp%d%nub, gdp%d%mlb:gdp%d%mub)  , intent(in) :: xcor   !  Description and declaration in esm_alloc_real.f90
    real(fp)      , dimension(gdp%d%nlb:gdp%d%nub, gdp%d%mlb:gdp%d%mub)  , intent(in) :: xz     !  Description and declaration in esm_alloc_real.f90
    real(fp)      , dimension(gdp%d%nlb:gdp%d%nub, gdp%d%mlb:gdp%d%mub)  , intent(in) :: ycor   !  Description and declaration in esm_alloc_real.f90
    real(fp)      , dimension(gdp%d%nlb:gdp%d%nub, gdp%d%mlb:gdp%d%mub)  , intent(in) :: yz     !  Description and declaration in esm_alloc_real.f90
    character(20) , dimension(lmax)                                      , intent(in) :: namcon !  Description and declaration in esm_alloc_char.f90
!
! Local variables
!
    integer                   :: m            ! Loop counter over MMAX 
    integer                   :: n            ! Loop counter over NMAXUS 
    integer                   :: ncol         ! Number of column to write to TEKAL data file 
    logical                   :: ltest        ! Help variable for atan2 function test 
    real(fp)                  :: amp          ! Fourier amplitude 
    real(fp)                  :: defaul       ! Default value 
    real(fp)                  :: fas          ! Fourier phase 
    real(fp)                  :: freqnt       ! Frequency in degrees per hour 
    real(fp)                  :: shift        ! Phase shift 
    real(fp)                  :: tfasto       ! Stop time in minutes 
    real(fp)                  :: tfastr       ! Start time in minutes 
    character(20)             :: namfun       ! Local name for fourier function 
    character(4)              :: blnm
!
!
!! executable statements -------------------------------------------------------
!
!
    fconno        => gdp%gdfourier%fconno
    flayno        => gdp%gdfourier%flayno
    fnumcy        => gdp%gdfourier%fnumcy
    iblwl         => gdp%gdfourier%iblwl
    iblcn         => gdp%gdfourier%iblcn
    ftmsto        => gdp%gdfourier%ftmsto
    ftmstr        => gdp%gdfourier%ftmstr
    fknfac        => gdp%gdfourier%fknfac
    foufas        => gdp%gdfourier%foufas
    fousma        => gdp%gdfourier%fousma
    fousmb        => gdp%gdfourier%fousmb
    fv0pu         => gdp%gdfourier%fv0pu
    fouelp        => gdp%gdfourier%fouelp
    founam        => gdp%gdfourier%founam
    tzone         => gdp%gdexttim%tzone
    hdt           => gdp%gdnumeco%hdt
    !
    !-----Initialize local variables
    !
    defaul = 999.999_fp
    !
    !-----Frequention := 360 degree / period
    !     where period = [ (FTMSTO - FMTSTR) * DTSEC ] / [ FNUMCY * 3600 ]
    !     FOUFAS is defined in RDFOUR as
    !     FOUFAS =  2 * PI * FNUMCY / [(FTMSTO - FMTSTR) ]
    !     so FREQNT = FOUFAS * RADDEG * 3600 / DTSEC is OK
    !
    shift = ftmstr(ifou)*foufas(ifou)
    freqnt = foufas(ifou)*raddeg*3600.0_fp/dtsec
    tfastr = real(ftmstr(ifou),fp)*dtsec/60.0_fp
    tfasto = real(ftmsto(ifou),fp)*dtsec/60.0_fp
    !
    namfun = founam(ifou)
    if (founam(ifou)(:2)=='s1') then
       iblwl = iblwl + 1
       blnm = 'WL??'
       write (blnm(3:4), '(i2.2)') iblwl
       namfun = 'water level'
    endif
    if (founam(ifou)(:2)=='r1') then
       iblcn = iblcn + 1
       blnm = 'CO??'
       write (blnm(3:4), '(i2.2)') iblcn
       namfun = namcon(fconno(ifou))
    endif
    !
    !-----Write information to "TEKAL" data file
    !
    write (lunfou, '(a,a16)') '* Results fourier analysis on: ', namfun
    !
    if (kmax>1) then
       write (lunfou, '(a,i3)') '* Layer number               : ', flayno(ifou)
    endif
    !
    write (lunfou, '(a,i0   )') '* Reference date in YYYYMMDD : ', itdate
    write (lunfou, '(a,f12.3)') '* Starttime fourier analysis : ', tfastr
    write (lunfou, '(a,f12.3)') '* Stoptime  fourier analysis : ', tfasto
    write (lunfou, '(a,i6   )') '* Number of cycles           : ', fnumcy(ifou)
    write (lunfou, '(a,f12.6)') '* Frequency [degrees/hour]   : ', freqnt
    !
    write (lunfou, '(a     )') '*'
    write (lunfou, '(a     )') '* Block definition:'
    !
    !-----For GPP: description in columns 17 to 37
    !
    write (lunfou, '(a     )') '* column    1 : X-coor, zeta point'
    write (lunfou, '(a     )') '* column    2 : Y-coor, zeta point'
    write (lunfou, '(a     )') '* column    3 : X-coor, depth point'
    write (lunfou, '(a     )') '* column    4 : Y-coor, depth point'
    write (lunfou, '(a     )') '* column    5 : M-index '
    write (lunfou, '(a     )') '* column    6 : N-index '
    if (fouelp(ifou)=='x') then
       ncol = 10
       write (lunfou, '(a     )') '* column    7 : Maximum value'
       write (lunfou, '(a     )') '* column    8 : KCS'
       write (lunfou, '(a     )') '* column    9 : KFU'
       write (lunfou, '(a     )') '* column   10 : KFV'
    elseif (fouelp(ifou)=='i') then
       ncol = 10
       write (lunfou, '(a     )') '* column    7 : Minimum value'
       write (lunfou, '(a     )') '* column    8 : KCS'
       write (lunfou, '(a     )') '* column    9 : KFU'
       write (lunfou, '(a     )') '* column   10 : KFV'
    else
       ncol = 11
       write (lunfou, '(a     )') '* column    7 : Fourier amplitude'
       write (lunfou, '(a     )') '* column    8 : Fourier phase'
       write (lunfou, '(a     )') '* column    9 : KCS'
       write (lunfou, '(a     )') '* column   10 : KFU'
       write (lunfou, '(a     )') '* column   11 : KFV'
    endif
    !
    !-----Write Block code and data to "TEKAL" data file
    !     Frequency is shown in GPP (20 characters total)
    !
    write (lunfou, '(a4,a5,f11.6)') blnm, ' freq', freqnt
    write (lunfou, '(4i8)') mmax*nmaxus, ncol, mmax, nmaxus
    !
    !-----Write data for user defined dimensions, hence NMAXUS and MMAX
    !     First for Maximum or Minimum
    !
    if (fouelp(ifou)=='x' .or. fouelp(ifou)=='i') then
       do n = 1, nmaxus
          do m = 1, mmax
             !
             !-----------Test for active points
             !           when KCS (N,M) = 1 N > 1 and M > 1 per definition
             !
             if (kcs(n, m)==1) then
                write (lunfou,'(4(f12.3,1x),2(i5,1x),  e14.6E3,1x ,3(i2,1x))') &
                    & xz(n, m), yz(n, m), xcor(n, m), ycor(n, m), m, n,        &
                    & fousma(n, m, ifou), kcs(n, m), kfu(n, m), kfv(n, m)
             !
             else
                !
                !--------------Inactive point (not inside grid, can be open boundary)
                !              defaul instead of xz/yz needed for GPP
                !              '0' instead of kcs, because TEKAL does not accept '2'
                !
                write (lunfou,'(4(f12.3,1x),2(i5,1x),  f14.3,1x ,3(i2,1x))')   &
                    & defaul, defaul, xcor(n, m), ycor(n, m), m, n, defaul, 0, &
                    & kfu(n, m), kfv(n, m)
             endif
          enddo
       enddo
    else
       !
       !-----Write data for user defined dimensions, hence NMAXUS and MMAX
       !
       do n = 1, nmaxus
          do m = 1, mmax
             ltest = (fousma(n, m, ifou)==0.0_fp .and. fousmb(n, m, ifou)==0.0_fp)
             !
             !-----------Test for active point and non-zero values
             !           when KCS (N,M) = 1 N > 1 and M > 1 per definition
             !
             if (kcs(n, m)==1 .and. .not.ltest) then
                fousma(n, m, ifou) = fousma(n, m, ifou)                         &
                                   & *2.0_fp/(real(ftmsto(ifou) - ftmstr(ifou),fp))
                fousmb(n, m, ifou) = fousmb(n, m, ifou)                         &
                                   & *2.0_fp/(real(ftmsto(ifou) - ftmstr(ifou),fp))
                amp = sqrt(fousma(n, m, ifou)*fousma(n, m, ifou)                &
                    & + fousmb(n, m, ifou)*fousmb(n, m, ifou))
                fas = atan2(fousmb(n, m, ifou), fousma(n, m, ifou)) + shift
                if (fnumcy(ifou)==0) then
                   amp = 0.5_fp*amp*cos(fas)
                   fas = 0.0_fp
                endif
                !
                ! Timezone correction added timezone*phase [degrees/hr].
                ! foufas       is in [rad/timestep]
                ! halftimestep is in [sec/timestep]
                ! => timezonecorr = tzone [-] * foufas [rad/timestep] * raddeg [deg/rad] * [sec/hr] / (2 * halftimestep [sec/timestep])
                !
                fas = fas*raddeg + fv0pu(ifou) - tzone*foufas(ifou)*raddeg*1800.0_fp/hdt
                !
                ! To define FAS between 0 and 360. add 720. to the MOD of
                !  FAS and re-use the MOD function
                !
                fas = mod(mod(fas, 360.0_fp) + 720.0_fp, 360.0_fp)
                amp = amp/fknfac(ifou)
                write (lunfou,'(4(f12.3,1x),2(i5,1x),2(e14.6E3,1x),3(i2,1x))') &
                    & xz(n, m), yz(n, m), xcor(n, m), ycor(n, m), m, n, amp,   &
                    & fas, kcs(n, m), kfu(n, m), kfv(n, m)
             else
                !
                !--------------Inactive point (not inside grid, can be open boundary)
                !              defaul instead of xz/yz needed for GPP
                !              '0' instead of kcs, because TEKAL does not accept '2'
                !
                write (lunfou,'(4(f12.3,1x),2(i5,1x),2(f14.3,1x),3(i2,1x))') &
                    & defaul, defaul, xcor(n, m), ycor(n, m), m, n, defaul,  &
                    & defaul, 0, kfu(n, m), kfv(n, m)
             endif
          enddo
       enddo
    endif
end subroutine wrfous
