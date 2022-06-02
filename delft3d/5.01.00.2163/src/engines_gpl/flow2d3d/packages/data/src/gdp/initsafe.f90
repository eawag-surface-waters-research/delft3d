subroutine initsafe(gdp)
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
!  $Id: initsafe.f90 1848 2012-09-14 17:42:05Z mourits $
!  $HeadURL: https://svn.oss.deltares.nl/repos/delft3d/tags/5.01.00.2163/src/engines_gpl/flow2d3d/packages/data/src/gdp/initsafe.f90 $
!!--description-----------------------------------------------------------------
!
! NONE
!
!!--pseudo code and references--------------------------------------------------
! NONE
!!--declarations----------------------------------------------------------------
    use precision
    use sp_buffer
    use message_module
    use bedcomposition_module
    !
    use globaldata
    !
    implicit none
    !
    type(globdat),target :: gdp
    !
    integer :: istat
!
!! executable statements -------------------------------------------------------
!
    istat = 0
    call tree_create("Delft3D-FLOW input", gdp%input_tree)
    nullify (gdp%mdfile_ptr)
    !
    call initadv2d     (gdp)
    call initbcdat     (gdp)
    call initbedformpar(gdp)
    call initbubble    (gdp)
    call initcline     (gdp)
    call initculver    (gdp)
    call initcoup      (gdp)
    call initdischarge (gdp)
    call initdefsub    (gdp)
    call initdpmveg    (gdp)
    call initdredge    (gdp)
    call initeqtran    (gdp)
    call initerosed    (gdp)
    call initf0isf1    (gdp)
    call initflwpar    (gdp)
    call initfmtbcc    (gdp)
    call initfmtbct    (gdp)
    call initfmtdis    (gdp)
    call initfourier   (gdp)
    call initheat      (gdp)
    call inithwid      (gdp)
    call initincbc     (gdp)
    call initincbcc    (gdp)
    call initincwav    (gdp)
    call initkeywtd    (gdp)
    call initmassbal   (gdp)
    call initmorpar    (gdp)
    call initsedpar    (gdp)
    call initstack     (gdp%messages)
    istat = initmorlyr (gdp%gdmorlyr)
    call initpostpr    (gdp)
    call initrestart   (gdp)
    call initprocs     (gdp)
    call initrtc       (gdp)
    call initscour     (gdp)
    call initsnel      (gdp)
    call initsobek     (gdp)
    call initstations  (gdp)
    call inittimers    (gdp)
    call inittrachy    (gdp)
    call inittrisol    (gdp)
    call initupdbcc    (gdp)
    call initupdbct    (gdp)
    call initupddis    (gdp)
    call initu_ppr     (gdp)
    call initwaqpar    (gdp)
    call initwrirst    (gdp)
    call initwrline    (gdp)
    call initz_initcg  (gdp)
    call initzmodel    (gdp)
    !
    call sbuff_init
    !
    ! Delft3D-MOR
    !
    call initcrvout    (gdp)
    !
    call initdfparall  (gdp) 
    ! 
    ! Since GDP allocation has not yet succeeded, I can't call prterr(...,gdp) and d3stop(...)
    !
    if (istat /= 0) then
       write(*,*) 'ERROR during initialization of GDP structure'
       stop 1
    endif
end subroutine initsafe
