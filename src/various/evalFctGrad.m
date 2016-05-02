%% Evaluation of the function and the gradients
% L. LAURENT -- 17/12/2010 -- luc.laurent@lecnam.net

function [eval,grad]=evalFctGrad(fct,X,type)

[tMesu,tInit]=mesuTime;
% depending on the kind of evaluations (computation at the sample points or
% for displaying)
switch type
    %evaluate sample points (X is a matrix: 1var per column)
    case 'eval'
        fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
        fprintf('  >>>   EVALUATION of the FUNCTION  <<<\n');
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
        fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
        fprintf('  >>> EVALUATION of the FUNCTION (display) <<<\n');
        Xeval=X;
        np=size(X,3);
        ns=size(X,1);
end

%evaluation of the function and gradients at sample points X
if nargout==1
    [eval]=feval(fct,Xeval);
elseif nargout==2
    [eval,gradb]=feval(fct,Xeval);
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
    error(['Wrong number of output parametersMauvais nombre de paramètres de sortie (cf.',mfilename,')']);
end

fprintf(' >> Evaluation of the function %s in %i pts (%iD)\n',fct,ns,np);
fprintf(' >> Computation of the gradients: ');
if nargout==2;fprintf('Yes\n');else fprintf('No\n');end

mesu_time(tMesu,tInit);
fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')