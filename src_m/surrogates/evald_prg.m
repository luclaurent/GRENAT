%%evaluation de la dérivée de la fonction polynomiale

%%L. LAURENT      luc.laurent@lecnam.net
%% 10/03/2010


function [GRG1,GRG2]=evald_prg(coef,xx,yy,deg)

if (deg==1)
   
   a1=coef(2,1);
   a2=coef(3,1);
   
   GRG1=a1*ones(size(xx));
   GRG2=a2*ones(size(xx));
   
elseif(deg==2)
   
   a1=coef(2,1);
   a2=coef(3,1);
   a11=coef(4,1);
   a22=coef(5,1);
   a12=coef(6,1);
   
   
   GRG1=a1+2*a11.*xx+a12.*yy;
   GRG2=a2+2*a22.*yy+a12.*xx;
   
elseif(deg==3)
   
   a1=coef(2,1);
   a2=coef(3,1);
   a11=coef(4,1);
   a22=coef(5,1);
   a12=coef(6,1);
   a111=coef(7,1);
   a222=coef(8,1);
   a112=coef(9,1);
   a122=coef(10,1);    
   
    
   GRG1=a1+2*a11.*xx+a12.*yy+3*a111.*xx.^2+2*a112.*xx.*yy+a122.*yy.^2;
   GRG2=a2+2*a22.*yy+a12.*xx+3*a222.*yy.^2+a112.*xx.^2+2*a122.*xx.*yy;
   
elseif(deg==4)
   
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

      
   GRG1=a1+2*a11.*xx+a12.*yy+3*a111.*xx.^2+2*a112.*xx.*yy+a122.*yy.^2+4*a1111.*xx.^3+3*a1112.*xx.^2.*yy+a1222.*yy.^3+2*a1122.*xx.*yy.^2;
   GRG2=a2+2*a22.*yy+a12.*xx+3*a222.*yy.^2+a112.*xx.^2+2*a122.*xx.*yy+4*a2222.*yy.^3+a1112.*xx.^3+3*a1222.*xx.*yy.^2+2*a1122.*xx.^2.*yy;
else
    disp('Degré de polynome non encore pris en comtpe');
end

end