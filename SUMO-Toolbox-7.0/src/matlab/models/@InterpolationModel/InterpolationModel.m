classdef InterpolationModel < Model

% InterpolationModel (SUMO)
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
% Revision: $Rev: 6376 $
%
% Signature:
%	InterpolationModel(varargin)
%
% Description:
%	Constructs an interpolation based on Matlabs griddata (to allow for
%	scattered data).  For 1D data the interp1 command is used.  For more
%	than 1 dimension the interpolation is triangle based (see griddata,
%	griddata3, and griddatan for more information).
%	The constructor takes one optional parameter: a string defining the
%	method.  See the above commands for available methods (linear, cubic,
%	nearest, ...).

	
	properties(Access = private)
        method;
		interpolant = [];
	end
	
	methods

		function this = InterpolationModel(varargin)

			if(nargin == 0)
                this.method = 'linear';
			elseif(nargin == 1)
				this.method = varargin{1};
			else
				error('Invalid number of parameters given');
			end
		end

		function t = getMethod(this)
			t = this.method;
		end

		function this = setMethod(this,t)
			this.method = t;
		end
		
		
		function [this] = constructInModelSpace(this, samples, values)
			
			this = this.constructInModelSpace@Model(samples, values);
			
			if ~verLessThan('matlab', '7.9')
				if size(samples,2) >= 2 && size(samples,2) <= 3
					if(strcmp(this.method,'natural') || strcmp(this.method,'linear') || strcmp(this.method,'nearest'))
						this.interpolant = TriScatteredInterp(samples, values);
						this.interpolant.Method = this.method;
					end
				end
			end
			
		end
		
    
        function [values] = evaluateInModelSpace(this, points)
            
			% interpolant available - use it if the method is supported
			if ~isempty(this.interpolant)
                if(strcmp(this.method,'natural') || strcmp(this.method,'linear') || strcmp(this.method,'nearest'))
    				values = this.interpolant(points);
        			return;
                end
			end
			
            [in out] = this.getDimensions();
            
            % get the training data
            samp = this.getSamplesInModelSpace();
            vals = this.getValues();
            
            if(in == 1)
                % 1D, use interp1
                values = interp1(samp,vals,points,this.method);
            elseif(in == 2)
                % 2D
                values = griddata(samp(:,1),samp(:,2),vals,points(:,1),points(:,2),this.method, {'Qt' 'Qbb' 'Qc' 'Qx' 'Qz'});
            elseif(in == 3)
                % 3D
                values = griddata3(samp(:,1),samp(:,2),samp(:,3),vals,points(:,1),points(:,2),points(:,3),this.method, {'Qt' 'Qbb' 'Qc' 'Qx' 'Qz'});
            else
                %nD
                values = griddatan(samp,vals,points,this.method, {'Qt' 'Qbb' 'Qc' 'Qx' 'Qz'});
            end
        end
        
        function desc = getDescription(this)
           desc = ['Interpolation model with method ' this.method]; 
        end
	end
end
