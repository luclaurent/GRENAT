%% fonction:  multiquadratics
%L. LAURENT -- 17/01/2012 (r: 31/08/2015) -- luc.laurent@cnam.fr

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

function [G,dG,ddG]=multiqua(xx,long)

%Cette fonction est non paramétrique

%nombre de points a evaluer
pt_eval=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);

%calcul de la valeur de la fonction au point xx
td=xx.^2;
fd=1+sum(td,2);
ev=fd.^0.5;

if nargout==1
    G=ev;
elseif nargout==2
    G=ev;
    dG=1/long.*xx./repmat(ev,1,nb_comp);
elseif nargout==3
    G=ev;
    dG=1/long.*xx./repmat(ev,1,nb_comp);   
    
    %calcul des derivees secondes    
    
    %suivant la taille de l'evaluation demandee on stocke les derivees
    %secondes de manieres differentes
    %si on ne demande le calcul des derivees secondes en un seul point, on
    %les stocke dans une matrice 
    if pt_eval==1
        ddG=zeros(nb_comp);
        for ll=1:nb_comp
           for mm=1:nb_comp
                if(mm==ll)
                    ddG(mm,ll)=1/long*(1/ev-xx(mm)^2/long.*ev^3);
                else
                    ddG(mm,ll)=-xx(ll)*xx(mm)/(long^2*ev^3);
                end
           end
        end
       
    %si on demande le calcul des derivees secondes en plusieurs point, on
    %les stocke dans un vecteur de matrices
    else
        ddG=zeros(nb_comp,nb_comp,pt_eval);
        for ll=1:nb_comp
           for mm=1:nb_comp
                if(mm==ll)                    
                    ddG(mm,ll,:)=1/long.*(1./ev-xx(:,mm).^2./long.*ev.^3);
                else
                    ddG(mm,ll,:)=-xx(:,ll).*xx(:,mm)./(long^2.*ev.^3);
                end
           end
        end
        if nb_comp==1
            ddG=vertcat(ddG(:));
        end

    end
   
    
else
    error('Mauvais argument de sortie de la fonction multiqua.m');
end