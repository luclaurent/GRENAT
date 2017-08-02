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
        missData;           % structure for missing data
        %
        polyOrder=0;        %polynomial order
        %
        beta=[];            %vector of the regressors
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
        forceGrad=false;     % flag for forcing the computation of 1st and énd derivatives of the kernel matrix
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
        function obj=LS(samplingIn,respIn,gradIn,missData)
            %load data
            obj.sampling=samplingIn;
            obj.resp=respIn;
            if nargin>2;obj.grad=gradIn;end
            if nargin>3;obj.missData=missData;end
            %if everything is ok then train
            if obj.checkAll; obj.train();end
        end
        
        %% setters
        
        %% getters
        function nS=get.nS(obj)
            nS=numel(obj.resp);
        end
        function nP=get.nP(obj)
            nP=size(obj.sampling,2);
        end
        
        %% check if gradients are available
        function flagG=checkGrad(obj)
            flagG=~isempty(obj.grad);
            obj.flagGLS=flagG;
        end
        
        %% prepare data for building (deal with missing data)
        function setData(obj)
            
        end
        
        %% Building/training metamodel
        function train()
            obj.showInfo('start');
        end
        
        %% Update metamodel
        function update()
            
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