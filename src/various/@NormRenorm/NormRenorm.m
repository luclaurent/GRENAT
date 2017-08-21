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
        %
        outC=[];
    end
    properties (Access = private)
        type='n';
    end
    methods
        %% constructor
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
            else
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
        
        %%initialize all data
        function init(obj)
            listP={'meanC','stdC','meanN','stdN','stdR','meanR','stdS','meanS','respN'};
            for it=1:length(listP)
                feval([obj '.' listP{it} '=[];']);
            end
        end
        
        %% load existing information (defined using structure)
        function loadConf(obj,StClIn)
            %read the input data
            out=checkStCl(StClIn);
            %
            obj.meanN=out.meanN;
            obj.meanR=out.meanR;
            obj.meanS=out.meanS;
            obj.stdN=out.stdN;
            obj.stdR=out.stdR;
            obj.stdS=out.stdS;
        end
        
        %% compute normalization data
        function computeNorm(obj,in,type)
            %in the case of no type specified
            if nargin<3;type='normal';end
            if any(isnan(in(:)));Gfprintf(' ++ Caution: NaN detected for normalization OMITTED\n');end
            %computation of the means and standard deviations
            obj.meanC=mean(in,'omitnan');
            obj.stdC=std(in,'omitnan');
            %depending on the option the storage is changed
            switch type
                case {'resp','Resp','r','R','RESP','response','Responses','RESPONSES'}
                    obj.meanR=obj.meanC;
                    obj.stdR=obj.stdC;
                case {'sampling','Sampling','s','S','SAMPLING'}
                    obj.meanS=obj.meanC;
                    obj.stdS=obj.stdC;
                otherwise
                    obj.meanN=obj.meanC;
                    obj.stdN=obj.stdC;
            end
        end
        
        %% add responses
        function out=addResp(obj,in)
            obj.computeNorm(in,'r');
            out=obj.Norm(in,'r');
            obj.respN=out;
        end
        
        %% add sample points
        function out=addSampling(obj,in)
            obj.computeNorm(in,'s');
            out=obj.Norm(in,'s');
            obj.samplingN=out;
        end
        
        %% choice of the current normalization data
        function flag=choiceData(obj,type)
            flag=true;
            %in the case of no type specified
            if nargin<2;type='normal';end
            switch type
                case {'resp','Resp','r','R','RESP','response','Responses','RESPONSES'}
                    obj.meanC=obj.meanR;
                    obj.stdC=obj.stdR;
                case {'sampling','Sampling','s','S','SAMPLING'}
                    obj.meanC=obj.meanS;
                    obj.stdC=obj.stdS;
                otherwise
                    obj.meanC=obj.meanN;
                    obj.stdC=obj.stdN;
            end
            % if empty normalization data
            if isempty(obj.meanC)||isempty(obj.stdC)
                Gfprintf(' ++ Caution: normalization data not defined (type: %s)\n',type);
                flag=false;
            end
        end
        %% normalization
        function out=Norm(obj,in,type)
            %
            if nargin<2;type='normal';end
            %
            fl=obj.choiceData(type);
            %normalization
            if fl
                nS=size(in,1);
                out=(in-obj.meanC(ones(nS,1),:))./obj.stdC(ones(nS,1),:);
            else
                out=in;
            end
        end
        
        %% renormalization
        function out=reNorm(obj,in,type)
            %
            if nargin<2;type='normal';end
            %
            fl=obj.choiceData(type);
            %renormalization
            if fl
                nS=size(in,1);
                out=obj.stdC(ones(nS,1),:).*in+obj.meanC(ones(nS,1),:);
            else
                out=in;
            end
        end
        
        %% normalization of gradients
        function out=NormG(obj,in)
            % if empty normalization data
            if isempty(obj.stdS)||isempty(obj.stdR)
                Gfprintf(' ++ Caution: normalization data not defined for gradient\n');
                out=in;
            else
                nS=size(in,1);
                out=in.*obj.stdS(ones(nS,1),:)./obj.stdR;
            end
        end
        
        %% renormalization of gradients
        function out=reNormG(obj,in,concat)
            % if concat (gradients concatenate in vector)
            if nargin<3;concat=false;end
            % if empty normalization data
            if isempty(obj.stdS)||isempty(obj.stdR)
                Gfprintf(' ++ Caution: normalization data not defined for gradient\n');
                out=in;
            else
                nS=size(in,1);
                if concat
                    correct=obj.stdR./obj.stdS;
                    nbv=numel(obj.stdS);
                    out=in.*repmat(correct(:),nS/nbv,1);
                else
                    out=in*obj.stdR./obj.stdS(ones(nS,1),:);
                end
            end
        end
        
        %% renormalization data obtained from difference of normalized data
        function out=reNormDiff(obj,in,type)
            %
            if nargin<2;type='normal';end
            %
            fl=obj.choiceData(type);
            %renormalization
            if fl
                nS=size(in,1);
                out=obj.stdC(ones(nS,1),:).*in;
            else
                out=in;
            end
        end
    end
end

%% function for checking and extracting the content of a class or a struct
function [statVal]=checkStCl(in)
%load the specific function
switch class(in)
    case 'class'
        fun='ismethod';
    case 'struct'
        fun='isfield';
end
% initialize variables
meanN=[];stdN=[];
meanR=[];stdR=[];
meanS=[];stdS=[];
%
if feval(fun,in,'mean')&&feval(fun,in,'std')
    meanN=in.mean;
    stdN=in.std;
end
%
if feval(fun,in,'meanC')&&feval(fun,in,'stdC')
    meanN=in.meanN;
    stdN=in.stdN;
end
%
if feval(fun,in,'meanS')&&feval(fun,in,'stdS')
    meanS=in.meanS;
    stdS=in.stdS;
end
%
if feval(fun,in,'meanR')&&feval(fun,in,'stdR')
    meanR=in.meanR;
    stdR=in.stdR;
end
%
if feval(fun,in,'resp')
    if feval(fun,in.resp,'mean')&&feval(fun,in.resp,'std')
        meanR=in.resp.mean;
        stdR=in.resp.std;
    end
end
%
if feval(fun,in,'sampling')
    if feval(fun,in.sampling,'mean')&&feval(fun,in.sampling,'std')
        meanS=in.sampling.mean;
        stdS=in.sampling.std;
    end
end
statVal.meanN=meanN;
statVal.stdN=stdN;
statVal.meanS=meanS;
statVal.stdS=stdS;
statVal.meanR=meanR;
statVal.stdR=stdR;
end
