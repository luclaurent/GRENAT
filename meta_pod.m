%%fonction permettant de construire un metamodèle en utilisant la POD

%%L. LAURENT      luc.laurent@ens-cachan.fr
%% 16/03/2010

function S=meta_pod(tirages,xx,yy,eval,nb_vs)

    A=zeros(sqrt(size(eval,1)));
    [Xv,Yv]=meshgrid(xx,yy);
    %Xv=zeros(size(A));
    %Yv=zeros(size(A));
    
    int=1;
    for ii=1:size(A,1)
        for jj=1:size(A,2)
            A(ii,jj)=eval(int);
            int=int+1;
        end
        Xv(ii)=tirages(ii,1);
        Yv(ii)=tirages(ii,2);
     end
    
    %Calcul de la décomposition en valeurs singulières
    [U,S,V]=svd(A);
    
    
    subplot(floor(sqrt(nb_vs)),floor(sqrt(nb_vs))+1,1)
    hold on
    mesh(Xv,Yv,A)
    view(3)
    for k=1:nb_vs
       
       zz=U(:,1:k)*S(1:k,1:k)*V(:,1:k)';
       %size(zz)
       %size(Xv)
       %hold on
       %subplot(floor(sqrt(nb_vs)),floor(sqrt(nb_vs))+1,k+1)
       figure;
       %hold on
       %mesh(Xv,Yv,zz)
       surf(Xv,Yv,zz)
       %hold on
       xlabel('x1');ylabel('x2');zlabel('F');
       %hold on
       title(['Approximation à ',num2str(k),' valeurs singulières']);
       view(3)
    end
    



end