%%fonction permettant le calcul de l'erreur R2
%%L. LAURENT   --  22/03/2010   --  luc.laurent@ens-cachan.fr

%%Zex: correspond a l'ensemble des valeurs obtenues par evalutions de la
%%fonction objectif
%%Zap: correspond a l'ensemble des valeurs

function r2=r_square(Zex,Zap)

moy=mean(Zex(:));

Zdiff2=(Zex-Zap).^2;
Zdiffm=(Zex-repmat(moy,size(Zex,1),size(Zex,2))).^2;

MSE=sum(Zdiff2(:));
VAR=sum(Zdiffm(:));
r2=1-MSE/VAR;

end