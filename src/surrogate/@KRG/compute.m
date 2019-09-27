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


%% Build factorization, solve the kriging problem and evaluate the log-likelihood
% INPUTS:
% - paraValIn: value of the hyperparameters
% OUTPUTS:
% - detK,logDetK: determinant and log of the determinant of the kernel
% matrix

function [detK,logDetK]=compute(obj,paraValIn)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition of the hyper-parameters
if nargin>1
    [~,~,paraValOk,...
        ~,~,~]=definePara(...
        obj.nP,...
        obj.metaData.kern,...
        paraValIn,...
        [],...
        'check');
    %store value of parameters
    obj.paraVal=paraValOk;
else
    paraValOk=obj.paraVal;
end
%
if obj.requireCompute
    %build the kernel Matrix
    obj.buildMatrix(paraValOk);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Factorization of the matrix
    switch obj.factK
        case 'QR'
            [detK,logDetK]=obj.coreQR;
        case 'LU'
            [detK,logDetK]=obj.coreLU;
        case 'LL'
            [detK,logDetK]=obj.coreLL;
        otherwise
            [detK,logDetK]=obj.coreClassical;
    end
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %variance of the Gaussian process
    sizeK=size(obj.K,1);
    obj.sig2=1/sizeK*...
        ((obj.YYtot-obj.krgLS.XX*obj.beta)'*obj.gamma);
    %obj.sig2
    if obj.sig2<0
        keyboard
    end
end
end
