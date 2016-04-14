%fonction permettant la construction des intervalles de confiance
% 03/12/2010 -- L. LAURENT -- luc.laurent@lecnam.net

%parametre d'entree (prediction metamodele et variance)
%sortie intervalles de confiance a 68%, 95% et 99%
function [ic68,ic95,ic99]=const_ic(ZZ,var)

%probleme de variance negative (pb numerique)
v=abs(var);

%a 68%
ic68.sup=ZZ+sqrt(v);
ic68.inf=ZZ-sqrt(v);
%a 95%
if nargout>=2
    ic95.sup=ZZ+2*sqrt(v);
    ic95.inf=ZZ-2*sqrt(v);
end
%a 99,7%
if nargout==3
    ic99.sup=ZZ+3*sqrt(v);
    ic99.inf=ZZ-3*sqrt(v);
end