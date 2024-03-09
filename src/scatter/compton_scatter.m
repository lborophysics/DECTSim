function [ndir, nnrj] = compton_scatter(direction, inrj, thetas, phis)
   % This function simulates the Compton scattering of a photon with
   % initial energy "inrj" and direction "direction", using the thetas provided
   % as the scattering angles. The function returns new direction and 
   % the energy of the scattered particle. 

   % Initialize some constants
   sin_theta = sin(thetas);
   cos_theta = cos(thetas);

   change_frame = false;
   if abs(direction(3)) == max(abs(direction))
      change_frame = true;
      direction = roty(pi/2) * direction;
   end

   ndir = rotateUz(direction, sin_theta, cos_theta, phis);
   if change_frame; ndir = roty(-pi/2) * ndir; end

   nnrj = ((constants.me_c2 .* inrj) ./ (constants.me_c2 + inrj .* (1 - cos_theta)));
end

function u = rotateUz(u, sin_theta, cos_theta, phis)
    % Sourced from CLHEP:
    % https://apc.u-paris.fr/~franco/g4doxy4.10/html/_three_vector_8cc_source.html#l00072
    u1 = u(1); u2 = u(2); u3 = u(3);
    up = u1*u1 + u2*u2;
    u = zeros(3, length(phis));

    if up > 0 % Not sure this if statement is necessary
        up = sqrt(up);
        px = sin_theta.*cos(phis); 
        py = sin_theta.*sin(phis);
        pz = cos_theta;
        u(1, :) = (u1.*u3.*px - u2.*py)./up + u1.*pz;
        u(2, :) = (u2.*u3.*px + u1.*py)./up + u2.*pz;
        u(3, :) = -up.*px + u3.*pz;
    elseif u3 < 0
        u(1) = -u(1);
        u(3) = -u(3);  % phi=0  theta=pi
    end
end


%{
Geant4 Software License
Version 1.0, 28 June 2006

Copyright (c) Copyright Holders of the Geant4 Collaboration, 1994-2006.
See http://cern.ch/geant4/license for details on the copyright holders.  All
rights not expressly granted under this license are reserved.

This software includes voluntary contributions made to Geant4.
See http://cern.ch/geant4 for more information on Geant4.

Installation, use, reproduction, display, modification and redistribution of
this software, with or without modification, in source and binary forms, are
permitted on a non-exclusive basis. Any exercise of rights by you under this
license is subject to the following conditions:

1. Redistributions of this software,  in whole or in part,  with  or without
   modification, must reproduce the above copyright notice and these license
   conditions  in  this  software,  the  user  documentation  and  any other
   materials provided with the redistributed software.

2. The user documentation,if any,included with a redistribution,must include
   the following notice:"This product includes software developed by Members
   of the Geant4 Collaboration ( http://cern.ch/geant4 )."
   If that  is  where  third-party  acknowledgments  normally  appear,  this
   acknowledgment  must  be  reproduced  in  the  modified  version  of this
   software itself.

3. The names "Geant4" and "The Geant4 toolkit" may not be used to endorse or
   promote software,or products derived therefrom, except with prior written
   permission  by  license@geant4.org.  If this software is redistributed in
   modified form,  the name  and  reference of  the modified version must be
   clearly distinguishable from that of this software.

4. You are under no obligation to provide anyone with  any  modifications of
   this software that you may develop,including but not limited to bug fixes,
   patches,  upgrades  or  other enhancements or derivatives of the features,
   functionality or performance of this software. However, if you publish or
   distribute your modifications without  contemporaneously  requiring users
   to enter into a separate written license agreement,  then  you are deemed
   to have granted all  Members  and all  Copyright Holders  of  the  Geant4
   Collaboration  a license to your  modifications,  including modifications
   protected by any patent owned by you,under the conditions of this license.

5. You may not include  this  software in  whole or in part in any patent or
   patent  application  in  respect  of  any  modification  of this software
   developed by you.


6. DISCLAIMER

 THIS SOFTWARE IS PROVIDED BY THE MEMBERS AND COPYRIGHT HOLDERS OF THE GEANT4
 COLLABORATION AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 INCLUDING,  BUT NOT LIMITED TO,  IMPLIED WARRANTIES OF  MERCHANTABILITY,  OF
 SATISFACTORY QUALITY,  AND FITNESS  FOR  A  PARTICULAR PURPOSE  OR  USE  ARE
 DISCLAIMED. THE MEMBERS OF THE GEANT4 COLLABORATION AND CONTRIBUTORS MAKE NO
 REPRESENTATION THAT THE SOFTWARE AND MODIFICATIONS THEREOF,WILL NOT INFRINGE
 ANY PATENT, COPYRIGHT, TRADE SECRET OR OTHER PROPRIETARY RIGHT.

7. LIMITATION OF LIABILITY

 THE  MEMBERS  AND  COPYRIGHT   HOLDERS  OF  THE   GEANT4  COLLABORATION  AND
 CONTRIBUTORS SHALL HAVE NO LIABILITY FOR DIRECT,INDIRECT,SPECIAL, INCIDENTAL,
 CONSEQUENTIAL,  EXEMPLARY,  OR PUNITIVE DAMAGES  OF  ANY CHARACTER INCLUDING,
 WITHOUT LIMITATION, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES, LOSS OF USE,
 DATA OR PROFITS,  OR BUSINESS INTERRUPTION, HOWEVER CAUSED AND ON ANY THEORY
 OF CONTRACT,  WARRANTY, TORT  (INCLUDING NEGLIGENCE),  PRODUCT LIABILITY  OR
 OTHERWISE,  ARISING IN  ANY WAY  OUT OF THE USE  OF  THIS SOFTWARE,  EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

8. This license  shall terminate with immediate effect and without notice if
   you  fail  to  comply with any  of  the terms of this license,  or if you
   institute litigation against any Member or Copyright Holder of the Geant4
   Collaboration with regard to this software.
%}