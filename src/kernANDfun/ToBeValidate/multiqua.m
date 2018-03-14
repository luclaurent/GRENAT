%% fonction:  multiquadratics
%L. LAURENT -- 17/01/2012 (r: 31/08/2015) -- luc.laurent@cnam.fr

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

function [G,dG,ddG]=multiqua(xx,para)

% this function is not parametric

%number of output parameters
nbOut=nargout;

%number of sample points
nS=size(xx,1);
%number of design variables
nP=size(xx,2);

lP=1./para;

%compute function value at point xx
td=para.*xx.^2;
fd=1+sum(td,2);
ev=fd.^0.5;

if nbOut==1
    G=ev;
end

%compute first derivatives
if nbOut>1
    %calcul derivees premieres
    dG=-xx./lP.^2.*k;
end

%compute second derivatives
if nbOut>2
    ddG=(xx.^2./lP.^4-1./lP.^2).*k;
end
end

% elseif nbOut==2
%     G=ev;
%     dG=1/para.*xx./repmat(ev,1,nP);
% elseif nbOut==3
%     G=ev;
%     dG=1/para.*xx./repmat(ev,1,nP);   
%     
%     %calcul des derivees secondes    
%     
%     %suivant la taille de l'evaluation demandee on stocke les derivees
%     %secondes de manieres differentes
%     %si on ne demande le calcul des derivees secondes en un seul point, on
%     %les stocke dans une matrice 
%     if nS==1
%         ddG=zeros(nP);
%         for ll=1:nP
%            for mm=1:nP
%                 if(mm==ll)
%                     ddG(mm,ll)=1/para*(1/ev-xx(mm)^2/para.*ev^3);
%                 else
%                     ddG(mm,ll)=-xx(ll)*xx(mm)/(para^2*ev^3);
%                 end
%            end
%         end
%        
%     %si on demande le calcul des derivees secondes en plusieurs point, on
%     %les stocke dans un vecteur de matrices
%     else
%         ddG=zeros(nP,nP,nS);
%         for ll=1:nP
%            for mm=1:nP
%                 if(mm==ll)                    
%                     ddG(mm,ll,:)=1/para.*(1./ev-xx(:,mm).^2./para.*ev.^3);
%                 else
%                     ddG(mm,ll,:)=-xx(:,ll).*xx(:,mm)./(para^2.*ev.^3);
%                 end
%            end
%         end
%         if nP==1
%             ddG=vertcat(ddG(:));
%         end
% 
%     end
%    
%     
% else
%     error('Mauvais argument de sortie de la fonction multiqua.m');
% end