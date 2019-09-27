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


%% Core of kriging computation using QR factorization
% INPUTS:
% - paraValIn: value of the hyperparameters
% OUTPUTS:
% - detK,logDetK: determinant and log of the derterminant of the kernel
% matrix

function [detK,logDetK]=coreQR(obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%QR factorization
[obj.matrices.QK,obj.matrices.RK,obj.matrices.PK]=qr(obj.K);
%
diagRK=diag(obj.matrices.RK);
detK=abs(prod(diagRK)); %Q is an unitary matrix
logDetK=sum(log(abs(diagRK)));
%
obj.matrices.QtK=obj.matrices.QK';
yQ=obj.matrices.QtK*obj.YYtot;
fctQ=obj.matrices.QtK*obj.krgLS.XX;
obj.matrices.fcK=obj.krgLS.XX'*obj.matrices.PK/obj.matrices.RK;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute beta coefficient
obj.matrices.fcCfct=obj.matrices.fcK*fctQ;
block2=obj.matrices.fcK*yQ;
obj.beta=obj.matrices.fcCfct\block2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute gamma coefficient
obj.gamma=obj.matrices.PK*(obj.matrices.RK\(yQ-fctQ*obj.beta));
end
