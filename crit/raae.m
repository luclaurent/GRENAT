%%fonction permettant le calcul de l'erreur RAAE
%%L. LAURENT   --  22/03/2010   --  luc.laurent@ens-cachan.fr

%%Zex: correspond à l'ensemble des valeurs obtenues par évalutions de la
%%fonction objectif
%%Zap: correspond à l'ensemble des valeurs
function raae=raae(Zex,Zap)

for kk=1:size(Zex,1)^2
    vv(kk)=Zex(kk);
end
STD=std(vv);
ECA=0;
for ii=1:size(Zex,1)
    for jj=1:size(Zex,2)
        ECA=ECA+abs(Zex(ii,jj)-Zap(ii,jj));  
    end
end

raae=ECA/(size(Zex,1)*STD);

end