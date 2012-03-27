%%fonction permettant le calcul de l'erreur MSE
%%L. LAURENT   --  22/03/2010   --  luc.laurent@ens-cachan.fr

%%Zex: correspond a  l'ensemble des valeurs obtenues par evalutions de la
%%fonction objectif
%%Zap: correspond a  l'ensemble des valeurs

function emse=mse_p(Zex,Zap)

diff=(Zex-Zap).^2;
MSE=sum(diff(:));
emse=1/numel(Zex)*MSE;
end