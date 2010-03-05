function x = poly_kernel(a,b, d)
% polynomial kernel function for implicit higher dimension mapping
%
%  X = poly_kernel(a,b,[t,degree])
%
% 'a' can only contain one datapoint in a row, 'b' can contain N
% datapoints of the same dimension as 'a'. 
%
% x = (a*b'+t^2).^degree;
% 
% see also:
%    RBF_kernel, lin_kernel, MLP_kernel, trainlssvm, simlssvm
%

% Copyright (c) 2002,  KULeuven-ESAT-SCD, License & help @ http://www.esat.kuleuven.ac.be/sista/lssvmlab

if length(d)>1, d=d(2); t=d(1); else d = d(1);t=1; end
d = (abs(d)>=1)*abs(d)+(abs(d)<1); % >=1 !!

x = zeros(size(b,1),1);
for i=1:size(b,1),
  x(i,1) = (a*b(i,:)'+t^2).^d;
end

