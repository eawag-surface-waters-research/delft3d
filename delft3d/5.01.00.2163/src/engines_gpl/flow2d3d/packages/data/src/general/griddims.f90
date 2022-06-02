subroutine griddims( gdp )
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
!  $Id: griddims.f90 1180 2012-01-13 17:05:48Z mourits $
!  $HeadURL: https://svn.oss.deltares.nl/repos/delft3d/tags/5.01.00.2163/src/engines_gpl/flow2d3d/packages/data/src/general/griddims.f90 $
!!--description-----------------------------------------------------------------
!
!    Function: Initialises grid related dimensions
!              This routine is introduced with the implementation
!              of DD boundaries
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
    integer      , pointer :: nmax
    integer      , pointer :: mmax
    integer      , pointer :: nlb
    integer      , pointer :: nub
    integer      , pointer :: mlb
    integer      , pointer :: mub
    integer      , pointer :: nmlb
    integer      , pointer :: nmub
    integer      , pointer :: ddbound
    integer      , pointer :: jstart
    integer      , pointer :: nmmaxj
    integer      , pointer :: nmmax
    integer      , pointer :: numdomains
    integer      , pointer :: nummappers
!
! Global variables
!
!
!
! Local variables
!
!
!
!! executable statements -------------------------------------------------------
!
    nmax         => gdp%d%nmax
    mmax         => gdp%d%mmax
    nlb          => gdp%d%nlb
    nub          => gdp%d%nub
    mlb          => gdp%d%mlb
    mub          => gdp%d%mub
    nmlb         => gdp%d%nmlb
    nmub         => gdp%d%nmub
    ddbound      => gdp%d%ddbound
    jstart       => gdp%d%jstart
    nmmaxj       => gdp%d%nmmaxj
    nmmax        => gdp%d%nmmax
    numdomains   => gdp%gdprognm%numdomains
    nummappers   => gdp%gdprognm%nummappers
    !
    ! basic dimensions:
    ! nmmax  = mmax   *   nmax
    ! nmmaxj = nmmax  + 2*nmax
    ! jstart = 1      - 2*nmax
    !
    !
    ! Probably, ddbound can be 0 when numdomains=1, nummappers>=1
    ! For safety, ddbound is always 1 when nummappers>=1
    !
    ! ddbound is expected to be able to be 0 when parll
    ! Unfortunately, it must be 1
    !
    if (nummappers>=1 .or. parll) then
       gdp%d%ddbound = 1
    else
       gdp%d%ddbound = 0
    endif
    gdp%d%nlb  = 1 - gdp%d%ddbound
    gdp%d%nub  = nmax + gdp%d%ddbound
    gdp%d%mlb  = -1 - gdp%d%ddbound
    gdp%d%mub  = mmax + 2 + gdp%d%ddbound
    nmmax      = (mmax + 2*gdp%d%ddbound)*(nmax + 2*gdp%d%ddbound)
    jstart     = 1 - 2*(nmax + 2*gdp%d%ddbound)
    nmmaxj     = nmmax + 2*(nmax + 2*gdp%d%ddbound)
    gdp%d%nmlb = jstart
    gdp%d%nmub = nmmaxj
end subroutine griddims
