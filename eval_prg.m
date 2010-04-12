%%evaluation de la fonction polynomiale

%%L. LAURENT      luc.laurent@ens-cachan.fr
%% 10/03/2010


function [val]=polyrg(coef,xx,yy,deg)

if (deg==1)
    a0=coef(1,1);
   a1=coef(2,1);
   a2=coef(3,1);
   
   val=a0+a1.*xx+a2.*yy;
   
elseif(deg==2)
   a0=coef(1,1);
   a1=coef(2,1);
   a2=coef(3,1);
   a11=coef(4,1);
   a22=coef(5,1);
   a12=coef(6,1);
   
   val=a0+a1.*xx+a2.*yy+a11.*xx.^2+a22.*yy.^2+a12.*xx.*yy;
   
elseif(deg==3)
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
     
   
   val=a0+a1.*xx+a2.*yy+a11.*xx.^2+a22.*yy.^2+a12.*xx.*yy+a111.*xx.^3+a222.*yy.^3+a112.*xx.^2.*yy+a122.*xx.*yy.^2;
   
elseif(deg==4)
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
   
   val=a0+a1.*xx+a2.*yy+a11.*xx.^2+a22.*yy.^2+a12.*xx.*yy+a111.*xx.^3+a222.*yy.^3+a112.*xx.^2.*yy+a122.*xx.*yy.^2+...
       a1111.*xx.^4+a2222.*yy.^4+a1112.*xx.^3.*yy+a1222.*xx.*yy.^3+a1122.*xx.^2.*yy.^2;
   
else
    disp('Degré de polynome non encore pris en comtpe');
end

end