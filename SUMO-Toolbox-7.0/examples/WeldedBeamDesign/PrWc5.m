function y = PrWc5(x)
% Matlab Code by A. Hedar (Nov. 23, 2005).
% Welded beam design problem, constraints
% Parameters
P = 6000; L = 14; E = 30e+6;
d_max = 0.25;
d = 4.*P.*L.^3./(E.*x(:,4).*x(:,3).^3);
% Constraints
y = d-d_max;