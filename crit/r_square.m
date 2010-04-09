%%fonction permettant le calcul de l'erreur R²
%%L. LAURENT   --  22/03/2010   --  luc.laurent@ens-cachan.fr

%%Zex: correspond à l'ensemble des valeurs obtenues par évalutions de la
%%fonction objectif
%%Zap: correspond à l'ensemble des valeurs

function r2=r_square(Zex,Zap)


%permutation du vecteur pour permettre le calcul de MSE
if(size(Zap,1)<size(Zap,2))
Zap=Zap';
end
if(size(Zex,1)<size(Zex,2))
Zex=Zex';
end



MSE=0;
VAR=0;
moy=mean(mean(Zex));
for ii=1:size(Zex,1)
    for jj=1:size(Zex,2)
        MSE=MSE+(Zex(ii,jj)-Zap(ii,jj))^2;
        VAR=VAR+(Zex(ii,jj)-moy)^2;
    end
end

r2=1-MSE/VAR;
end