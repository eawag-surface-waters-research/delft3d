subroutine inittrachy(gdp       )
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
!  $Id: inittrachy.f90 1618 2012-06-19 15:22:02Z ye $
!  $HeadURL: https://svn.oss.deltares.nl/repos/delft3d/tags/5.01.00.2163/src/engines_gpl/flow2d3d/packages/data/src/gdp/inittrachy.f90 $
!!--description-----------------------------------------------------------------
!
! NONE
!
!!--pseudo code and references--------------------------------------------------
! NONE
!!--declarations----------------------------------------------------------------
    use precision
    use globaldata
    !
    implicit none
    !
    type(globdat),target :: gdp
!
! Global variables
!
!! executable statements -------------------------------------------------------
!

    nullify(gdp%gdtrachy%ittaru)
    nullify(gdp%gdtrachy%ittarv)
    nullify(gdp%gdtrachy%ittdef)
    !
    nullify(gdp%gdtrachy%vegh2d)
    nullify(gdp%gdtrachy%vden2d)
    !
    nullify(gdp%gdtrachy%rgcalu)
    nullify(gdp%gdtrachy%rgcalv)
    nullify(gdp%gdtrachy%rttaru)
    nullify(gdp%gdtrachy%rttarv)
    nullify(gdp%gdtrachy%rttdef)
    nullify(gdp%gdtrachy%rttfu)
    nullify(gdp%gdtrachy%rttfv)
    !
    gdp%gdtrachy%flsedprop_rqrd = .false. 
end subroutine inittrachy
