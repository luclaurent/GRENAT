%% function for building confidence intervals (CI)
% L. LAURENT -- 03/12/2010 -- luc.laurent@lecnam.net

% input variables: predication and variance provided by the surrogate model
% outputs: 68%, 95% and 99.7% CI

function [ci68,ci95,ci99]=BuildCI(ZZ,var)

% numerical problem of negative variance
if any(var<0)
    fprintf(' >> Negative variance (changed to absolute value)\n');
end
v=abs(var);

%  68% CI
ci68.sup=ZZ+sqrt(v);
ci68.inf=ZZ-sqrt(v);
% 95% CI
if nargout>=2
    ci95.sup=ZZ+2*sqrt(v);
    ci95.inf=ZZ-2*sqrt(v);
end
% 99.7% CI
if nargout==3
    ci99.sup=ZZ+3*sqrt(v);
    ci99.inf=ZZ-3*sqrt(v);
end