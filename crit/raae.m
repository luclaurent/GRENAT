%%fonction permettant le calcul de l'erreur RAAE
%%L. LAURENT   --  22/03/2010   --  luc.laurent@ens-cachan.fr

%%Zex: correspond a  l'ensemble des valeurs obtenues par evalutions de la
%%fonction objectif
%%Zap: correspond a  l'ensemble des valeurs
function raae=raae(Zex,Zap)

STD=std(Zex(:));
vec=abs(Zex-Zap);
ECA=sum(vec(:));


raae=ECA/(size(Zex,1)*size(Zex,2)*STD);

end