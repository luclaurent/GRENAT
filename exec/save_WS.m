%% Sauvegarde du Workspace
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function save_WS(dossier,nom)

if nargin == 1
    nomfich=[dossier '/WS.mat'];
elseif nargin == 2
    nomfich=[dossier '/' nom];
else
    error('Mauvais nombre de paramètres\n');
end

save(nomfich)
