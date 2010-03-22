%%fonction permettant le calcul de l'erreur RMAE
%%L. LAURENT   --  22/03/2010   --  luc.laurent@ens-cachan.fr

%%Zex: correspond à l'ensemble des valeurs obtenues par évalutions de la
%%fonction objectif
%%Zap: correspond à l'ensemble des valeurs
function rmae=rmae(Zex,Zap)

bor=size(Zex,1)*size(Zex,1);
for kk=1:bor
    vvx(kk)=Zex(kk);
    vva(kk)=Zap(kk);
end

vec=zeros(bor,1);
STD=std(vvx);


for ii=1:size(vvx,1)
    vec(ii)=abs(vvx(ii)-vva(ii)); 
   end

rmae=max(vec)/STD;

end