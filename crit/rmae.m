%%fonction permettant le calcul de l'erreur RMAE
%%L. LAURENT   --  22/03/2010   --  luc.laurent@ens-cachan.fr

%%Zex: valeurs de la fonction objectif "exactes" obtenues par simulation
%%Zap: valeurs approchées de la fonction objectif obtenues par le
%%métamodèle
function rmae=rmae(Zex,Zap)

STD=std(Zex(:));
vec=abs(Zex-Zap);

rmae=max(max(vec))/STD;

end