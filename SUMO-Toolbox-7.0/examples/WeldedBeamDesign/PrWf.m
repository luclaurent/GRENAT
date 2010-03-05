function y = PrWf(h, l, t, b)
% Matlab Code by A. Hedar (Nov. 23, 2005).
% Welded beam design problem
% h= 0.2444, l = 6.2187, t = 8.2915, b = 0.2444
% f*(x) = 2.38116
% Solution reported by 
% G.V. Reklaitis, A. Ravindran, K.M. Ragsdell, Engineering Optimization Methods and Applications, Wiley, New York, 1983.

% x1 = height
% x2 = length
% x3 = t
% x4 = b
y = 1.10471.*h.^2.*l + 0.04811.*t.*b .* (14.0+l);
