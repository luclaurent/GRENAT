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


%% Core of kriging computation using no factorization
% INPUTS:
% - paraValIn: value of the hyperparameters
% OUTPUTS:
% - detK,logDetK: determinant and log of the derterminant of the kernel
% matrix

function [detK,logDetK]=coreClassical(obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%classical approach
eigVal=eig(obj.K);
detK=prod(eigVal);
logDetK=sum(log(eigVal));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute gamma and beta coefficients
obj.matrices.fcC=obj.krgLS.XX'/obj.K;
obj.matrices.fcCfct=obj.matrices.fcC*obj.krgLS.XX;
block2=((obj.krgLS.XX'/obj.K)*obj.YYtot);
obj.beta=obj.matrices.fcCfct\block2;
obj.gamma=obj.K\(obj.YYtot-obj.krgLS.XX*obj.beta);
end
