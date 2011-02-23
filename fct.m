function [fct,dfct]=fct(x)


%fct=15*cos(x)+20;
%if nargout==2
%    dfct=-15*sin(x);
%end
a=10;
b=0;

fct=exp(-x/a).*cos(x)+1/a*x+b;

if nargout==2
   dfct=-exp(-x/a).*(sin(x)+x/a.*cos(x))+1/a; 
end