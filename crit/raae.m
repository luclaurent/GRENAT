%%fonction permettant le calcul de l'erreur RAAE
%%L. LAURENT   --  22/03/2010   --  luc.laurent@ens-cachan.fr

%%Zex: correspond à l'ensemble des valeurs obtenues par évalutions de la
%%fonction objectif
%%Zap: correspond à l'ensemble des valeurs
function raae=raae(Zex,Zap)


%permutation du vecteur pour permettre le calcul de ECA
if(size(Zap,1)<size(Zap,2))
Zap=Zap';
end
if(size(Zex,1)<size(Zex,2))
Zex=Zex';
end

hh=1;

for kk=1:size(Zex,1)
    for ll=1:size(Zex,2)
        vv(hh)=Zex(kk,ll);
        hh=hh+1;
    end
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