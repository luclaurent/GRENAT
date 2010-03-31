%%fonction permettant de construire un metamodèle à l'aide de fonctions à
%%base radiale

%%L. LAURENT      luc.laurent@ens-cachan.fr
%% 15/03/2010

function w=meta_rbf(tirages,eval,para,fct)

    F=eval;
    
    A=zeros(size(eval,1));
    for ii=1:size(eval,1)
        for jj=1:size(eval,1)
            
           A(ii,jj)=feval(fct,(tirages(ii,:)-tirages(jj,:))',para);            
        end
    end
    
    w=inv(A)*F;


end