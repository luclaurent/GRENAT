%%fonction permettant le calcul de 3 critères de qualité
%%L. LAURENT   --  22/10/2010   --  luc.laurent@ens-cachan.fr

%%Zex: valeurs de la fonction objectif "exactes" obtenues par simulation
%%Zap: valeurs approchées de la fonction objectif obtenues par le
%%métamodèle

function [q1,q2,q3]=qual(Zex,Zap)

%permutation du vecteur pour concordance des dimensions
if(size(Zap,1)<size(Zap,2))
Zap=Zap';
end
if(size(Zex,1)<size(Zex,2))
Zex=Zex';
end


%%Calcul des écarts 
ecart=(Zex-Zap).^2/max(max(Zex));

%Calcul du critère 1 (max des écarts)
q1=max(max(ecart));

%Calcul du critère 2 (somme des écarts)
q2=sum(ecart(:));

%calcul du critère 3 (moyenne des écarts)
q3=q2/(size(Zex,1)*size(Zex,2));