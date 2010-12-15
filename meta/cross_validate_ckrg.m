%Fonction assurant le calcul des diverses erreurs par validation croisée
%dans le cas du CoKrigeage
%L. LAURENT -- 14/12/2010 -- laurent@lmt.ens-cachan.fr

function [cv]=cross_validate_ckrg(ckrg,tirages,eval)

%stockage des évaluations du metamodèle au point enleve
cv_z=zeros(ckrg.dim,1);
cv_var=zeros(ckrg.dim,1);
cv_gz=zeros(ckrg.dim,ckrg.con);

%%On parcourt l'ensemble des tirages
for tir=1:ckrg.dim
   %%On construit le métamodèle de CoKrigeage avec un site en moins
   %Traitement des matrices et vecteurs en supprimant les lignes et
   %colonnes correspondant 
   cv_fc=ckrg.fc;
   cv_fc([tir ckrg.dim+(tir:tir+ckrg.con)])=[];
   cv_rcc=ckrg.rcc;
   cv_rcc([tir ckrg.dim+(tir:tir+ckrg.con)],:)=[];
   cv_rcc(:,[tir ckrg.dim+(tir:tir+ckrg.con)])=[];
   cv_y=ckrg.y;
   cv_y([tir ckrg.dim+(tir:tir+ckrg.con)])=[];
   cv_tirages=tirages;
   cv_tirages(tir,:)=[];
   
   %calcul de beta
   cv_ft=cv_fc';
   block1=((cv_ft/cv_rcc)*cv_fc);
   block2=((cv_ft/cv_rcc)*cv_y);
   ckrg_cv.beta=block1\block2;
   %creation de la matrice des facteurs de correlation
   ckrg_cv.gamma=cv_rcc\(cv_y-cv_fc*ckrg_cv.beta);
   
   %%Evaluation du métamodèle au point supprime de la construction
   [cv_z(tir),cv_gz(tir,:),cv_var(tir)]=eval_ckrg([tirages(tir,1) tirages(tir,2)],cv_tirages);
end


%%Calcul des differentes erreurs
%differences entre les evaluations vraies et celle obtenues en retranchant
%le site associe
diff=cv_z-eval;
%Biais moyen
cv.bm=1/krg.dim*sum(diff);
%MSE
diffc=diff.^2;
cv.msep=1/krg.dim*sum(diffc);
%PRESS
cv.press=sum(diffc);
%critère d'adequation
diffa=diff./cv_var;
cv.adequ=1/krg.dim*sum(diffa);

