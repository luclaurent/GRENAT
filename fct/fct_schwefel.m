%fonction Schwefel 
%L. LAURENT -- 26/01/2011 -- luc.laurent@ens-cachan.fr

%nombreux minimums locaux
%1 minimum global: x=(1,1,...,1) >> f(x)=0

%domaine d'étude -500<xi<500

function [p,dp1,dp2]=fct_schwefel(xx,yy)

coef=418.9829;

%distinction cas 2D et nD
if nargin==1    %en nD

%donnnees entree: matrice/vecteur
% nombre de colonnes = nombre de variables
% lignes = tirages
nbvar=size(xx,2);

cal=xx.*sin(sqrt(abs(xx)));
p=coef*nbvar-sum(call,2);

if nargout==2
dp1=-sin(sqrt(abs(xx)))-xx.*cos(sqrt(abs(xx))).*sign(xx)./(2*sqrt(abs(xx)));
elseif nargout==3
    error('fonction Schwefel: en dimension n>2, la fonction ne sort que deux elements\n');
elseif nargout>3
    error('fonction Schwefel: trop de parametres de sortie\n');
end

else    %en 2D    
    cal=xx.*sin(sqrt(abs(xx)))+yy.*sin(sqrt(abs(yy)));
    p=coef*2-cal;
    if nargout==2
        error('fonction Schwefel: en dimension 2, la fonction sort trois elements/n');
    elseif nargout==3
        dp1=-sin(sqrt(abs(xx)))-xx.*cos(sqrt(abs(xx))).*sign(xx)./(2*sqrt(abs(xx)));
        dp2=-sin(sqrt(abs(yy)))-yy.*cos(sqrt(abs(yy))).*sign(yy)./(2*sqrt(abs(yy)));
    elseif nargout>3
        error('fonction Schwefel: trop de parametres de sortie\n');
    end
end

