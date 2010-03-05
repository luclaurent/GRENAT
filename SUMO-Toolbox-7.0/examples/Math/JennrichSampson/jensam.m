function f = jensam(x1, x2)
% **********************************************
% **********************************************
%
% function [fvec, J]= jensam(n,m,x,opt)
% Jenrich and Sampson function [6]
% Dimensions n=2,   m>=n
% Function definition 
%               f(x)=2+2i-(exp[ix1] + exp[ix2])
% Standard starting point x=(0.3,0.4)
% minima of f=124.362 at x1=x2=0.2578 for m=10
%
% Revised 10/23/94  PLK
% **********************************************
for i=1:10
        fvec(i) =  (2+2*i-(exp(i*x1)+exp(i*x2))) ;
end

fvec=fvec';
f = fvec' * fvec;
