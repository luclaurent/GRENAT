function perf=mserr(e)
%
% calculate the mean squared error of the given errors
% 
%  'perf = mserr(E);'
%
% see also:
%    mae, linf, trimmedmse
%

% Copyright (c) 2002,  KULeuven-ESAT-SCD, License & help @ http://www.esat.kuleuven.ac.be/sista/lssvmlab


perf = sum(sum(e.^2)) / prod(size(e));