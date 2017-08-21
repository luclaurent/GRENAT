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


%% Build kernel matrix and remove missing part
% INPUTS:
% - paraValIn: value of the hyperparameters
% OUTPUTS:
% - K: full kernel matrix

function K=buildMatrix(obj,paraValIn)
%in the case of GKRG
if obj.flagG
    [KK,KKd,KKdd]=obj.kernelMatrix.buildMatrix(paraValIn);
    obj.K=[KK -KKd;-KKd' -KKdd];
else
    [obj.K]=obj.kernelMatrix.buildMatrix(paraValIn);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Improve condition number of the KRG/GKRG Matrix
if obj.metaData.recond
    %coefficient for reconditionning (co)kriging matrix
    coefRecond=(10+size(obj.krgLS.XX,1))*eps;
    %
    obj.K=obj.K+coefRecond*speye(size(obj.K));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%remove missing parts
if obj.checkMiss
    if obj.flagG
        obj.K=obj.missData.removeGRM(obj.K);
    else
        obj.K=obj.missData.removeRM(obj.K);
    end
end
%
K=obj.K;
%
end
