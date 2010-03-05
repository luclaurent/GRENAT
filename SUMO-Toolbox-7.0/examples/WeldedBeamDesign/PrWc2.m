function y = PrWc2(x)
% Matlab Code by A. Hedar (Nov. 23, 2005).
% Welded beam design problem, constraints
% Parameters
P = 6000; L = 14;
s_max = 30000;
s = 6.*P.*L./(x(:,4).*x(:,3).^2);
% Constraints
y = s-s_max;
