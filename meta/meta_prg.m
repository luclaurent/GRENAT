%%fonction permettant d'établir une regression polynomiale à partir d'un
%%ensemble de points

%%L. LAURENT      luc.laurent@ens-cachan.fr
%% 10/03/2010


function [B,MSE]=meta_prg(xx,eval,deg)

if(deg==1) %%polynome de degré 1
    matx=zeros(size(eval,1),3);
    for i=1:size(eval,1)
        matx(i,:)=[1 xx(i,1) xx(i,2)];
        fs(i,1)=eval(i);
    end
    
elseif(deg==2)  %%polynome de degré 2    
    matx=zeros(size(eval,1),6);
    for i=1:size(eval,1)
        matx(i,:)=[1 xx(i,1) xx(i,2) xx(i,1)^2 xx(i,2)^2 xx(i,1)*xx(i,2)];
        fs(i,1)=eval(i);
    end
    
    
elseif(deg==3)  %%polynome de degré 3
    matx=zeros(size(eval,1),10);
    for i=1:size(eval,1)
        matx(i,:)=[1 xx(i,1) xx(i,2) xx(i,1)^2 xx(i,2)^2 xx(i,1)*xx(i,2) xx(i,1)^3 xx(i,2)^3 xx(i,1)^2*xx(i,2) xx(i,1)*xx(i,2)^2];
        fs(i,1)=eval(i);
    end
    
    elseif(deg==4)  %%polynome de degré 4
    matx=zeros(size(eval,1),15);
    for i=1:size(eval,1)
        matx(i,:)=[1 xx(i,1) xx(i,2) xx(i,1)^2 xx(i,2)^2 xx(i,1)*xx(i,2) xx(i,1)^3 xx(i,2)^3 xx(i,1)^2*xx(i,2) xx(i,1)*xx(i,2)^2 ...
            xx(i,1)^4 xx(i,2)^4 xx(i,1)^3*xx(i,2) xx(i,1)*xx(i,2)^3 xx(i,1)^2*xx(i,2)^2];
        fs(i,1)=eval(i);
    end
else
    disp('Degré de polynome non encore pris en comtpe');
end
    
    %%Détermination des coefficients du polynome
    %  f(x)=a0+a1*x1+a2*x2+a11*x1²+a22*x2²+a12*x1*x2
    % B=[a0 a1 a2 a11 a22 a12]; polynome de degré 2
    
    B=inv(matx'*matx)*matx'*fs;
    MSE=B'*matx'*matx*B-2*B'*matx'*fs+fs'*fs;
end