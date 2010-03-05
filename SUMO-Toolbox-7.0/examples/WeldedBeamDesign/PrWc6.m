function y = PrWc6(x)
% Matlab Code by A. Hedar (Nov. 23, 2005).
% Welded beam design problem, constraints
% Parameters
P = 6000; L = 14; E = 30e+6; G = 12e+6;
P_c = (4.013.*E./(6.*L.^2)).*x(:,3).*x(:,4).^3.*(1-0.25.*x(:,3).*sqrt(E./G)./L);
% Constraints
y = P-P_c;