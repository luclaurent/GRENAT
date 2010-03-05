% Freudenstein and Roth function 
% ------------------------------ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% function [fvec,J]=froth(n,m,x,option)     
% Problem no. 2
% Dimensions -> n=2, m=2                           
% Standard starting point -> x=(0.5,-2)            
% Minima -> f=0 at (5,4)                           
%           f=48.9842... at (11.41...,-0.8968...)  
%                                                  
% Revised on 10/22/94 by Madhu Lamba               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%function [fvec,J] = froth(n,m,x,option)
function f = froth(x, y)
  fvec = [ -13+x+((5-y)*y-2)*y
          -29+x+((y+1)*y-14)*y ]; 
  
  f = fvec' * fvec;
end
%
