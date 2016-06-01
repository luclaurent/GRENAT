%% Normalised Peaks function
%L. LAURENT -- 12/05/2010 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016  Luc LAURENT <luc.laurent@lecnam.net>
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

function [p,dp1,dp2]=funPeaksN(xx,yy)
xx=xx*4;
yy=yy*4;
p =  3*(1-xx).^2.*exp(-(xx.^2) - (yy+1).^2) ...
    - 10*(xx/5 - xx.^3 - yy.^5).*exp(-xx.^2-yy.^2) ...
    - 1/3*exp(-(xx+1).^2 - yy.^2);

p=p/7.5;