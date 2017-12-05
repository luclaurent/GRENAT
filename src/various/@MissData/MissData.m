%% class for checking input data for finding missing information
% L. LAURENT -- 02/08/2017 -- luc.laurent@lecnam.net

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
        NnS=0;                      % number of new sample points
    end
    properties (Access = private)
       requireCheckResp=true;       % flag if the checking of responses is required 
       requireCheckGrad=true;       % flag if the checking of gradients is required
    end
    properties (Dependent,Access = private)
        %
        nS;                         % number of sample points
        nP;                         % dimension of the problem
        %
        emptyGrad;                  % flag for empty gradient matrix
        %
    end
    properties (Dependent)
        on;                         % flag for missing data
        onNew;                      % flag for missing data in the new added data
        onResp;                     % flag for missing data in responses
        onGrad;                     % flag for missing data in gradients
        onNewResp;                  % flag for missing data in new responses
        onNewGrad;                  % flag for missing data in new gradients
    end
    methods
        %% constructor
        % samplingIn: array of sample points
        % respIn: vector of responses
        % gradIn: array of gradients (optional)
        function obj=MissData(samplingIn,respIn,gradIn)
            %initialize class
            if nargin>0;obj.sampling=samplingIn;end
            if nargin>1;obj.resp=respIn;end
            if nargin>2;obj.grad=gradIn;end
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
        
        %% Add new data to the database
        addData(obj,samplingIn,respIn,gradIn);
        %% Add new gradients to the database
        addGrad(obj,in);
        %% Add new responses to the database
        addResp(obj,in);
        %% Add new sample points to the database
        addSampling(obj,in);
        %% Check database and display
        check(obj,type);
        %% Check missing data in gradients (specified in input as NaN as component)
        iX=checkGrad(obj,gradIn);
        %% Check missing data in responses (specified in input as NaN)
        iX=checkResp(obj,respIn);
        %% Remove missing data in matrix (gradients)
        VV=removeGM(obj,V,type);
        %% Remove missing data in matrix (responses+gradients)
        VV=removeGRM(obj,V,type);
        %% Remove missing data in vector (responses+gradients)
        VV=removeGRV(obj,V,type);
        %% Remove missing data in vector (gradients)
        VV=removeGV(obj,V,type);
        %% Remove missing data in matrix (responses)
        VV=removeRM(obj,V,type);
        %% Remove missing data in vector (responses)
        VV=removeRV(obj,V,type);
        %% Display information concerning missing data
        show(obj);
    end
end
