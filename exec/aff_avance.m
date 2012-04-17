%% procédure d'affichage d'avancement
%% L. LAURENT -- 06/03/2012 -- laurent@lmt.ens-cachan.fr

function aff_avance(situation,fin)

if nargin>=2
   fprintf('%i %i%s',situation,floor(situation/fin),char(37)) 
else
    fprintf('%i%s',situation)
end