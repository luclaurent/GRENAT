%% GRENAT class for manipulating gradient-enhanced metamodels
% L. LAURENT -- 26/06/2016 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016  Luc LAURENT <luc.laurent@lecnam.net>
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

classdef GRENAT < handle
    
    properties
        %building
        sampling=[];
        resp=[];
        grad=[];
        confMeta=initMeta;%load default configuration
        type=confMeta.type;
        %training
        dataTrain;
        %evaluating
        nonsamplePts=[];
        nonsampleResp=[];
        nonsampleGrad=[];
        nonsampleVar=[];
        nonsampleCI=struct('ci68',[],'ci95',[],'ci98',[]);
        nonsampleEI=[];
        err=[];
        %display data
        dispData=initDisp;
        %reference
        respRef=[];
        gradRef=[];
    end
    
    properties (Constant)
        typeAvail={};
        typeTxt={};
    end
    properties (Access = private)
        runTrain=true; %flag for checking if the training is obsolete
        runEval=true; %flag for checking if the training is obsolete
        gradAvail=false; %flag for availability of the gradients
    end
    
    methods
        %construction
        function obj=GRENAT(typeIn,samplingIn,respIn,gradIn)
            %load directories on the path
            initDirGRENAT;
            %specific configuration
            if nargin>0;obj.confMeta.type=typeIn;obj.type=typeIn;end
            if nargin>1;obj.sampling=samplingIn;end
            if nargin>2;obj.resp=respIn;end
            if nargin>3;obj.grad=gradIn;end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %setter for the type of metamodel
        function set.confMeta(obj,confIn)
            % look up the previous value
            oldVal = obj.confMeta;
            % loop through fields to check what has changed
            fields = fieldnames(confIn);
            for fn = fields(:)' %'#
                %turn cell into string for convenience
                field2check = fn{1};
                if isfield(oldVal,field2check)
                    %# simply assign the fields you don't care about
                    obj.confMeta.(field2check) = confIn.(field2check);
                end
            end
        end
        %setter for the sampling
        function set.sampling(obj,samplingIn)
            if ~isempty(samplingIn)
                obj.sampling=samplingIn;
                obj.runTrain=true;
            else
                fprintf('ERROR: Empty array of sample points\n');
            end
        end        
        %setter for the responses
        function set.resp(obj,respIn)
            if ~isempty(respIn)
                obj.resp=respIn;
                obj.runTrain=true;
            else
                fprintf('ERROR: Empty array of responses\n');
            end
        end
        %setter for the gradients
        function set.grad(obj,gradIn)
            if ~isempty(gradIn)
                obj.grad=gradIn;
                obj.runTrain=true;
                obj.gradAvail=true;
            end
        end
        %setter for the non sample points
        function set.nonsamplePts(obj,samplingIn)
            obj.nonsamplePts=samplingIn;
            obj.runEval=true;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %getter for the responses at the non sample points
        function Z=get.nonsampleResp(obj)
            if obj.runEval;eval(obj);end
            Z=obj.nonsampleResp;
        end
        %getter for the gradients at the non sample points
        function GZ=get.nonsampleGrad(obj)
            if obj.runEval;eval(obj);end
            GZ=obj.nonsampleGrad;
        end
        %getter for the variance at the non sample points
        function variance=get.nonsampleVar(obj)
            if obj.runEval;eval(obj);end
            variance=obj.nonsampleVar;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %train the metamodel
        function train(obj)
            obj.dataTrain=BuildMeta(obj.sampling,obj.resp,obj.grad,obj.confMeta);
            obj.runTrain=false;
        end
        %evaluate the metamodel
        function [Z,GZ,variance]=eval(obj,nonsamplePts)
            %store non sample points
            if nargin>1;obj.nonsamplePts=nonsamplePts;end
            %evaluation of the metamodels
            if obj.runEval
                [K]=EvalMeta(nonsamplePts,obj.dataTrain);
                obj.runEval=false;
                Z=K.Z;GZ=K.GZ;variance=K.var;
                %store data from the evaluation
                obj.nonsampleResp=Z;
                obj.nonsampleGrad=GZ;
                obj.nonsampleVar=variance;
            else
                Z=obj.nonsampleResp;
                GZ=obj.nonsampleGrad;
                variance=obj.nonsampleVar;
            end
        end
        %evaluate the CI of the metamodel
        function evalCI(obj,nonsamplePts)
            %store non sample points
            if nargin>1;obj.nonsamplePts=nonsamplePts;end
            %eval the CI
            [ci68,ci95,ci99]=BuildCI(obj.nonsampleResp,obj.nonsampleVar);
            obj.nonsampleCI.ci68=ci68;
            obj.nonsampleCI.ci95=ci95;
            obj.nonsampleCI.ci99=ci99;
        end
        %define the reference surface
        function defineRef(obj,varargin)
            %accepted keyword
            keyOk={'sampleRef','respRef','gradRef'};
            %two kind of input variables list (with keywords or not)
            %depend on the first argument: double for classical list of
            %argument or string if the use of keywords
            if isa(varargin{1},'double')
                if nargin>1;obj.sampleRef=varargin{1};obj.nonsamplePts=varargin{1};end
                if nargin>2;obj.respRef=varargin{2};end
                if nargin>3;obj.gradRef=varargin{3};end
            elseif isa(varargin{1},'char')
                if mod(nargin-1,2)==0
                    for itV=1:2:nargin-1
                        %load key and associated value
                        keyTxt=varargin{itV};
                        keyVal=varargin{itV+1};
                        %check if the keyword is usable
                        if ismember(keyTxt,keyOk)
                            %store the data
                            obj.(keyTxt)=keyVal;
                        else
                            execOk=false;
                        end
                    end
                else
                    execOk=false;
                end
            else
                execOk=false;
            end
            %display error message if wrong syntax
            if ~execOk
                fprintf('Wrong syntax for the method\n')
                fprintf('defineref(sampleRef,respRef,gradRef)\n')
                fprintf('or sortConf(''sampleRef'',val1,''respRef'',val2,''gradRef'',val3)\n')
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %display the surrogate model
        function show(obj,nonsamplePts)
            %store non sample points
            figure;
            subplot(231)
            showRespRef(obj,nonsamplePts);
            subplot(234)
            showGradRef(obj,nonsamplePts);
            subplot(232)
            showResp(obj,nonsamplePts);
            subplot(235)
            showGrad(obj,nonsamplePts);
            subplot(233)
            showCI(obj,nonsamplePts);
        end
        %display the gradients approximated by the metamodel
        function showGrad(obj,nonsamplePts)
            %store non sample points
            if nargin>1;obj.nonsamplePts=nonsamplePts;end
            obj.dispData.title=('Approximated gradients');
            displaySurrogate(obj.nonsamplePts,obj.nonsampleResp,obj.sampling,obj.resp,obj.grad,obj.dispData);
        end
        %display the reference surface
        function showRespRef(obj,varargin)
            %store non sample points
            definRef(obj,varargin);
            obj.dispData.title=('Reference');
            displaySurrogate(obj.sampleRef,obj.respRef,obj.sampling,obj.resp,obj.grad,obj.dispData);
        end
        %display the reference gradients surface
        function showGradRef(obj,varargin)
            %store non sample points
            definRef(obj,varargin);
            obj.dispData.title=('Gradients Reference');
            displaySurrogate(obj.sampleRef,obj.respRef,obj.sampling,obj.resp,obj.grad,obj.dispData);
        end
        %display the response approximated by the metamodel
        function showResp(obj,nonsamplePts)
            %store non sample points
            if nargin>1;obj.nonsamplePts=nonsamplePts;end
            obj.dispData.title=('Approximated responses');
            displaySurrogate(obj.nonsamplePts,obj.nonsampleResp,obj.sampling,obj.resp,obj.grad,obj.dispData);
        end
        %display the confidence intervals approximated by the metamodel
        function showCI(obj,ciVal,nonsamplePts)
            %type of confidence intervals
            ciOk=false;ciValDef=95;
            if nargin>1;if ~isempty(ciVal);if ismember(ciVal,[68,95,99]);ciOk=true;end, end, end
            if ~ciOk;ciVal=ciValDef;end            
            %store non sample points
            if nargin>2;obj.nonsamplePts=nonsamplePts;end
            obj.dispData.title=([num2str(ciVal) '% confidence intervals']);
            %load data to display
            ciDisp=obj.nonsampleCI.(['ci' num2str(ciVal)]);
            displaySurrogateCI(obj.nonsamplePts,ciDisp,obj.dispData,K.Z);
        end
    end    
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function display table with two columns of text
function dispTableTwoColumns(tableA,tableB)
%size of every components in tableA
sizeA=cellfun(@numel,tableA);
maxA=max(sizeA);
%space after each component
spaceA=maxA-sizeA+3;
spaceTxt=' ';
%display table
for itT=1:numel(tableA)
    fprintf('%s%s%s\n',tableA{itT},spaceTxt(ones(1,spaceA(itT))),tableB{itT});
end
end
