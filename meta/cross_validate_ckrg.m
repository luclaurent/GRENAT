%Fonction assurant le calcul des diverses erreurs par validation croisée
%dans le cas du CoKrigeage
%L. LAURENT -- 14/12/2010 -- laurent@lmt.ens-cachan.fr

function []=cross_validate_ckrg(ckrg,tirages)


%%On parcourt l'ensemble des tirages
for tir=1:ckrg.dim
   %%On construit le métamodèle de CoKrigeage avec un site en moins
   %Traitement des matrices et vecteurs en supprimant les lignes et
   %colonnes correspondant 
   cv_fc=ckrg.fc;
   cv_fc()=[];
   cv_rcc=ckrg.rcc;
   cv_rcc()=[];
   cv_y=ckrg.y;
   cv_y()=[];
   
   %calcul de beta
   cv_ft=cv_fc';
   block1=((cv_ft/cv_rcc)*cv_fc);
   block2=((cv_ft/cv_rcc)*cv_y);
   ckrg_cv.beta=block1\block2;
   %creation de la matrice des facteurs de correlation
   ckrg_cv.gamma=cv_rcc\(cv_y-cv_fc*ckrg_cv.beta);
   
   %%Evaluation du métamodèle au point supprime de la construction
   [cv_z(tir),GZ(tir,:)]=eval_ckrg();
end