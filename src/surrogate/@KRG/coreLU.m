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


%% Core of kriging computation using LU factorization
% INPUTS:
% - paraValIn: value of the hyperparameters
% OUTPUTS:
% - detK,logDetK: determinant and log of the derterminant of the kernel
% matrix

function [detK,logDetK]=coreLU(obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LU factorization
[obj.matrices.LK,obj.matrices.UK,obj.matrices.PK]=lu(obj.K,'vector');
%
diagUK=diag(obj.matrices.UK);
detK=prod(diagUK); %L is a quasi-triangular matrix and contains ones on the diagonal
logDetK=sum(log(abs(diagUK)));
%
yP=obj.YYtot(obj.matrices.PK,:);
fctP=obj.krgLS.XX(obj.matrices.PK,:);
yL=obj.matrices.LK\yP;
fctL=obj.matrices.LK\fctP;
obj.matrices.fcU=obj.krgLS.XX'/obj.matrices.UK;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute beta coefficient
obj.matrices.fcCfct=obj.matrices.fcU*fctL;
block2=obj.matrices.fcU*yL;
obj.beta=obj.matrices.fcCfct\block2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute gamma coefficient
obj.gamma=obj.matrices.UK\(yL-fctL*obj.beta);
end
