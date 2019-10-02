%% Method of SVR class
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


%% Build kernel matrix and remove missing part
% INPUTS:
% - paraValIn: value of the hyperparameters
% OUTPUTS:
% - K: full kernel matrix

function K=buildMatrix(obj,paraValIn)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Build of the SVR/GSVR matrix
if obj.flagG
    %for GSVR
    [KK,KKd,KKdd]=obj.kernelMatrix.buildMatrix(paraValIn);
    %remove missing data
    if obj.checkMiss
        KK=obj.missData.removeRM(KK);
        KKd=obj.missData.removeRV(KKd);
        KKdd=obj.missData.removeGM(KKdd);
    end
    %assemble matrices
    obj.K=[KK -KKd;-KKd' -KKdd];
    Psi=[KK -KK;-KK KK];
    PsiDo=-[KKd -KKd; -KKd KKd];
    PsiDDo=-[KKdd -KKdd;-KKdd KKdd];
    obj.PsiT=[Psi PsiDo;PsiDo' PsiDDo];
else
    [obj.K]=obj.kernelMatrix.buildMatrix(paraValIn);
    %remove missing data
    if obj.checkMiss
        obj.K=obj.missData.removeRM(obj.K);
    end
    %
    obj.PsiT=[obj.K -obj.K;-obj.K obj.K];
end
%
K=obj.K;
%
end