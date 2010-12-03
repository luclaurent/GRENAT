%fonction permettant la construction des intervalles de confiance
% 03/12/2010 -- L. LAURENT -- laurent@lmt.ens-cachan.fr

%paramétre d'entrée (prédiction métamodèle et variance
%sortie intervalles de confiance à 68%, 95% et 99%
function [ic68,ic95,ic99]=const_ic(ZZ,var)

%a 68%
ic68.sup=ZZ+sqrt(mse);
ic68.inf=ZZ-mse;
%a 95%
if nargout>=2
    ic95.sup=ZZ+2*mse;
    ic95.inf=ZZ-2*mse;
end
%a 99,7%
if nargout==2
    ic99.sup=ZZ+3*mse;
    ic99.inf=ZZ-3*mse;
end