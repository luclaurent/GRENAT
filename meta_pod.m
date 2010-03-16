%%fonction permettant de construire un metamodèle en utilisant la POD

%%L. LAURENT      luc.laurent@ens-cachan.fr
%% 16/03/2010

function w=meta_pod(tirages,eval,nb_vs)

    A=zeros(sqrt(size(eval,1)));
    Xv=meshgrid(tirages(:,1));
    Yv=meshgrid(tirages(:,2));
    
    int=1;
    for ii=1:size(A,1)
        for jj=1:size(A,2)
            A(ii,jj)=eval(int);
            int=int+1;
        end
     end
    
    %Calcul de la décomposition en valeurs singulières
    [U,S,V]=svd(A);
    
    for k=1:nb_vs
        figure;
       zz=U(:,1:k)*S(1:k,1:k)*V(:,1:k)';
       surf(Xv,Yv,zz);
       xlabel('x1');ylabel('x2');zlabel('F');
       title(['Approximation à ',num2str(k),' valeurs singulières']);
    end
    



end