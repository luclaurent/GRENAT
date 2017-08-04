%% class for checking input data for finding missing information
% L. LAURENT -- 02/08/2017 -- luc.laurent@lecnam.net

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

classdef MissData < handle
    properties
        verbose=true;               % display information or note
        %
        sampling=[];                % sample points
        resp=[];                    % sample responses
        grad=[];                    % sample gradients
        %
        maskResp=[];                % mask of non-nan responses
        nbMissResp=0;               % number of missing responses
        ixMissResp=[];              % indices of the missing responses
        ixAvailResp;                % indices of available responses
        missRespAll=false;          % flag at true if all responses are missing
        %
        maskGrad=[];                % mask of non-nan gradients
        nbMissGrad=0;               % number of missing gradients
        ixMissGrad=[];              % indices of the missing gradients
        ixAvailGrad;                % indices of available gradients
        ixMissGradLine=[];          % linear indices of the missing gradients
        ixAvailGradLine;            % linear indices of available gradients
        missGradAll=false;          % flag at true if all gradients are missing
        %
        newResp;                    % structure for new responses 
        newGrad;                    % structure for new gradients
        %
        NnS=0;                    % number of new sample points
    end
    properties (Dependent,Access = private)
        %
        nS;                     % number of sample points
        nP;                     % dimension of the problem
        %
        emptyGrad;              % flag for empty gradient matrix
        %
    end
    properties (Dependent)
        on;                     % flag for missing data
        onNew;                  % flag for missing data in the new added data
        onResp;                 % flag for missing data in responses
        onGrad;                 % flag for missing data in gradients
        onNewResp;                 % flag for missing data in new responses
        onNewGrad;                 % flag for missing data in new gradients
    end
    methods
        %% constructor
        function obj=MissData(samplingIn,respIn,gradIn)
            %initialize class
            obj.sampling=samplingIn;
            obj.resp=respIn;
            if nargin>2
                obj.grad=gradIn;
            end
            %
            obj.check();
        end
        %% getters
        function n=get.nP(obj)
            n=size(obj.sampling,2);
        end
        function n=get.nS(obj)
            n=size(obj.sampling,1);
        end
        function f=get.emptyGrad(obj)
            f=isempty(obj.grad);
        end
        function f=get.onResp(obj)
            f=(obj.nbMissResp~=0);
        end
        function f=get.onGrad(obj)
            f=(obj.nbMissGrad~=0);
        end
        function f=get.on(obj)
            f=(obj.onResp||obj.onGrad);
        end
        function f=get.onNewResp(obj)
            f=false;
            if ~isempty(obj.newResp);f=(obj.newResp.nbMissResp~=0);end
        end
        function f=get.onNewGrad(obj)
             f=false;
            if ~isempty(obj.newGrad);f=(obj.newGrad.nbMissGrad~=0);end
        end
        function f=get.onNew(obj)
            f=(obj.onNewResp||obj.onNewGrad);
        end
        
        %% add sampling, responses and gradients
        function addSampling(obj,in)
            obj.sampling=[obj.sampling;in];
            obj.NnS=size(in,1);
        end
        function addResp(obj,in)
            obj.resp=[obj.resp;in];
            obj.newResp=obj.checkResp(in);
        end
        function addGrad(obj,in)
            obj.grad=[obj.grad;in];
            obj.newGrad=obj.checkGrad(in);
        end
    end
end