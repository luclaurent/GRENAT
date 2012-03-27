function [fct,dfct]=fct_manub(x)


%fct=15*cos(x)+20;
%if nargout==2
%    dfct=-15*sin(x);
%end
a=10;
b=0;
c=5;

fct=exp(-x/a).*cos(c*x)+1/a*x+b;

if nargout==2
   dfct=-exp(-x/a).*(sin(x)+1/a.*cos(x))+1/a; 
end