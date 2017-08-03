%% class for least-squares surrogate model
% LS: Least-Squares
% GLS: gradient-base Least Squares
% L. LAURENT -- 31/07/2017 -- luc.laurent@lecnam.net

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

classdef LS < handle
    properties
        sampling=[];        % sample points
        resp=[];            % sample responses
        grad=[];            % sample gradients
        %
        missData;           % class for missing data
        %
        YY=[];              % vector of responses (and gradients)
        %
        polyOrder=0;        % polynomial order
        %
        beta=[];            % vector of the regressors
        valFunPoly=[];      % matrix of the evaluation of the monomial terms
        nbMonomialTerms=0;  % number of monomial terms
    end
    
    properties (Access = private)
        respV=[];            % responses prepared for training
        gradV=[];            % gradients prepared for training
        %
        flagGLS=false;       % flag for computing matrices with gradients
        parallelW=1;         % number of workers for using parallel version
        %
        requireRun=true;     % flag if a full building is required
        requireUpdate=false; % flag if an update is required
        forceGrad=false;     % flag for forcing the computation of 1st and 2nd derivatives of the kernel matrix
    end
    properties (Dependent,Access = private)
        NnS;               % number of new sample points
        nS;                 % number of sample points
        nP;               % dimension of the problem
        parallelOk=false;    % flag for using parallel version
        %
    end
    
    methods
        %% Constructor
        function obj=xLS(samplingIn,respIn,gradIn,orderIn,missData)
            %load data
            obj.sampling=samplingIn;
            obj.resp=respIn;
            if nargin>2;obj.grad=gradIn;end
            if nargin>3;obj.polyOrder=orderIn;end
            if nargin>4;obj.missData=missData;end
            %if everything is ok then train
            obj.train();
        end
        
        %% setters
        
        %% getters
        function nS=get.nS(obj)
            nS=numel(obj.resp);
        end
        function nP=get.nP(obj)
            nP=size(obj.sampling,2);
        end
        
        %% getter for GLS building
        function flagG=get.flagGLS(obj)
            flagG=~isempty(obj.grad);
        end
        
        %% add new sample points, new responses and new gradients
        function addSample(obj,newS)
            obj.sampling=[obj.sampling;newS];
        end
        function addResp(obj,newR)
            obj.resp=[obj.resp;newR];
        end
        function addGrad(obj,newG)
            obj.grad=[obj.grad;newG];
        end
        
        %% check if there is missing data
        function flagM=checkMiss(obj)
            flagM=false;
            if ~isempty(obj.missData)
                flagM=obj.missData.on;
            end
        end
        
        %% prepare data for building (deal with missing data)
        function setData(obj)
            %Responses and gradients at sample points
            YYT=obj.resp;
            %remove missing response(s)
            if obj.checkMiss
                YYT=obj.missData.removeRV(YYT);
            end
            %
            der=[];
            if obj.flagGLS
                tmp=obj.grad';
                der=tmp(:);
                %remove missing gradient(s)
                if obj.checkMiss
                    der=obj.missData.removeGV(der);
                end
            end
            obj.YY=vertcat(YYT,der);
        end
        
        %% Building/training metamodel
        function train(obj)
            obj.showInfo('start');
            %Prepare data
            obj.setData;
            %Build regression matrix (for the trend model)
            
            %depending on the availability of the gradients
            if ~obj.flagGLS
                obj.valFunPoly=MultiMono(obj.sampling,obj.polyOrder);
                if obj.checkMiss
                    %remove missing response(s)
                     obj.valFunPoly=obj.missData.removeRV(obj.valFunPoly);
                end
            else
                %gradient-based
                [MatX,MatDX]=MultiMono(obj.sampling,obj.polyOrder);
                obj.valFunPoly=[MatX;MatDX];
                if obj.checkMiss
                    obj.valFunPoly=obj.missData.removeGRV(obj.valFunPoly);
                end
%                 
%                 nbMonomialTerms=size(MatX,2);
%                 if obj.checkMiss
%                     sizeResp=ns-obj.missData.nbMissResp;
%                     sizeGrad=ns*np-obj.missData.nbMissGrad;
%                     sizeTotal=sizeResp+sizeGrad;
%                 else
%                     sizeResp=ns;
%                     sizeGrad=ns*np;
%                     sizeTotal=sizeResp+sizeGrad;
%                 end
%                 %initialize regression matrix
%                 valFunPoly=zeros(sizeTotal,nbMonomialTerms);
%                 if missResp
%                     %remove missing response(s)
%                     MatX=MatX(metaData.miss.resp.ixAvail,:);
%                 end
%                 %load monomial terms of the polynomial regression
%                 valFunPoly(1:sizeResp,:)=MatX;
%                 
%                 if missGrad
%                     %remove missing gradient(s)
%                     MatDX=MatDX(missData.grad.ixt_dispo_line,:);
%                 end
%                 %add derivatives to the regression matrix
%                 valFunPoly(sizeResp+1:end,:)=MatDX;
            end
            obj.nbMonomialTerms=size(obj.valFunPoly,2);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %determine regressors
            fct=obj.valFunPoly'*obj.valFunPoly;
            fcY=obj.valFunPoly'*obj.YY;
            %deal with unsifficent number of equations
            if obj.nbMonomialTerms>size(obj.YY,1)
                Gfprintf(' > !! matrix ill-conditionned!! (use pinv)\n');
                obj.beta=pinv(fct)*fcY;
            else
                [Q,R]=qr(fct);
                obj.beta=R\(Q'*fcY);
            end
        end
        
        %% Update metamodel
        function update(obj,newSample,newResp,newGrad,newMissData)
            obj.nawSample(newSample);
            obj.newResp(newResp);
            if nargin>3;obj.addGrad(newGrad);end
            if nargin>4;obj.missData=newMissData;end
            obj.train;
        end
        
        %% Evaluation of the metamodel
        function [Z,GZ]=eval(obj,U)
            calcGrad=false;
            if nargout>1
                calcGrad=true;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %regression matrix at the non-sample points
            if calcGrad
                [ff,jf]=MultiMono(U,obj.polyOrder);
            else
                [ff]=MultiMono(U,obj.polyOrder);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %evaluation of the surrogate model at point X
            Z=ff*obj.beta;
            if calcGrad
                %%verif in 2D+
                GZ=jf*obj.beta;
            end
        end
        
        %% Show information in the console
        function showInfo(obj,type)
            switch type
                case {'start','START','Start'}
                    textd='++ Type: ';
                    textf='';
                    Gfprintf('\n%s\n',[textd 'Least-Squares ((G)LS)' textf]);
                    Gfprintf('>> Deg : %i \n',obj.polyOrder);
                    %
                    if dispTxtOnOff(obj.cv.on,'>> CV: ',[],true)
                        dispTxtOnOff(obj.cv.full,'>> Computation all CV criteria: ',[],true);
                        dispTxtOnOff(obj.cv.disp,'>> Show CV: ',[],true);
                    end
                    %
                    Gfprintf('\n');
                case {'cv','CV'}
                case {'end','End','END'}
                    
            end
        end
    end
    
end


%% function for display information
function boolOut=dispTxtOnOff(boolIn,txtInTrue,txtInFalse,returnLine)
boolOut=boolIn;
if nargin==2
    txtInFalse=[];
    returnLine=false;
elseif nargin==3
    returnLine=false;
end
if isempty(txtInFalse)
    Gfprintf('%s',txtInTrue);if boolIn; fprintf('Yes');else, fprintf('No');end
else
    if boolIn; fprintf('%s',txtInTrue);else, fprintf('%s',txtInFalse);end
end
if returnLine
    fprintf('\n');
end
end