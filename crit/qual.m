%%fonction permettant le calcul de 3 criteres de qualite
%%L. LAURENT   --  22/10/2010   --  luc.laurent@ens-cachan.fr

%%Zex: valeurs de la fonction objectif "exactes" obtenues par simulation
%%Zap: valeurs approchees de la fonction objectif obtenues par le
%%metamodele

function [q1,q2,q3]=qual(Zex,Zap)

%%Calcul des ecarts 
ecart=(Zex-Zap).^2/max(max(Zex.^2));

%Calcul du critere 1 (max des ecarts)
q1=max(ecart(:));

%Calcul du critere 2 (somme des ecarts)
q2=sum(ecart(:));

%calcul du critere 3 (moyenne des ecarts)
q3=q2/(size(Zex,1)*size(Zex,2));