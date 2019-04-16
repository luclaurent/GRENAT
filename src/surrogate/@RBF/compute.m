%% Method of RBF class
% L. LAURENT -- 15/08/2017 -- luc.laurent@lecnam.net

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


%% Build factorization, solve the RBF problem
% INPUTS:
% - paraValIn: value of the hyperparameters
% OUTPUTS:
% - none

function compute(obj,paraValIn)
if nargin==1;
    paraValIn=obj.paraVal;
else
    obj.paraVal=paraValIn;
end
%
if obj.requireCompute
    %build the kernel Matrix
    obj.buildMatrix(paraValIn);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Factorization of the matrix
    switch obj.factK
        case 'QR'
            obj.coreQR;
        case 'LU'
            obj.coreLU;
        case 'LL'
            obj.coreLL;
        otherwise
            obj.coreClassical;
    end
    %
end
end
