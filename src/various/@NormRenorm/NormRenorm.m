%% Normalization and renormalization of the Data (class version)
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

classdef NormRenorm < handle
    properties
        %
        meanC=[];
        stdC=[];
        %
        meanN=[];
        stdN=[];
        %
        stdR=[];
        meanR=[];
        %
        stdS=[];
        meanS=[];
        %
        respN=[];
        samplingN=[];
        gradN=[];
        grad=[];
        %
        outC=[];
    end
    properties (Access = private)
        type='n';       %type of normalization ("n" normal, "r" responses, "s" sampling)
        gradNormOk=false;   % true if the available gradients have been normalized
    end
    properties (Access = private, Dependent )
        gradOk=false;       % sufficient data for normalization and renormalization of gradients
    end
    methods
        %% constructor
        % syntax:
        % - NormRenorm(inV);                    % normalize the inV array and store the data
        % as current
        % - NormRenorm(inV,type);               % normalize the inV array and store the data
        % as data specified in type (resp, sampling)
        % - NormRenorm(inV,data)                % renormalize inV using data (structure or
        % object)
        % - NormRenorm(sample,resp)             % normalize sampling and
        % responses and store them (respect order sample, resp)
        % - NormRenorm(sample,resp,data)        % renormalize sampling and
        % responses and using data (structure or object) (respect order sample, resp)
        
        function obj=NormRenorm(in,varargin)
            %% depending of the type of the input arguments
            % look for a string in the input arguments (corresponding to
            % type)
            if nargin>1
                StCl=[];
                sTxt=find(cellfun(@ischar,varargin)~=false);
                if ~isempty(sTxt);obj.type=varargin{sTxt};end
                % look for a struct or a class
                sSC=cellfun(@isstruct,varargin)||cellfun(@isobject,varargin);
                sSC=find(sSC~=false);
                if ~isempty(sSC);StCl=varargin{sSC};end
                %look for an array or a double
                sM=find(cellfun(@ismatrix,varargin)~=false);
                if ~isempty(sM);inB=varargin{sM};end
                %
                
                %if the configuration can be loaded
                if ~isempty(StCl)
                    obj.loadConf(StCl);
                end
                %case if sampling and responses are given without configuration
                if ~isempty(inB)&&isempty(StCl)
                    obj.addSampling(in);
                    obj.addResp(inB);
                else
                    obj.computeNorm(in,obj.type);
                    obj.outC=obj.Norm(in,obj.type);
                end
                %case if sampling and responses are given with configuration
                if ~isempty(inB)&&~isempty(StCl)
                    obj.outC{1}=obj.reNorm(in,'s');
                    obj.outC{2}=obj.reNorm(inB,'r');
                end
            end
            if nargin==1
                obj.computeNorm(in,obj.type);
                obj.outC=obj.Norm(in,obj.type);
            end
        end
        
        %% setters
        function set.meanN(obj,val)
            if ~isempty(val);obj.meanN=val;end
        end
        function set.meanR(obj,val)
            if ~isempty(val);obj.meanR=val;end
        end
        function set.meanS(obj,val)
            if ~isempty(val);obj.meanS=val;end
        end
        function set.stdN(obj,val)
            if ~isempty(val);obj.stdN=val;end
        end
        function set.stdR(obj,val)
            if ~isempty(val);obj.stdR=val;end
        end
        function set.stdS(obj,val)
            if ~isempty(val);obj.stdS=val;end
        end
        
        %% getter for the flag for computing gradients
        function flag=get.gradOk(obj)
            flag=(~isempty(obj.stdR)...
                &&~isempty(obj.stdS));
        end
        
        %% getter for the normalized gradients
        function out=get.gradN(obj)
            %if the data hase been already normalized, load it
            if obj.gradNormOk
                out=obj.gradN;
            else
                out=obj.NormG(obj.grad);
                obj.gradN=out;
                obj.grad=[];
            end
        end
        
        %% Initialize all data
        init(obj);
        %% Load existing information (defined using structure)
        loadConf(obj,StClIn);
        %% Compute normalization data
        computeNorm(obj,in,type);
        %% Add responses and normalize
        out=addResp(obj,in);
        %% Add sample points and normalize
        out=addSampling(obj,in);
        %% Add gradients and normalize
        out=addGrad(obj,in);
        %% Choice of the current normalization data
        flag=choiceData(obj,type);
        %% Normalization of sampling or responses
        out=Norm(obj,in,type);
        %% Renormalization of sample points or responses
        out=reNorm(obj,in,type);
        %% Normalization of gradients
        out=NormG(obj,in);
        %% Renormalization of gradients
        out=reNormG(obj,in,concat);
        %% Renormalization data obtained from difference of normalized data
        out=reNormDiff(obj,in,type);
        %% Renormalization of variance
        out=reNormVar(obj,in);
    end
end

