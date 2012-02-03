%% Fonction assurant l'enrichissemsnt de la base de points echantillonnes 
%% L. LAURENT -- 04/12/2011 -- laurent@lmt.ens-cachan.fr


function new_tir=ajout_tir_doe(doe,old_tirages)


Xmin=doe.bornes(:,1);
Xmax=doe.bornes(:,2);

nb_samples=size(old_tirages,1);

% en fonction du type de tirages initial
switch doe.type
    case 'LHS_R'
        [~,new_tir]=lhsu_R(Xmin,Xmax,nb_samples,old_tirages,1);
    case 'IHR_R'
        [~,new_tir]=ihs_R(Xmin,Xmax,nb_samples,old_tirages,1);
    otherwise
        fprintf('>>>> Seul les tirages de type LHS_R et IHS_R \n permettent l''enrichissement\n')
        pts=[];
end