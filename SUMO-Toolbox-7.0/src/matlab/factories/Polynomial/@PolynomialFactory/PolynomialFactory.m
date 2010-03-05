classdef PolynomialFactory <  ModelFactory

% PolynomialFactory (SUMO)
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
%	PolynomialFactory(config)
%
% Description:
%	This class is responsible for generating Kriging Models

    properties(Access = private)
	dimension;		
	degrees;
	baseFunctions;
	logger;
    end
    
    methods
        function this = PolynomialFactory(config)
            import java.util.logging.*;

            this = this@ModelFactory(config);
		    this.logger = Logger.getLogger('Matlab.PolynomialFactory');
  
			this.dimension = config.input.getInputDimension();
			this.degrees = [0 0;0 1;0 2;1 0;1 1;1 2;2 0;2 1;2 2];
			this.baseFunctions = {@chebyshevBase};
		
			degrees = str2num(char(config.self.getOption('degrees', '[]')));
			if ~isempty( this.degrees )
				if size(this.degrees,2) ~= config.input.getInputDimension()
					msg = 'Illegal size of degrees, need one column for each dimension';
					this.logger.severe(msg);
					error(msg);
				end
				this.degrees = degrees;
			else
				this.logger.warning( 'No valid degrees specified, using default (Quadratic model in 2 dimensions)' );
			end

			bf = char(config.self.getOption('basis', '') );
			if strcmp( bf, 'power' ) || strcmp( bf, 'chebyshev' ) || strcmp( bf, 'legendre' )
				this.baseFunctions = str2func( [ char(bf) 'Base' ] );
			else
				this.logger.warning( 'No valid basis function specified, using default (Chebyshev base)' );
			end
            
		end
		
		%%% Implement ModelFactory
		function [LB UB] = getBounds(this);
			% NOT USED
			LB = [];
			UB = [];
		end
		
		function res = supportsComplexData(this)
			res = true;
		end

		function res = supportsMultipleOutputs(this)
		  res = true;
		end

		models = createInitialModels(this,number,wantModels);
		model = createModel(this,parameters);
		obs = getObservables(this);

		%%% Implement GeneticFactory (TODO: only this function is implemented
		%%% from GeneticFactory)
		function res = getModelType(this)
			res = 'PolynomialModel';
		end

	end % methods
end % classdef
