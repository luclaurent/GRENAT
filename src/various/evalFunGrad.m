%% Evaluation of the function and the gradients
% L. LAURENT -- 17/12/2010 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox 
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016  Luc LAURENT <luc.laurent@lecnam.net>
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

function [eval,grad]=evalFunGrad(funR,X,type)


countTime=mesuTime;
% depending on the kind of evaluations (computation at the sample points or
% for displaying)
switch type
    %evaluate sample points (X is a matrix: 1var per column)
    case 'eval'
        Gfprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
        Gfprintf('  >>>   EVALUATION of the FUNCTION  <<<\n');
        %% X matrix of sample points:
        % columns: each design parameters
        % rows: one set of parameters
        np=size(X,2);
        ns=size(X,1);

        %preparing set of sample points for evaluation
        Xeval=zeros(ns,1,np);
        
        for ii=1:np
            Xeval(:,:,ii)=X(:,ii);
        end
        %evalaution for display (X est a nd-array)
    case 'disp'
        Gfprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
        Gfprintf('  >>> EVALUATION of the FUNCTION (display) <<<\n');
        Xeval=X;
        np=size(X,3);
        ns=size(X,1);
end

%fix fun name
funT=[funR];

%evaluation of the function and gradients at sample points X
if nargout==1
    [eval]=feval(funT,Xeval);
elseif nargout==2
    [eval,gradb]=feval(funT,Xeval);
    % reordering in the case of evaluation
    if strcmp(type,'eval')
        grad=zeros(size(X));
        for ii=1:np
           grad(:,ii)=gradb(:,:,ii); 
        end
    else
        grad=gradb;
    end
else
    error(['Wrong number of output parameters (cf. ',mfilename,')']);
end

fprintf(' >> Evaluation of the function %s at %i pts (%iD)\n',funT,ns,np);
fprintf(' >> Computation of the gradients: ');
if nargout==2;fprintf('Yes\n');else fprintf('No\n');end

countTime.stop;
fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')