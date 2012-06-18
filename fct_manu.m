function [fct,dfct]=fct_manu(x)
v=2;

if v==1
    fct=15*cos(x)+20;
    if nargout==2
        dfct=-15*sin(x);
    end
elseif v==2
    a=10;
    b=0;
    fct=exp(-x/a).*cos(x)+1/a*x+b;
    if nargout==2
        dfct=-exp(-x/a).*(sin(x)+1/a.*cos(x))+1/a;
    end
elseif v==3
    fct=cos(4*x);
    if nargout==2
        dfct=-4*sin(4*x);
    end
end