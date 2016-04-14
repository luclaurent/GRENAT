%%fonction permettant le calcul de l'erreur RMSE
%%L. LAURENT   --  10/02/2012   --  luc.laurent@lecnam.net

%%Zex: correspond a  l'ensemble des valeurs obtenues par evalutions de la
%%fonction objectif
%%Zap: correspond a  l'ensemble des valeurs

function rmse=rmse_p(Zex,Zap)

diff=(Zex-Zap).^2;
MSE=sum(diff(:));
rmse=sqrt(1/(size(Zex,1)*size(Zex,2))*MSE);
end