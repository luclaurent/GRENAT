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
% - evalPts: evaluation points
% - Verb: activate verbose mode
% OUTPUTS:
% - Z: approximate responses
% - GZ: approximate gradients
% - variance: variance of the metamodel

function [Z,GZ,variance]=eval(obj,evalPts,Verb)
%
countTime=mesuTime;
%
numWorkers=1;
%
if nargin<3;Verb=true;end
%check if the metamodel has been already trained
if obj.runTrain;train(obj);end
%store non sample points
if nargin>1;obj.nonSamplePts=evalPts;end
%evaluation of the metamodels
if obj.runEval
    %declare variables
    NnS=size(obj.nonSamplePts,1);
    NnP=size(obj.nonSamplePts,2);
    %
    %end of evaluations
    if Verb
        Gfprintf('++ Evaluation at %i points\n',NnS);
    end
    %
    Ztmp=zeros(NnS,1);
    GZtmp=zeros(NnS,NnP);
    VarTmp=zeros(NnS,1);
    %Store the evaluation points
    NonSamplePtsTmp=obj.nonSamplePts;
    %Store the function for evaluation
    funEval=@(x)obj.dataTrain.eval(x);
    %check if variance could be computed
    flagVar=false;
    if isprop(obj.dataTrain,'computeVariance')
        flagVar=true;
        funVar=@(x)obj.dataTrain.computeVariance(x);
    end
    %Store the function for computing variance
    for itS=1:NnS
        %current points
        currPts=NonSamplePtsTmp(itS,:);
        %evaluation of the metamodel
        if flagVar
            [Ztmp(itS),GZtmp(itS,:),VarTmp(itS)]=funEval(currPts);
        else
            [Ztmp(itS),GZtmp(itS,:)]=funEval(currPts);
        end
    end
    %store data from the evaluation
    obj.nonSampleRespN=Ztmp;
    obj.nonSampleGradN=GZtmp;
    obj.nonSampleVarN=VarTmp;
    %update flags
    obj.runEval=false;
    obj.runErr=true;
end
%extract unnormalized data
Z=obj.nonSampleResp;
GZ=obj.nonSampleGrad;
variance=obj.nonSampleVar;
%
countTime.stop;
%
end