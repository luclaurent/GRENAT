%%fonction permettant le calcul de l'erreur RMAE
%%L. LAURENT   --  22/03/2010   --  luc.laurent@ens-cachan.fr

%%Zex: valeurs de la fonction objectif "exactes" obtenues par simulation
%%Zap: valeurs approchées de la fonction objectif obtenues par le
%%métamodèle
function rmae=rmae(Zex,Zap)




%permutation du vecteur pour permettre le calcul de MSE
if(size(Zap,1)<size(Zap,2))
Zap=Zap';
end
if(size(Zex,1)<size(Zex,2))
Zex=Zex';
end

hh=1;

for kk=1:size(Zex,1)
    for ll=1:size(Zex,2)
        vvx(hh)=Zex(kk,ll);
        vva(hh)=Zap(kk,ll);
        hh=hh+1;
    end
end

vec=zeros(size(vvx));
STD=std(vvx);


for ii=1:size(vvx,1)
    vec(ii)=abs(vvx(ii)-vva(ii)); 
   end

rmae=max(vec)/STD;

end