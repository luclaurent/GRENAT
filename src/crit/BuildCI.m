%% function for building confidence intervals (CI)
% L. LAURENT -- 03/12/2010 -- luc.laurent@lecnam.net
%
% input variables: predication and variance provided by the surrogate model
% outputs: 68%, 95% and 99.7% CI

%     GRENAT - GRadient ENhanced Approximation Toolbox 
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016-2017  Luc LAURENT <luc.laurent@lecnam.net>
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

function [ci68,ci95,ci99]=BuildCI(ZZ,var)

% numerical problem of negative variance
if any(var<0)
    Gfprintf(' >> Negative variance (changed to absolute value)\n');
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
