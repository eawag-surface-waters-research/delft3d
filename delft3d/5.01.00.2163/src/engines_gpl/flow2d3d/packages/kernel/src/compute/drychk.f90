subroutine drychk(idry      ,s1        ,qxk       ,qyk       ,icx       , &
                & icy       ,dps       ,kfu       ,kfv       ,kfs       , &
                & j         ,nmmaxj    ,nmmax     ,kmax      ,nfltyp    , &
                & excbed    ,kcs       ,gdp       )
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
!  $Id: drychk.f90 1977 2012-11-15 16:54:06Z ye $
!  $HeadURL: https://svn.oss.deltares.nl/repos/delft3d/tags/5.01.00.2163/src/engines_gpl/flow2d3d/packages/kernel/src/compute/drychk.f90 $
!!--description-----------------------------------------------------------------
!
!    Function: This subroutine checks for drying in water level
!              points. In case the point is dry, all surrounding
!              mask arrays (KFU and KFV) are set to zero and sub-
!              sequently SUD computation will be repeated
! Method used:
!
!!--pseudo code and references--------------------------------------------------
! NONE
!!--declarations----------------------------------------------------------------
    use precision
    use globaldata
    use dfparall
    !
    implicit none
    !
    type(globdat),target :: gdp
    !
    ! The following list of pointer parameters is used to point inside the gdp structure
    !
    logical      , pointer :: sedim
    logical      , pointer :: mudlay
    real(fp)     , pointer :: cbed
    real(fp)     , pointer :: hdt
!
! Global variables
!
    integer                                         , intent(in)  :: icx    !!  Increment in the X-dir., if ICX= NMAX then computation proceeds in the X-dir. If icx=1 then computation proceeds in the Y-dir.
    integer                                        , intent(in)  :: icy    !!  Increment in the Y-dir. (see ICX)
    integer                                                       :: idry   !!  Flag set to 1 if a dry point is detected in routine DRYCHK after SUD is completed
    integer                                                       :: j      !!  Begin pointer for arrays which have been transformed into 1D arrays. Due to the shift in the 2nd (M-) index, J = -2*NMAX + 1
    integer                                        , intent(in)  :: kmax   !  Description and declaration in esm_alloc_int.f90
    integer                                        , intent(in)  :: nfltyp !  Description and declaration in esm_alloc_int.f90
    integer                                        , intent(in)  :: nmmax  !  Description and declaration in dimens.igs
    integer                                                      :: nmmaxj !  Description and declaration in dimens.igs
    integer, dimension(gdp%d%nmlb:gdp%d%nmub)      , intent(in)  :: kcs    !  Description and declaration in esm_alloc_int.f90
    integer, dimension(gdp%d%nmlb:gdp%d%nmub)      , intent(out) :: kfs    !  Description and declaration in esm_alloc_int.f90
    integer, dimension(gdp%d%nmlb:gdp%d%nmub)                    :: kfu    !  Description and declaration in esm_alloc_int.f90
    integer, dimension(gdp%d%nmlb:gdp%d%nmub)                    :: kfv    !  Description and declaration in esm_alloc_int.f90
    real(prec), dimension(gdp%d%nmlb:gdp%d%nmub)                 :: dps    !  Description and declaration in esm_alloc_real.f90
    real(fp), dimension(gdp%d%nmlb:gdp%d%nmub)      , intent(in)  :: excbed !  Description and declaration in esm_alloc_real.f90
    real(fp), dimension(gdp%d%nmlb:gdp%d%nmub)      , intent(in)  :: s1     !  Description and declaration in esm_alloc_real.f90
    real(fp), dimension(gdp%d%nmlb:gdp%d%nmub, kmax), intent(out) :: qxk    !  Description and declaration in esm_alloc_real.f90
    real(fp), dimension(gdp%d%nmlb:gdp%d%nmub, kmax), intent(out) :: qyk    !  Description and declaration in esm_alloc_real.f90
!
! Local variables
!
    integer       :: k
    integer       :: lungrd
    integer       :: n
    integer       :: m
    integer       :: ndm
    integer       :: nm
    integer       :: nmd
    character(18) :: tmpname
    integer       :: nm_pos ! indicating the array to be exchanged has nm index at the 2nd place, e.g., dbodsd(lsedtot,nm)
!
!! executable statements -------------------------------------------------------
!
    hdt        => gdp%gdnumeco%hdt
    cbed       => gdp%gdmudcoe%cbed
    sedim      => gdp%gdprocs%sedim
    mudlay     => gdp%gdprocs%mudlay
    !
    idry   = 0
    nm_pos = 1
    if (nfltyp/=0) then
       do nm = 1, nmmax
          if ( (kcs(nm)==1 .or. kcs(nm)==2) ) then
          nmd = nm - icx
          ndm = nm - icy
             if (       ( kfu(nm)==1 .or. kfu(nmd)==1 ) &
                 & .or. ( kfv(nm)==1 .or. kfv(ndm)==1 )  ) then
             if ( s1(nm) <= -real(dps(nm),fp) ) then
                kfu(nm) = 0
                kfu(nmd) = 0
                kfv(nm) = 0
                kfv(ndm) = 0
                idry = 1
                do k = 1, kmax
                  qxk(nm, k) = 0.0
                  qxk(nm - icx, k) = 0.0
                  qyk(nm, k) = 0.0
                  qyk(nm - icy, k) = 0.0
                enddo
             endif
          endif
          endif
       enddo
       !
       ! determine global maximum of 'idry' over all nodes
       ! Note: this enables to synchronize the repeating computation of SUD
       !
       call dfreduce( idry, 1, dfint, dfmax, gdp )
     endif
    !
    ! CHECK FOR FOUR DRY VELOCITY POINTS
    !
    do nm = 1, nmmax
       !
       ! correction due to vectorisation
       !
       if (kfu(nm)==99) kfu(nm) = 0
       !
       if (kcs(nm)>0) then
          nmd = nm - icx
          ndm = nm - icy
          kfs(nm) = max(kfu(nm), kfu(nmd), kfv(nm), kfv(ndm))
       endif
    enddo
    call dfexchg ( kfs, 1,    1, dfint, nm_pos, gdp )
    do nm = 1, nmmax
       nmd = nm - icx
       ndm = nm - icy
       if (kfs(nm)==0 .and. kcs(nm)/=0) then
          kfu(nm)  = 0
          kfu(nmd) = 0
          kfv(nm)  = 0
          kfv(ndm) = 0
       endif
    enddo
    !
    ! exchange kfu, kfv, qxk and qyk with neighbours for parallel runs
    !
    call dfexchg ( kfu, 1,    1, dfint , nm_pos, gdp )
    call dfexchg ( kfv, 1,    1, dfint , nm_pos, gdp )
    call dfexchg ( qxk, 1, kmax, dfloat, nm_pos, gdp )
    call dfexchg ( qyk, 1, kmax, dfloat, nm_pos, gdp )
    !
    ! Re-define bottom by adding erosion / sedimentation
    ! Only for IDRY=0 or NFLTYP=0 and if mudlay == .true.
    !
    if ((nfltyp*idry==0) .and. mudlay) then
       do nm = 1, nmmax
          if (kcs(nm)==1) then
             dps(nm) = dps(nm) - real(hdt*excbed(nm)/cbed,prec)
          endif
       enddo
       call dfexchg ( dps, 1, 1, dfprec, nm_pos, gdp )
    endif
end subroutine drychk
