%% function for calculating Normalized MSE
%L. LAURENT   --  09/11/2018   --  luc.laurent@lecnam.net
%
%Zex: "exact" values of the function obtained by simulation
%Zap: approximated values given by the surrogate model

%     GRENAT - GRadient ENhanced Approximation Toolbox 
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016-2017  Luc LAURENT <luc.laurent@lecnam.net>
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

function enmse=calcNMSE(Zex,Zap)

%mean exact
mZex=mean(Zex);
diffZex=(mZex-Zex).^2;
sumZex=sum(diffZex(:));
%
diff=(Zex-Zap).^2;
MSE=sum(diff(:));
%
enmse=1/numel(Zex)*MSE./sumZex;
end
