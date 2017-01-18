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
        samplingN=[];
        respN=[];
        gradN=[];
        %evaluating
        nonsamplePts=[];
        nonsampleResp=[];
        nonsampleGrad=[];
        nonsamplePtsOrder=[];
        nonsampleRespOrder=[];
        nonsampleGradOrder=[];
        nonsamplePtsN=[];
        nonsampleRespN=[];
        nonsampleGradN=[];
        sizeNonSample=zeros(1,3);
        nonsampleVar=[];
        nonsampleVarOrder=[];
        nonsampleCI=struct('ci68',[],'ci95',[],'ci98',[]);
        nonsampleEI=[];
        %normalization data
        norm;
        normMeanS;
        normStdS;
        normMeanR;
        normStdR;
        %
        err=[];
        %reference
        sampleRef=[];
        respRef=[];
        gradRef=[];
        %structures & class for storing configuration and data
        confMeta;   %metamodel configuration
        dataTrain;  %training data
        confDisp;   %display configuration
        miss;       %missing data
    end
    properties (Dependent)
        type;
    end
    
    properties (Access = private)
        runTrain=true; %flag for checking if the training is obsolete
        runEval=true; %flag for checking if the training is obsolete
        gradAvail=false; %flag for availability of the gradients
        runErr=true; %flag for computation of the error
        normSamplePtsIn=false; %flag for checking if the input data are normalized
        normRespIn=false; %flag for checking if the input data are normalized
        runMissingData=true; %flag for checking missing data
        nbSubplot=0; %number of subplot for display
    end
    properties (Access = private,Constant)
        infoProp=affectTxtProp;
    end
    
    methods
        %construction
        function obj=GRENAT(typeIn,samplingIn,respIn,gradIn)
            %load directories on the path
            initDirGRENAT;
            %
            Gfprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n');
            Gfprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n');
            Gfprintf(' Create GRENAT Object \n');
            %the date and time
            dispDate;
            %load default configuration
            obj.confMeta=initMeta;
            %load display configuration
            obj.confDisp=initDisp;
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
        %setter for the sampling
        function set.sampling(obj,samplingIn)
            if ~isempty(samplingIn)
                if isempty(obj.sampling)
                    obj.sampling=samplingIn;
                else
                    obj.sampling=[obj.sampling;samplingIn];
                end
                initRunTrain(obj,true);
                resetNorm(obj);
                initData(obj,'Sampling');
            else
                fprintf('ERROR: Empty array of sample points\n');
            end
        end
        %setter for the responses
        function set.resp(obj,respIn)
            if ~isempty(respIn)
                if isempty(obj.resp)
                    obj.resp=respIn;
                else
                    obj.resp=[obj.resp;respIn];
                end
                initRunTrain(obj,true);
                initData(obj,'Resp');
            else
                fprintf('ERROR: Empty array of responses\n');
            end
        end
        %setter for the gradients
        function set.grad(obj,gradIn)
            if ~isempty(gradIn)
                if isempty(obj.grad)
                    obj.grad=gradIn;
                else
                    obj.grad=[obj.grad;gradIn];
                end
                initRunTrain(obj,true);
                initGradAvail(obj,true);
                initData(obj,'Grad');
            end
        end
        %setter for the non sample points
        function set.nonsamplePts(obj,samplingIn)
            if ~isempty(samplingIn)
                obj.nonsamplePts=samplingIn;
                initRunEval(obj,true);
            end
        end
        %setter for the type of metamodel
        function set.type(obj,typeIn)
            obj.confMeta.type=typeIn;
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
        %setter for the non sample points
        function PtS=get.nonsamplePtsOrder(obj)
            PtS=orderData(obj,obj.nonsamplePts,'sampleIn');
        end
        %getter for the responses at the non sample points
        function Z=get.nonsampleResp(obj)
            if obj.runEval;eval(obj);end
            Z=orderData(obj,obj.nonsampleRespOrder,'respOut');
        end
        %getter for the gradients at the non sample points
        function GZ=get.nonsampleGrad(obj)
            if obj.runEval;eval(obj);end
            GZ=orderData(obj,obj.nonsampleGradOrder,'gradOut');
        end
        %getter for the variance at the non sample points
        function variance=get.nonsampleVar(obj)
            if obj.runEval;eval(obj);end
            variance=orderData(obj,obj.nonsampleVarOrder,'respOut');
        end
        %getter for error values
        function err=get.err(obj)
            if obj.runErr;errCalc(obj);end
            err=obj.err;
        end
        %getter for normalization data structure
        function normStruct=get.norm(obj)
            normStruct.sampling.mean=obj.normMeanS;
            normStruct.sampling.std=obj.normStdS;
            normStruct.resp.mean=obj.normMeanR;
            normStruct.resp.std=obj.normStdR;
            normStruct.on=obj.confMeta.normOn;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %initialize flags
        function initRunTrain(obj,flag)
            obj.runTrain=flag;
        end
        function initGradAvail(obj,flag)
            obj.gradAvail=flag;
        end
        function initRunEval(obj,flag)
            obj.runEval=flag;
        end
        %initialize data (remove saved data)
        function initData(obj,type)
            if nargin==1
                obj.sampling=[];
                obj.resp=[];
                obj.grad=[];
            elseif nargin==2
                switch type
                    case 'Sampling'
                        obj.samplingN=obj.sampling;
                    case 'Resp'
                        obj.respN=obj.resp;
                    case 'Grad'
                        obj.gradN=obj.grad;
                end
            end
        end
        %ordering data (for manipulating nd-arrays)
        function dataOut=orderData(obj,dataIn,type)
            switch type
                case 'sampleIn'
                    %size of the input data
                    obj.sizeNonSample=[size(dataIn,1),size(dataIn,2),size(dataIn,3)];
                    %in the case of nd-array
                    if obj.sizeNonSample(3)>1
                        dataOut=reshape(dataIn,[ obj.sizeNonSample(1)*obj.sizeNonSample(2),obj.sizeNonSample(3),1]);
                    else
                        dataOut=dataIn;
                    end
                case 'sampleOut'
                    if obj.sizeNonSample(3)>1
                        dataOut=reshape(dataIn,[ obj.sizeNonSample(1),obj.sizeNonSample(2),obj.sizeNonSample(3)]);
                    else
                        dataOut=dataIn;
                    end
                case 'respOut'
                    if obj.sizeNonSample(3)>1
                        dataOut=reshape(dataIn,[ obj.sizeNonSample(1),obj.sizeNonSample(2)]);
                    else
                        dataOut=dataIn;
                    end
                case 'gradOut'
                    if obj.sizeNonSample(3)>1
                        dataOut=reshape(dataIn,[ obj.sizeNonSample(1),obj.sizeNonSample(2),obj.sizeNonSample(3)]);
                    else
                        dataOut=dataIn;
                    end
            end
        end
        %Normalization of the input data
        function dataOut=normInputData(obj,type,dataIn)
            if obj.confMeta.normOn
                %preparing data structures
                infoDataS=obj.norm.sampling;
                infoDataR=obj.norm.resp;
                %for various situations
                switch type
                    case 'initSamplePts'
                        [obj.samplingN,infoDataS]=NormRenorm(obj.sampling,'norm');
                        obj.normMeanS=infoDataS.mean;
                        obj.normStdS=infoDataS.std;
                        obj.normSamplePtsIn=true;
                    case 'initResp'
                        [obj.respN,infoDataR]=NormRenorm(obj.resp,'norm');
                        obj.normMeanR=infoDataR.mean;
                        obj.normStdR=infoDataR.std;
                        obj.normRespIn=true;
                    case 'SamplePts'
                        dataOut=NormRenorm(dataIn,'norm',infoDataS);
                    case 'Resp'
                        dataOut=NormRenorm(dataIn,'norm',infoDataR);
                    case 'Grad'
                        if ~isempty(dataIn)
                            dataOut=NormRenormG(dataIn,'norm',infoDataS,infoDataR);
                        else
                            dataOut=[];
                        end
                end
            else
                if nargin>2
                    dataOut=dataIn;
                end
            end
        end
        %ReNormalization of the input data
        function dataOut=reNormInputData(obj,type,dataIn)
            if obj.confMeta.normOn
                %preparing data structures
                infoDataS=obj.norm.sampling;
                infoDataR=obj.norm.resp;
                %for various situations
                switch type
                    case 'SamplePts'
                        dataOut=NormRenorm(dataIn,'renorm',infoDataS);
                    case 'Resp'
                        dataOut=NormRenorm(dataIn,'renorm',infoDataR);
                    case 'Grad'
                        dataOut=NormRenormG(dataIn,'renorm',infoDataS,infoDataR);
                end
            else
                if nargin>2
                    dataOut=dataIn;
                end
            end
        end
        %reset normalisation state
        function resetNorm(obj)
            obj.normSamplePtsIn=false;
            obj.normRespIn=false;
        end
        %check missing data
        function checkMissingData(obj)
            %Check input data (find missing data)
            obj.confMeta.miss=CheckInputData(obj.samplingN,obj.respN,obj.gradN);
            obj.runMissingData=false;
        end
        %define the configuration for the display
        function defineDisp(obj,varargin)
            % look up the previous value
            obj.confDisp.conf(varargin{:});
        end
        %train the metamodel
        function train(obj)
            %normalization of the input data
            normInputData(obj,'initSamplePts');
            normInputData(obj,'initResp');
            obj.gradN=normInputData(obj,'Grad',obj.grad);
            %check if data are missing
            checkMissingData(obj);
            %store normalization data
            obj.confMeta.norm=obj.norm;
            %train surrogate model
            obj.dataTrain=BuildMeta(obj.samplingN,obj.respN,obj.gradN,obj.confMeta);
            %save estimate parameters
            obj.confMeta.definePara(obj.dataTrain.build.para);
            obj.confMeta.updatePara;
            %change state of flags
            obj.runTrain=false;
            obj.runErr=true;
            
            % keyboard
            % if metaData.norm.on&&~isempty(metaData.norm.resp.std)
            %     ret.build.sig2=ret.build.sig2*metaData.norm.resp.std^2;
            % end
        end
        %update the metamodel by adding sample points and associated
        %responses and gradients
        function update(obj,samplingIn,respIn,gradIn,paraFind,varargin)
            %add data
            if ~isempty(samplingIn)
                obj.sampling=samplingIn;
                obj.resp=respIn;
                obj.grad=gradIn;
                %initialize flags
                initRunTrain(obj,true);
                initRunEval(obj,true);
                %change status of the estimation of the parameters
                obj.confMeta.conf('estimOn',paraFind);
                %deal with additional options
                if nargin>5;
                    obj.confMeta.conf(varargin{:});
                end
                %train the metamodel
                obj.train();
            end
        end
        %evaluate the metamodel
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
        %check interpolation
        function [ZI,detI]=evalInfill(obj,nonsamplePts,Verb)
            if nargin<3;Verb=true;end
            %store non sample points
            if nargin>1;obj.nonsamplePts=nonsamplePts;end
            %evaluation
            obj.eval([],Verb);
            %smallest response
            respMin=min(obj.resp);
            %computation of infill criteria
            ZI=[];
            if ~isempty(obj.nonsampleVar)
                [ZI,detI]=InfillCrit(respMin,obj.nonsampleResp,obj.nonsampleVar,obj.confMeta.infill);
            end
        end
        %check interpolation
        function [statusR,statusG]=checkInterp(obj)
            statusG=true;
            %evaluation of the approximation at the sample points
            [Z,GZ]=obj.eval(obj.sampling);
            %check interpolation
            statusR=checkInterpRG(obj.resp,Z,'resp');
            if  obj.dataTrain.used.availGrad
                statusG=checkInterpRG(obj.grad,GZ,'grad');
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
                fprintf('or defineref(''sampleRef'',val1,''respRef'',val2,''gradRef'',val3)\n')
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
                elseif all(nbGRef==nbSRef)
                    okGrad=true;
                end
            end
            okAll=okSample&&okResp&&okGrad;
            %display error messages
            if ~okSample;Gfprintf('>> Wrong definition of the reference sample points\n');end
            if ~okResp;Gfprintf('>> Wrong definition of the reference responses\n');end
            if ~okGrad;Gfprintf('>> Wrong definition of the reference gradients\n');end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %define properties
        function conf(obj,varargin)
            %list properties
            listProp=properties(obj);
            okConf=false;
            %if a input variable is specified
            if nargin>2
                %if the number of input argument is even
                if  mod(nargin-1,2)==0
                    %along the argument
                    for itV=1:2:nargin-1
                        %extract keyword and associated value
                        keyW=varargin{itV};
                        keyV=varargin{itV+1};
                        %if the first argument is a string
                        if isa(varargin{1},'char')
                            %check if the keyword is acceptable
                            if ismember(keyW,listProp)
                                okConf=true;
                                obj.(keyW)=keyV;
                            else
                                fprintf('>> Wrong keyword ''%s''\n',keyW);
                            end
                        end
                    end
                end
                if ~okConf
                    Gfprintf('\nWrong syntax used for conf method\n');
                    Gfprintf('use: conf(''key1'',val1,''key2'',val2...)\n');
                    Gfprintf('\nList of the available keywords:\n');
                    dispTableTwoColumnsStruct(listProp,obj.infoProp);
                end
            else
                fprintf('Current configuration\n');
                disp(obj);
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %display the surrogate model
        function show(obj,varargin)
            %depending of the kind of data
            if obj.sizeNonSample(3)==2
                obj.confDisp.conf('d3',true,'contour',true);
                %if argument
                if nargin>1;obj.confDisp.conf(varargin{:});end
                show2D(obj);
            elseif obj.sizeNonSample(3)==1
                obj.confDisp.conf('d3',false,'d2',false);
                %if argument
                if nargin>1;obj.confDisp.conf(varargin{:});end
                show1D(obj);
            end
        end
        function show1D(obj)
            figure;
            %depend if the reference is available or not
            if checkRef(obj)
                obj.nbSubplot=231;
                subplot(obj.nbSubplot);
                obj.confDisp.conf('samplePts',true,'sampleGrad',false);
                showRespRef(obj);
                obj.nbSubplot=obj.nbSubplot+1;subplot(obj.nbSubplot)
                %remove display of sample points
                obj.confDisp.conf('samplePts',true,'sampleGrad',true);
                showGradRef(obj);
                obj.nbSubplot=obj.nbSubplot+1;
            else
                obj.nbSubplot=221;
            end
            obj.nbSubplot=obj.nbSubplot+1;subplot(obj.nbSubplot);
            obj.confDisp.conf('samplePts',true,'sampleGrad',false);
            showResp(obj);
            obj.nbSubplot=obj.nbSubplot+1;subplot(obj.nbSubplot);
            %remove display of sample points
            obj.confDisp.conf('samplePts',true,'sampleGrad',true);
            showGrad(obj);
            obj.nbSubplot=obj.nbSubplot+1;subplot(obj.nbSubplot);
            showCI(obj,[]);
        end
        function show2D(obj)
            figure;
            %depend if the reference is available or not
            if checkRef(obj);
                obj.nbSubplot=331;
                subplot(obj.nbSubplot);
                obj.confDisp.conf('samplePts',true);
                showRespRef(obj);
                obj.nbSubplot=obj.nbSubplot+1;subplot(obj.nbSubplot)
                %remove display of sample points
                obj.confDisp.conf('samplePts',false,'sampleGrad',false);
                showGradRef(obj,1);
                obj.nbSubplot=obj.nbSubplot+1;subplot(obj.nbSubplot)
                showGradRef(obj,2);
            else
                obj.nbSubplot=231;
            end
            obj.nbSubplot=obj.nbSubplot+1;subplot(obj.nbSubplot);
            obj.confDisp.conf('samplePts',true);
            showResp(obj);
            obj.nbSubplot=obj.nbSubplot+1;subplot(obj.nbSubplot);
            %remove display of sample points
            obj.confDisp.conf('samplePts',false,'sampleGrad',false,'gridGrad',false);
            showGrad(obj,1);
            obj.nbSubplot=obj.nbSubplot+1;subplot(obj.nbSubplot);
            showGrad(obj,2);
            obj.nbSubplot=obj.nbSubplot+1;subplot(obj.nbSubplot);
            showCI(obj,[]);
        end
        %display the reference surface
        function showRespRef(obj)
            obj.confDisp.title=('Reference');
            displaySurrogate(obj.sampleRef,obj.respRef,obj.sampling,obj.resp,obj.grad,obj.confDisp);
        end
        %display the reference gradients surface
        function showGradRef(obj,nbG)
            %default value
            if nargin==1;nbG=1;end
            obj.confDisp.title=(['Gradients Reference /x' num2str(nbG)]);
            displaySurrogate(obj.sampleRef,obj.gradRef(:,:,nbG),obj.sampling,obj.resp,obj.grad,obj.confDisp);
        end
        %display the response approximated by the metamodel
        function showResp(obj)
            obj.confDisp.title=('Approximated responses');
            displaySurrogate(obj.nonsamplePts,obj.nonsampleResp,obj.sampling,obj.resp,obj.grad,obj.confDisp);
        end
        %display the gradients approximated by the metamodel
        function showGrad(obj,nbG)
            %default value
            if nargin==1;nbG=1;end
            obj.confDisp.title=(['Approximated gradients /x' num2str(nbG)]);
            displaySurrogate(obj.nonsamplePts,obj.nonsampleGrad(:,:,nbG),obj.sampling,obj.resp,obj.grad,obj.confDisp);
        end
        %display the confidence intervals approximated by the metamodel
        function showCI(obj,ciVal,nonsamplePts)
            %type of confidence intervals
            ciOk=false;ciValDef=95;
            if nargin>1;if ~isempty(ciVal);if ismember(ciVal,[68,95,99]);ciOk=true;end, end, end
            if ~ciOk;ciVal=ciValDef;end
            %store non sample points
            if nargin>2;obj.nonsamplePts=nonsamplePts;end
            obj.confDisp.title=([num2str(ciVal) '% confidence intervals']);
            %evaluation of the confidence interval
            evalCI(obj);
            %load data to display
            ciDisp=obj.nonsampleCI.(['ci' num2str(ciVal)]);
            %display the CI
            displaySurrogateCI(obj.nonsamplePts,ciDisp,obj.confDisp,obj.nonsampleResp);
        end
        %overload isfield
        function isF=isfield(obj,field)
            isF=isprop(obj,field);
        end
    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function for declaring the purpose of each properties
function info=affectTxtProp()
info.type='Type of the surrogate model';
info.sampling='Coordinates of the sample points';
info.resp='Value(s) of the responses at the sample points';
info.grad='Value(s) of the gradients at the sample points';
info.samplingN='Normalized coordinates of the sample points';
info.respN='Value(s) of the normalized responses at the sample points';
info.gradN='Value(s) of the normalized gradients at the sample points';
info.nonsamplePts='Coordinates of the non-sample points';
info.nonsampleResp='Value(s) of the approximated responses calculated at the non-sample points';
info.nonsampleGrad='Value(s) of the approximated gradients calculated at the non-sample points';
info.nonsamplePtsN='Normalized coordinates of the  non-sample points';
info.nonsampleRespN='Value(s) of the normalized approximated responses calculated at the non-sample points';
info.nonsampleGradN='Value(s) of the normalized approximated gradients calculated at the non-sample points';
info.nonsampleVar='Value(s) of the variance calculated at the non-sample points';
info.nonsampleCI='Structure containing the bounds of the confidence intervals (68%, 95%, 99%)';
info.nonsampleEI='Value(s) of the expected improvment calculated at the non-sample points';
info.norm='Structure containing the normalization data';
info.normMeanS='Mean value of the sample points (vector)';
info.normStdS='Standard deviation of the sample points (vector)';
info.normMeanR='Mean value of the responses';
info.normStdR='Standard deviation of the responses';
info.err='Structure containing the values of the error criteria';
info.sampleRef='Array of the sample points used for the reference response surface';
info.respRef='Array of the responses of the reference response surface';
info.gradRef='Array of the gradients of the reference response surface';
info.confMeta='Class object (initMeta) containing information about the configuration (metamodel) (conf method for modifying it)';
info.dataTrain='Structures containing data about the training of the surrogate model';
info.confDisp='Class object (initDisp) containing information about the display (conf method for modifying it)';
info.miss='Structure Containing information about the missing data';
end

%function display table with two columns of text
function dispTableTwoColumnsStruct(tableFiedIn,structIn)
%size of every components in tableA
sizeA=cellfun(@numel,tableFiedIn);
maxA=max(sizeA);
%space after each component
spaceA=maxA-sizeA+3;
spaceTxt=' ';
%display table
for itT=1:numel(tableFiedIn)
    if isfield(structIn,tableFiedIn{itT})
        fprintf('%s%s%s\n',tableFiedIn{itT},spaceTxt(ones(1,spaceA(itT))),structIn.(tableFiedIn{itT}));
    end
end
end

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
