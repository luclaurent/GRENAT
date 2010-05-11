%fonction assurant l'évaluation du métamodèle de krigeage
%L. LAURENT -- 11/05/2010 -- L. LAURENT

function Z=eval_krg(X,tirages,krg)

%calcul de l'évaluation du métamodèle au point considéré
%matrice de corrélation aux points d'évaluations
rr=zeros(krg.dim,1);
for ll=1:krg.dim
   rr(ll)=feval(krg.corr,tirages(ll,:)-X,krg.theta);
end

%matrice de régression aux points d'évalutions
nbt=1/2*(krg.deg+1)*(krg.deg+2);
ff=zeros(nbt,1);
ff=feval(krg.reg,X);


%évaluation du métamodèle au point X
Z=ff*krg.beta+rr'*krg.gamma;