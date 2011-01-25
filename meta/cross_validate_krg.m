%Fonction assurant le calcul des diverses erreurs par validation croisee
%dans le cas du Krigeage
%L. LAURENT -- 16/12/2010 -- laurent@lmt.ens-cachan.fr

function [cv]=cross_validate_krg(krg,tirages,eval)

%stockage des evaluations du metamodele au point enleve
cv_z=zeros(krg.dim,1);
cv_var=zeros(krg.dim,1);
cv_gz=zeros(krg.dim,krg.con);

%%On parcourt l'ensemble des tirages
for tir=1:krg.dim
   %%On construit le metamodele de CoKrigeage avec un site en moins
   %Traitement des matrices et vecteurs en supprimant les lignes et
   %colonnes correspondant 
   
   %positions des element a retirer
   pos=[tir];
   cv_fc=krg.fc;
   cv_fc(pos,:)=[];
   cv_rc=krg.rc;
   cv_rc(pos,:)=[];
   cv_rc(:,pos)=[];
   cv_y=krg.y;
   cv_y(pos)=[];
   cv_tirages=tirages;
   cv_tirages(tir,:)=[];
   
   %passage des parametres
   krg_cv=krg;
   krg_cv.dim=krg_cv.dim-1;  %retrait d'un site
   krg_cv.rc=cv_rc;
   
   %calcul de beta
   warning off all
   cv_ft=cv_fc';
   block1=((cv_ft/cv_rc)*cv_fc);
   block2=((cv_ft/cv_rc)*cv_y);
   krg_cv.beta=block1\block2;
  
   
   krg_cv.ft=cv_ft;
   
   %creation de la matrice des facteurs de correlation
   krg_cv.gamma=cv_rc\(cv_y-cv_fc*krg_cv.beta);
    
   
   %calcul de la variance de prediction
   
    sig2=1/size(cv_rc,1)*((cv_y-cv_fc*krg_cv.beta)'/cv_rc)...
        *(cv_y-cv_fc*krg_cv.beta);
    warning on all
    
    if krg.norm.on
        krg_cv.sig2=sig2*krg.norm.std_eval^2;
    else
        krg_cv.sig2=sig2;
    end

   %%Evaluation du metamodele au point supprime de la construction
   [cv_z(tir),cv_gz(tir,:),cv_var(tir)]=eval_krg(tirages(tir,:),cv_tirages,krg_cv);
   
end
warning on all;

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
%critere d'adequation
diffa=diffc./cv_var;
cv.adequ=1/krg.dim*sum(diffa);