%%evaluation de la fonction polynomiale

%%L. LAURENT      luc.laurent@ens-cachan.fr
%% 10/03/2010


function [val]=eval_prg(coef,xx,deg)
%en dimension 1, xx doit être un vecteur colonne

%dimension du probleme
dim=size(xx,2);

%en fonction du degré du polynôme
if (deg==1)
    if dim==1
        a0=coef(1,1);
        a1=coef(2,1);
        
        val=a0+a1.*xx(:,1);
    elseif dim==2
        a0=coef(1,1);
        a1=coef(2,1);
        a2=coef(3,1);
        
        val=a0+a1.*xx(:,1)+a2.*xx(:,2);
    else
        error('Dimension du probleme non pris en charge');
    end
    
elseif(deg==2)
    if dim==1
        a0=coef(1,1);
        a1=coef(2,1);
        a2=coef(3,1);
        
        
        val=a0+a1.*xx+a2.*xx.^2;
    elseif dim==2
        a0=coef(1,1);
        a1=coef(2,1);
        a2=coef(3,1);
        a11=coef(4,1);
        a22=coef(5,1);
        a12=coef(6,1);
        
        val=a0+a1.*xx(:,1)+a2.*xx(:,2)+a11.*xx(:,1).^2+a22.*xx(:,2).^2+a12.*xx(:,1).*xx(:,2);
    else
        error('Dimension du probleme non pris en charge');
    end
    
elseif(deg==3)
    if dim==1
        a0=coef(1,1);
        a1=coef(2,1);
        a2=coef(3,1);
        a3=coef(4,1);
        
        val=a0+a1.*xx+a2.*xx.^2+a3.*xx.^3;
    elseif dim==2
        a0=coef(1,1);
        a1=coef(2,1);
        a2=coef(3,1);
        a11=coef(4,1);
        a22=coef(5,1);
        a12=coef(6,1);
        a111=coef(7,1);
        a222=coef(8,1);
        a112=coef(9,1);
        a122=coef(10,1);
        
        
        val=a0+a1.*xx(:,1)+a2.*xx(:,2)+a11.*xx(:,1).^2+a22.*xx(:,2).^2+a12.*xx(:,1).*xx(:,2)...
            +a111.*xx(:,1).^3+a222.*xx(:,2).^3+a112.*xx(:,1).^2.*xx(:,2)+a122.*xx(:,1).*xx(:,2).^2;
    else
        error('Dimension du probleme non pris en charge');
    end
    
elseif(deg==4)
    f(deg==3)
    if dim==1
        a0=coef(1,1);
        a1=coef(2,1);
        a2=coef(3,1);
        a3=coef(4,1);
        a4=coef(5,1);
        
        
        val=a0+a1.*xx+a2.*xx.^2+a3.*xx.^3+a4.*xx.^4;
    elseif dim==2
        a0=coef(1,1);
        a1=coef(2,1);
        a2=coef(3,1);
        a11=coef(4,1);
        a22=coef(5,1);
        a12=coef(6,1);
        a111=coef(7,1);
        a222=coef(8,1);
        a112=coef(9,1);
        a122=coef(10,1);
        a1111=coef(11,1);
        a2222=coef(12,1);
        a1112=coef(13,1);
        a1222=coef(14,1);
        a1122=coef(15,1);
        
        val=a0+a1.*xx(:,1)+a2.*xx(:,2)+a11.*xx(:,1).^2+a22.*xx(:,2).^2+a12.*xx(:,1).*xx(:,2)+a111.*xx(:,1).^3+...
            a222.*xx(:,2).^3+a112.*xx(:,1).^2.*xx(:,2)+a122.*xx(:,1).*xx(:,2).^2+...
            a1111.*xx(:,1).^4+a2222.*xx(:,2).^4+a1112.*xx(:,1).^3.*xx(:,2)+...
            a1222.*xx(:,1).*xx(:,2).^3+a1122.*xx(:,1).^2.*xx(:,2).^2;
    else
        error('Dimension du probleme non pris en charge');
    end
    
    
else
    disp('Degre de polynome non encore pris en comtpe');
end

end