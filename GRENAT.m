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
        sampleRef=[];
        respRef=[];
        gradRef=[];
    end
    properties (Dependent)
        type;
    end
    
    properties (Constant)
        typeAvail={};
        typeTxt={};
    end
    properties (Access = private)
        runTrain=true; %flag for checking if the training is obsolete
        runEval=true; %flag for checking if the training is obsolete
        gradAvail=false; %flag for availability of the gradients
        runErr=true; %flag for computation of the error 
    end
    
    methods
        %construction
        function obj=GRENAT(typeIn,samplingIn,respIn,gradIn)
            fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n');
            fprintf(' Create GRENAT Object \n')
            %the date and time
            dispDate;
            %load directories on the path
            initDirGRENAT;
            %specific configuration
            if nargin>0;obj.confMeta.type=typeIn;end
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
                    % simply assign the fields you don't care about
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
            if ~isempty(samplingIn)
                obj.nonsamplePts=samplingIn;
                obj.runEval=true;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %getter for the type of metamodel
        function type=get.type(obj)
            type=obj.confMeta.type;
        end
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
        %getter for error values
        function err=get.err(obj)
            if obj.runErr;errCalc(obj);end
            err=obj.err;
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
            obj.runErr=true;
        end
        %evaluate the metamodel
        function [Z,GZ,variance]=eval(obj,nonsamplePts)
            %check if the metamodel has been already trained
            if obj.runTrain;train(obj);end
            %store non sample points
            if nargin>1;obj.nonsamplePts=nonsamplePts;end
            %evaluation of the metamodels
            if obj.runEval
                [K]=EvalMeta(obj.nonsamplePts,obj.dataTrain);
                obj.runEval=false;
                obj.runErr=true;
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
        function [ci68,ci95,ci99]=evalCI(obj,nonsamplePts)
            %store non sample points
            if nargin>1;obj.nonsamplePts=nonsamplePts;end
            %eval the CI
            [ci68,ci95,ci99]=BuildCI(obj.nonsampleResp,obj.nonsampleVar);
            obj.nonsampleCI.ci68=ci68;
            obj.nonsampleCI.ci95=ci95;
            obj.nonsampleCI.ci99=ci99;
        end
        %extract CI
        function [ci68,ci95,ci99]=CI(obj,nonsamplePts)
            %store non sample points
            if nargin>1;obj.nonsamplePts=nonsamplePts;end
            %eval the CI
            [ci68,ci95,ci99]=BuildCI(obj.nonsampleResp,obj.nonsampleVar);
            obj.nonsampleCI.ci68=ci68;
            obj.nonsampleCI.ci95=ci95;
            obj.nonsampleCI.ci99=ci99;
        end
        %compute and show the errors of the metamodel (using reference if it is
        %available)
        function errCalc(obj)
            obj.err=critErrDisp(obj.nonsampleResp,obj.respRef,obj.dataTrain.build);
            obj.runErr=false;
        end
        %define the reference surface
        function defineRef(obj,varargin)
            %accepted keyword
            keyOk={'sampleRef','respRef','gradRef'};
            %two kind of input variables list (with keywords or not)
            %depend on the first argument: double for classical list of
            %argument or string if the use of keywords
            execOk=true;
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
        %check if all data is available for displaying the reference
        %surface and gradients
        function [okAll,okSample,okResp,okGrad]=checkRef(obj)
            okSample=false;
            okResp=false;
            okGrad=false;
            nbSRef(1)=size(obj.sampleRef,1);
            nbSRef(2)=size(obj.sampleRef,2);
            nbSRef(3)=size(obj.sampleRef,3);
            nbRRef(1)=size(obj.respRef,1);
            nbRRef(2)=size(obj.respRef,2);
            nbRRef(3)=size(obj.respRef,3);
            nbGRef(1)=size(obj.gradRef,1);
            nbGRef(2)=size(obj.gradRef,2);
            nbGRef(3)=size(obj.gradRef,3);
            if sum(nbSRef(:))~=0
                okSample=true;
                if nbSRef(1)==nbRRef(1)
                    okResp=true;
                end
                if nbGRef(3)==1
                    if nbGRef(1)==nbSRef(1)&&nbGRef(2)==nbSRef(2)
                        okGrad=true;
                    end
                elseif nbGRef(3)==nbSRef(2)&&nbGRef(1)==nbSRef(1)
                    okGrad=true;
                end
            end
            okAll=okSample&&okResp&&okGrad;
            %display error messages
            if ~okSample;fprintf('>> Wrong definition of the reference sample points\n');end
            if ~okResp;fprintf('>> Wrong definition of the reference responses\n');end
            if ~okGrad;fprintf('>> Wrong definition of the reference gradients\n');end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %display the surrogate model
        function show(obj,nonsamplePts)
            if nargin==1;nonsamplePts=[];end
            %store non sample points
            figure;
            %depend if the reference is available or not
            if checkRef(obj);
                nbSubplot=231;
                subplot(nbSubplot)                
                showRespRef(obj);
                nbSubplot=nbSubplot+1;subplot(nbSubplot)
                showGradRef(obj);
            else
                nbSubplot=221;
            end
            nbSubplot=nbSubplot+1;subplot(nbSubplot)
            showResp(obj,nonsamplePts);
            nbSubplot=nbSubplot+1;subplot(nbSubplot)
            showGrad(obj,nonsamplePts);
            nbSubplot=nbSubplot+1;subplot(nbSubplot)
            showCI(obj,nonsamplePts);
        end
        %display the reference surface
        function showRespRef(obj,varargin)
            %store non sample points
            if nargin>1;defineRef(obj,varargin{:});end
            obj.dispData.title=('Reference');
            displaySurrogate(obj.sampleRef,obj.respRef,obj.sampling,obj.resp,obj.grad,obj.dispData);
        end
        %display the reference gradients surface
        function showGradRef(obj,varargin)
            %store non sample points
            if nargin>1;defineRef(obj,varargin{:});end
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
        %display the gradients approximated by the metamodel
        function showGrad(obj,nonsamplePts)
            %store non sample points
            if nargin>1;obj.nonsamplePts=nonsamplePts;end
            obj.dispData.title=('Approximated gradients');
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
            %evaluation of the confidence interval
            evalCI(obj);
            %load data to display
            ciDisp=obj.nonsampleCI.(['ci' num2str(ciVal)]);
            %display the CI
            displaySurrogateCI(obj.nonsamplePts,ciDisp,obj.dispData,obj.nonsampleResp);
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
