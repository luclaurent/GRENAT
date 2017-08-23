%% Method of GRENAT class
% L. LAURENT -- 26/06/2016 -- luc.laurent@lecnam.net

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

%% Evaluate the metamodel
% responses and gradients
% INPUTS:
% - nonsamplePts: evaluation points
% - Verb: activate verbose mode
% OUTPUTS:
% - Z: approximate responses
% - GZ: approximate gradients
% - variance: variance of the metamodel

function [Z,GZ,variance]=eval(obj,nonsamplePts,Verb)
if nargin<3;Verb=true;end
%check if the metamodel has been already trained
if obj.runTrain;train(obj);end
%store non sample points
if nargin>1;obj.nonsamplePts=nonsamplePts;end
%evaluation of the metamodels
if obj.runEval
    %normalization of the input data
    obj.nonsamplePtsN=normInputData(obj,'SamplePts',obj.nonsamplePtsOrder);
    %evaluation of the metamodel
    [K]=EvalMeta(obj.nonsamplePtsN,obj.dataTrain,obj.confMeta,Verb);
    %store data from the evaluation
    obj.nonsampleRespN=K.Z;
    obj.nonsampleGradN=K.GZ;
    obj.nonsampleVarOrder=K.var;
    %renormalization of the data
    obj.nonsampleRespOrder=reNormInputData(obj,'Resp',obj.nonsampleRespN);
    obj.nonsampleGradOrder=reNormInputData(obj,'Grad',obj.nonsampleGradN);
    %update flags
    obj.runEval=false;
    obj.runErr=true;
end
%extract unnormalized data
Z=obj.nonsampleResp;
GZ=obj.nonsampleGrad;
variance=obj.nonsampleVar;
end