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

moy=mean(mean(Zex));

Zdiff2=(Zex-Zap).^2;
Zdiffm=(Zex-repmat(moy,size(Zex,1),size(Zex,2))).^2;

MSE=sum(Zdiff2,1);
VAR=sum(Zdiffm,1);
r2=1-MSE/VAR;

end