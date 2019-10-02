%% Specific execution of Quadratic Programming depending on Matlab/Octave
% L. LAURENT -- 18/08/2017 -- luc.laurent@lecnam.net

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

function [solQP, fval, exitflag, lmQP]=ExecQP(PsiT,CC,AA,bb,Aeq,beq,lb,ub,opts)
if isOctave
    [solQP, fval, info, lambda] = qp(zeros(size(CC)),PsiT,CC,Aeq,beq,lb,ub,[], AA, bb);
    exitflag=info.info;
    lmQP.ineqlin=lambda((end-numel(bb)+1):end);
    lmQP.eqlin=-lambda(1:numel(beq));
    lmQP.lower=lambda(numel(beq)+(1:numel(lb)));
    lmQP.upper=lambda(numel(beq)+numel(lb)+(1:numel(ub)));
else
    [solQP,fval,exitflag,~,lmQP]=quadprog(PsiT,CC,AA,bb,Aeq,beq,lb,ub,[],opts);
end
end