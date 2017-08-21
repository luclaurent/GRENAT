%% Method of KRG class
% L. LAURENT -- 07/08/2017 -- luc.laurent@lecnam.net

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


%% Core of kriging computation using Cholesky (LL) factorization
% INPUTS:
% - paraValIn: value of the hyperparameters
% OUTPUTS:
% - detK,logDetK: determinant and log of the derterminant of the kernel
% matrix

function [detK,logDetK]=coreLL(obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Cholesky's fatorization
%%% to be degugged
obj.matrices.LK=chol(obj.K,'lower');
%
diagLK=diag(obj.matrices.LK);
detK=prod(diagLK)^2;
logDetK=2*sum(log(abs(diagLK)));
%
LtK=obj.matrices.LK';
yL=obj.matrices.LK\obj.YYtot;
fctL=obj.matrices.LK\obj.krgLS.XX;
obj.matrices.fcL=obj.krgLS.XX'/LtK;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute beta coefficient
obj.matrices.fcCfct=obj.matrices.fcL*fctL;
block2=obj.matrices.fcL*yL;
obj.beta=obj.matrices.fcCfct\block2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute gamma coefficient
obj.gamma=LtK\(yL-fctL*obj.beta);
end
