%%fonction permettant d'évaluer le métamodèle RBF en un ensemble de pts donnés

%%L. LAURENT      luc.laurent@ens-cachan.fr
%% 15/03/2010

function Zrbf=eval_rbf(xx,yy,tirages,w,para,fct)

Zrbf=zeros(size(xx));
for kk=1:size(xx,1)
    for ll=1:size(xx,2)
        for ii=1:size(w,1)
            pt=[xx(kk,ll) yy(kk,ll)];
            Zrbf(kk,ll)=Zrbf(kk,ll)+w(ii)*feval(fct,(tirages(ii,:)-pt)',para);
        end
    end
end


end