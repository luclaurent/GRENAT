%%fonction permettant de construire un metamodèle à l'aide de fonctions à
%%base radiale

%%L. LAURENT      luc.laurent@ens-cachan.fr
%% 15/03/2010 modif le 12/04/2010

function w=meta_rbf(tirages,eval,para,fct)

if (size(eval,1)<size(eval,2))
    F=eval';
else
    F=eval;
end
    %pour éviter les erreurs de mauvaise dimensions du vecteur eval
    taille=max(size(eval,1),size(eval,2));
    A=zeros(taille);
    for ii=1:taille
        for jj=1:taille
            
           A(ii,jj)=feval(fct,(tirages(ii,:)-tirages(jj,:))',para,'f');            
        end
    end
    
    w=inv(A)*F;


end