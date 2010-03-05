function y = PrWc4(x)
% Matlab Code by A. Hedar (Nov. 23, 2005).
% Welded beam design problem, constraints
% Parameters
% Constraints
y = 0.10471.*x(:,1).^2+0.04811.*x(:,3).*x(:,4).*(14.0+x(:,2))-5.0;