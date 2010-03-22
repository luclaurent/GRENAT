%%fonction permettant le calcul de l'erreur MSE
%%L. LAURENT   --  22/03/2010   --  luc.laurent@ens-cachan.fr

%%Zex: correspond à l'ensemble des valeurs obtenues par évalutions de la
%%fonction objectif
%%Zap: correspond à l'ensemble des valeurs

function emse=mse(Zex,Zap)


MSE=0;
for ii=1:size(Zex,1)
    for jj=1:size(Zex,2)
        MSE=MSE+(Zex(ii,jj)-Zap(ii,jj))^2;
    end
end

emse=MSE;
end