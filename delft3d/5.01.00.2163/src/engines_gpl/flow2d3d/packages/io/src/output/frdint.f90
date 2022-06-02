subroutine frdint(comfil    ,lundia    ,error     ,ifcore    ,mmax      , &
                & nmax      ,kmaxk     ,nmaxus    ,grpnam    ,nelmx     , &
                & elmnms    ,elmdms    ,elmqty    ,elmunt    ,elmdes    , &
                & elmtps    ,nbytsg    ,funam     ,ntimwa    ,ntimwb    , &
                & atimw     ,btimw     ,func      ,fcom      ,gdp       )
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
!  $Id: frdint.f90 2083 2013-01-02 10:52:35Z ye $
!  $HeadURL: https://svn.oss.deltares.nl/repos/delft3d/tags/5.01.00.2163/src/engines_gpl/flow2d3d/packages/io/src/output/frdint.f90 $
!!--description-----------------------------------------------------------------
!
! Method used:
!
!!--pseudo code and references--------------------------------------------------
! NONE
!!--declarations----------------------------------------------------------------
    use precision
    !
    use globaldata
    !
    implicit none
    !
    type(globdat),target :: gdp
    !
    ! The following list of pointer parameters is used to point inside the gdp structure
    !
!
! Global variables
!
    integer                                                             , intent(in)  :: kmaxk  !!  Number of layers in the z-dir.
                                                                                                !!  For values of func which need a third
                                                                                                !!  dimension, else 1
    integer                                                                           :: lundia !  Description and declaration in inout.igs
    integer                                                             , intent(in)  :: mmax   !  Description and declaration in esm_alloc_int.f90
    integer                                                                           :: nelmx  !!  Number of elements for this group
    integer                                                                           :: nmax   !  Description and declaration in esm_alloc_int.f90
    integer                                                             , intent(in)  :: nmaxus !  Description and declaration in esm_alloc_int.f90
    integer                                                                           :: ntimwa !!  Time index of first function
    integer                                                                           :: ntimwb !!  Time index of second function
    integer, dimension(2)                                               , intent(in)  :: ifcore !!  Time indices (cell id's) of the wave
                                                                                                !!  functions which are in core available
    integer, dimension(6, nelmx)                                                      :: elmdms !  Description and declaration in nefisio.igs
    integer, dimension(nelmx)                                                         :: nbytsg !!  Array containing the number of by-
                                                                                                !!  tes of each single ELMTPS
    logical                                                             , intent(out) :: error  !!  Flag=TRUE if an error is encountered
    real(fp)                                                            , intent(in)  :: atimw  !!  Interpolation factor for first
                                                                                                !!  function
    real(fp)                                                            , intent(in)  :: btimw  !!  Interpolation factor for second
                                                                                                !!  function
    real(fp), dimension(gdp%d%nlb:gdp%d%nub, gdp%d%mlb:gdp%d%mub, kmaxk), intent(out) :: func   !!  Interpolated result
    real(fp), dimension(nmaxus, mmax, kmaxk, 2)                                       :: fcom   !!  The two timesteps, defined by ifcore,
                                                                                                !!  of the function
    character(*)                                                                      :: comfil !!  Name for communication file
                                                                                                !!  com-<case><label>
    character(16), dimension(nelmx)                                                   :: elmunt !!  Array with element physical unit
    character(16)                                                                     :: funam  !!  Name of element which has to be read
    character(16)                                                                     :: grpnam !!  Data-group name defined for the
                                                                                                !!  COM-files (CURTIM)
    character(16), dimension(nelmx)                                                   :: elmnms !!  Element name defined for the COM-files
    character(16), dimension(nelmx)                                                   :: elmqty !!  Array with element quantity
    character(16), dimension(nelmx)                                                   :: elmtps !!  Array containing the types of the
                                                                                                !!  elements (real, ch. , etc. etc.)
    character(64), dimension(nelmx)                                                   :: elmdes !!  Array with element description
!
! Local variables
!
    integer           :: ierr   ! Flag for error when writing to Communication file 
    integer           :: k
    integer           :: m
    integer           :: n
    integer, external :: neferr
    logical           :: wrswch ! Flag to write file .TRUE. : write to  file .FALSE.: read from file 
    character(256)    :: errmsg ! Character var. containing the errormessage to be written to file. The message depends on the error. 
!
!! executable statements -------------------------------------------------------
!
    ! Initialize local variables
    !
    ierr = 0
    wrswch = .false.
    if (ntimwb==0) then
       !
       ! Only one time step on com-file
       !
       ! Read the first timestep from file; all definition and creation
       ! of files, data groups, cells and elements is handled by PUTGTR
       !
       call putgtr(comfil    ,grpnam    ,nelmx     ,elmnms    ,elmdms    , &
                 & elmqty    ,elmunt    ,elmdes    ,elmtps    ,nbytsg    , &
                 & funam     ,ntimwa    ,wrswch    ,ierr      ,fcom(1, 1, 1, 1)     )
       if (ierr/=0) goto 9999
    else
       !
       ! Check if the first required timestep is in core.
       !
       if (ntimwa/=ifcore(1) .and. ntimwa/=ifcore(2)) then
          !
          ! Read the first timestep from file; all definition and creation
          ! of files, data groups, cells and elements is handled by PUTGTR
          !
          call putgtr(comfil    ,grpnam    ,nelmx     ,elmnms    ,elmdms    , &
                    & elmqty    ,elmunt    ,elmdes    ,elmtps    ,nbytsg    , &
                    & funam     ,ntimwa    ,wrswch    ,ierr      ,fcom(1, 1, 1, 1)     )
          if (ierr/=0) goto 9999
       elseif (ntimwa/=ifcore(1) .and. ntimwa==ifcore(2)) then
          !
          ! Copy the second, in core available, time step to the first
          ! position.
          !
          do k = 1, kmaxk
             do m = 1, mmax
                do n = 1, nmaxus
                   fcom(n, m, k, 1) = fcom(n, m, k, 2)
                enddo
             enddo
          enddo
       else
       endif
       !
       ! Check if the second required timestep is in core.
       !
       if (ntimwb/=ifcore(2)) then
          !
          ! Read the second timestep from file; all definition and
          ! creation of files, data groups, cells and elements is handled
          ! by PUTGTR.
          !
          call putgtr(comfil    ,grpnam    ,nelmx     ,elmnms    ,elmdms    , &
                    & elmqty    ,elmunt    ,elmdes    ,elmtps    ,nbytsg    , &
                    & funam     ,ntimwb    ,wrswch    ,ierr      ,fcom(1, 1, 1, 2)     )
          if (ierr/=0) goto 9999
       endif
    endif
    !
    ! Linear interpolation of wave functions
    !
    do k = 1, kmaxk
       do m = 1, mmax
          do n = 1, nmaxus
             func(n, m, k) = atimw*fcom(n, m, k, 1) + btimw*fcom(n, m, k, 2)
          enddo
       enddo
    enddo
 9999 continue
    if (ierr /= 0) then
       ierr = neferr(0, errmsg)
       call prterr(lundia, 'P004', errmsg)
       error = .true.
    endif
end subroutine frdint
