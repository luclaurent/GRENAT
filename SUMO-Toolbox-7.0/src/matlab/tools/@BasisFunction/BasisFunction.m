classdef BasisFunction

% BasisFunction (SUMO)
%
%     This file is part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
%     and you can redistribute it and/or modify it under the terms of the
%     GNU Affero General Public License version 3 as published by the
%     Free Software Foundation.  With the additional provision that a commercial
%     license must be purchased if the SUMO Toolbox is used, modified, or extended
%     in a commercial setting. For details see the included LICENSE.txt file.
%     When referring to the SUMO-Toolbox please make reference to the corresponding
%     publication.
%
% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
% Revision: $Rev: 6401 $
%
% Signature:
%	BasisFunction(varargin)
%
% Description:
%	This class represents a basis function for use in an approximation method
%	This could be a gaussian function for in an RBF model or a polynomial kernel function for in an SVM model, etc.
%	Each basis function has a name (= name of the matlab script that implements it),
%	parameter bounds, and a scale for each parameters (log/linear). The config comes from a <BasisFunction> tag
%
%	Example:
%	   - a gaussian with one non-isotropic parameter (parameter gets duplicated dim times)
%	        <BasisFunction name="gaussian">
%	            <Parameter name="p" min="-5" max="3" scale="log" isotropic="0" />
%	        </BasisFunction>
%	   - a gaussian with two isotropic parameters
%	        <BasisFunction name="gaussian">
%	            <Parameter name="p1" min="-5" max="3" scale="log" isotropic="1" />
%	            <Parameter name="p2" min="-5" max="3" scale="log" isotropic="1" />
%	        </BasisFunction>
%	   - a sigmoid with mixed parameters
%	       <BasisFunction name="sigmoid" min="0 ; 5" max="11 ; 25" scale="log;lin"/>
%	            <Parameter name="p1" min="-5" max="3" scale="log" isotropic="0" />
%	            <Parameter name="p2" min="0.01" max="5" scale="lin" isotropic="1" />
%	        </BasisFunction>
%

    
    properties(Access = private)
        name = 'corrgauss';
		funcHandle = @corrgauss;
		
		hpNames = {}; % hyperparameter names
		nrHp = 0; % number of parameters
		transform = [];
		scale = {};
        min = [];
        max = [];
    end
    
    methods(Access = public, Static = true)
             
        % Load a set of basis functions from a config node
        function res = loadBasisFunctions(config)
            import ibbt.sumo.config.*;
            
            % Get the defined basis functions
            bfs = config.self.selectNodes( 'BasisFunction' );
            nBFs = bfs.size();
            
            res = cell(1,nBFs);
            for i=1:nBFs
                res{i} = instantiate( bfs.get(i-1), config );
            end
		end
		
    end
    
    methods(Access = public)
        function this = BasisFunction(varargin)
			
			import ibbt.sumo.config.*
			
            if(nargin == 0)
                % do nothing, keep defaults
				dim = 1;
			elseif nargin == 1
				config = varargin{1};
				dim = config.context.getInputConfig.getInputDimension();
				
				% name of basis function
				this.name = char(config.self.getAttrValue( 'name', 'corrgauss' ) );
				
				% parse parameters
				nodes = config.self.selectNodes('Parameter');
				nrParams = nodes.size();
				
				this.hpNames = cell(nrParams,1); % parameter names
				for i=1:nrParams
					param = NodeConfig.newInstance( nodes.get(i-1) );
					
					this.hpNames{i,:} = char(param.getAttrValue('name'));
					
					lb = param.getDoubleAttrValue('min', '-2');
					ub = param.getDoubleAttrValue('max', '2');
					scale = {char(param.getAttrValue('scale', 'log'))};
					
					% TODO: default value ?
					duplicate = param.getBooleanAttrValue( 'duplicate', 'on' );
					if duplicate
						this.transform = [this.transform i.*ones(1,dim)];
					else
						this.transform = [this.transform i];
					end
					
					this.min = [this.min lb];
					this.max = [this.max ub];
					this.scale = [this.scale scale];
				end
				
			elseif nargin == 5
                this.name = varargin{1};
                dim = varargin{2};
                this.min = varargin{3};
                this.max = varargin{4};
                this.scale = varargin{5};
				
				this.transform = ones(1,dim);
				this.hpNames = {'dummy'};
            else
                error('Invalid number of parameters given');
            end
            
            if(~iscell(this.scale))
                error('The scale must be passed as a cell array of strings');
			end
            
			this.funcHandle = str2func( this.name );
			str = this.funcHandle();
			D = dim;
			this.nrHp = eval( str );
			
			%% Error checking
			if length(this.transform) ~= this.nrHp
				error('The number of rows of the min, max and scale attributes has to be the same as the number of expected hyperparameters.');
			end
            
			% Misc
			if ~all( this.min < this.max )
                error('Maxima should be larger than minima for basis function parameters');
			end
		end
        
		% Description: returns name of the basisfunction
        function res = getName(this)
            res = this.name;
		end
		
		% Description: returns function handle of the basisfunction
		function h = getFunction(this)
			h = this.funcHandle;
		end
        
        % Description: return the upper and lower bounds for this basis function
        function [LB UB] = getBounds(this)
                LB = this.min(:,this.transform);
                UB = this.max(:,this.transform);
        end
        
        % Description: return the scale for this basis function
        function res = getScale(this)
                res = this.scale(:,this.transform);
		end
        
        % Description: returns number of hyperparameters
		function nr = nrHyperParameters(this)
			nr = this.nrHp;
		end
		
		% Description: returns names of hyperparameters
		function [out formatout] = getHpNames(this)
			out = this.hpNames;
			
			if nargout > 1
				formatout = this.hpNames{1};
				if length( this.hpNames ) > 1
					tmp = sprintf( ',%s', this.hpNames{2:end} );
					formatout = ['(' formatout tmp ')'];
				end
			end
		end
		
        % Description: transform hyperparameter from the scale specified by
        % the basisfunction to the (standard) linear scale
        function [param LB UB] = processParameters(this, param)
            
			% expand param
			if  length(this.transform) ~= size(param,2)
				if max(this.transform) == size(param,2)
					param = param(:,this.transform);
				else
					error('Unexpected number of hyperparameters (=%i), expected %i ',size(param,2), max(this.transform) );
				end
			%else no need to expand
			end
            
            %% now switch space
            % note that param may be a matrix (if there are multiple params
            % for this basis function)
            [LB UB] = this.getBounds();
			for i=1:size(param,2)
				if strcmp( this.scale(:,this.transform(i)), 'log' )
					param(i) = 10.^param(i);
					LB(i) = 10.^LB(i);
					UB(i) = 10.^UB(i);
				%elseif 'lin' do nothing
				end
			end
            
			% Bounds check
            assert( all( LB <= (param+eps) ) );
            assert( all( (param-eps) <= UB) );
        end
		
        % Description: print out a user friendly description of this basis function
        function disp(this)
            disp(' ');
            disp([inputname(1),' = '])
            disp(' ');
            disp(sprintf('Basisfunction %s with minima %s, maxima %s and scale %s',this.name,arr2str(this.min),arr2str(this.max),stringJoin(this.scale,',')));
            disp(' ');
        end
    end
end
