function f = bard(x, y, z)
% **************************************************************
% **************************************************************
%  function [fvec,J]= bard(n,m,x,opt)
%  Bard function       [8] 
%  Dimensions  n=3,    m=15
%  Function definition:
%       f(x) = y(i) - [x1 + (u(i) / v(i)x2 + w(i)x3)]
%       where u(i) = i, v(i) = 16-i, w(i) = min(u(i),v(i))
%  Standard starting point at x= (1,1,1)
%  Minima f=8.21487...10^(-3)   and f=17.4286 at (0.8406...,-inf,-inf)
%
%  Revised 10/23/94   PLK
% **************************************************************


a    = [.14  .18  .22  .25  .29  .32  .35  .39  .37  .58
        .73  .96  1.34 2.10 4.39   0    0    0    0    0 ]' ;

for i = 1:15
     
    u(i) = i;
    v(i) = 16 - i;
    w(i) = min(u(i),v(i));

    fvec(i) = a(i)-(x+( u(i) / ( v(i)*y + w(i)*z ) ) );
    
end;

fvec=fvec';
f = fvec' * fvec;

