%%fonction permettant d'etablir une regression polynomiale à partir d'un
%%ensemble de points

%%L. LAURENT      luc.laurent@ens-cachan.fr
%% 10/03/2010


function [B,MSE]=meta_prg(xx,eval,deg)

%en dimension 1: xx et eval doivent etre des vecteurs colonne

%constante
nb_pts=size(xx,1);
dim=size(xx,2);

if(deg==1) %%polynome de degre 1
    matx=zeros(nb_pts,1+dim);
    matx(:,1)=ones(nb_pts,1);
    matx(:,2:dim+1)=xx;
    fs=eval;
    
elseif(deg==2)  %%polynome de degre 2
    %nombre de colonne
    ncl=(dim+1)*(dim+2)/2;
    matx=zeros(nb_pts,ncl);
    matx(:,1)=ones(nb_pts,1);
    matx(:,2:dim+1)=xx;
    j=dim+1;q=dim;
    for ii=1:dim
        matx(:,j+(1:q)) = repmat(xx(:,ii),1,q) .* xx(:,ii:dim);
        j = j+q;   q = q-1;
    end
    fs=eval;
    
    
    
elseif(deg==3)  %%polynome de degre 3
    
    if dim==1
        matx=[ones(size(eval,1),1) xx xx.^2 xx.^3];
    elseif dim==2
        matx=[ones(size(eval,1),1) xx(:,1) xx(:,2) xx(:,1).^2 xx(:,2).^2 xx(:,1).*xx(:,2) xx(:,1).^3 ...
            xx(:,2).^3 xx(:,1).^2.*xx(:,2) xx(i,1).*xx(i,2).^2];
    else
        error('Dimension non prise en charge');
    end
    fs=eval;
    
    
elseif(deg==4)  %%polynome de degre 4
    if dim==1
        matx=[ones(size(eval,1),1) xx xx.^2 xx.^3 xx.^4];
    elseif dim==2
        matx=[ones(size(eval,1),1) xx(:,1) xx(:,2) xx(:,1)^2 xx(:,2)^2 xx(:,1)*xx(:,2) xx(:,1)^3 ...
            xx(:,2)^3 xx(:,1)^2*xx(:,2) xx(:,1)*xx(:,2)^2 ...
            xx(:,1)^4 xx(:,2)^4 xx(:,1)^3*xx(:,2) xx(:,1)*xx(:,2)^3 xx(:,1)^2*xx(:,2)^2];
    else
        error('Dimension non prise en charge');
    end
    fs=eval;
    
else
    error('Degre de polynome non encore pris en comtpe');
end

%%Determination des coefficients du polynome
%  f(x)=a0+a1*x1+a2*x2+a11*x1²+a22*x2²+a12*x1*x2
% B=[a0 a1 a2 a11 a22 a12]; polynome de degre 2

B=inv(matx'*matx)*matx'*fs;
if nargout==2
    MSE=B'*matx'*matx*B-2*B'*matx'*fs+fs'*fs;
end
end

