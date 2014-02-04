%%fonction permettant le calcul de l'erreur RMAE
%%L. LAURENT   --  22/03/2010   --  luc.laurent@ens-cachan.fr

% Jin 2000 "Comparative Studies Of Metamodeling Techniques under Multiple Modeling Criteria"

%%Zex: valeurs de la fonction objectif "exactes" obtenues par simulation
%%Zap: valeurs approchées de la fonction objectif obtenues par le
%%métamodèle
function rmae=rmae(Zex,Zap)

STD=std(Zap(:));
vec=abs(Zex-Zap);

rmae=max(vec(:))/STD;

end