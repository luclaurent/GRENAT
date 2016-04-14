%%fonction permettant d'évaluer le gradient du métamodèle RBF en un ensemble de pts donnés

%%L. LAURENT      luc.laurent@lecnam.net
%% 12/04/2010

function [Grbf1,Grbf2]=evald_rbf(xx,yy,tirages,w,para,fct)

Grbf1=zeros(size(xx));
Grbf2=zeros(size(xx));
for kk=1:size(xx,1)
    for ll=1:size(xx,2)
        for ii=1:size(w,1)
            pt=[xx(kk,ll) yy(kk,ll)];
            %calcul du gradient de la fonction support en un pt
            G=feval(fct,(pt-tirages(ii,:))',para,'d');
            %calcul du gradient du métamodèle en un pt
            Grbf1(kk,ll)=Grbf1(kk,ll)+w(ii)*G(1);
            Grbf2(kk,ll)=Grbf2(kk,ll)+w(ii)*G(2);
        end
    end
end



end