function m = createModel(this, varargin)

% createModel (SUMO)
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
%	m = createModel(this, varargin)
%
% Description:
%	Given an individual representing a model, return a real model

%Construct the model through the given samples

% theta = [-1,1] in ? space

%% Kriging optimizes parameters (AdaptiveModelBuilder)
if( nargin == 1 )

    corrFunc = this.correlationFunctions{this.initialCorrelationFunction};
    % adaptive modelbuilder: theta optimized by likelihood
    m = KrigingModel( this.options, this.initialHp, this.regressionFunction,corrFunc, 'useLikelihood' );
   
%% Use given parameters/model (GeneticModelBuilder, ...)
elseif( nargin == 2 )
	individual = varargin{1};
	
	if( isa(individual,'Model') )
		m = individual;
	else
		% Add default corr function
		if this.nBFs == 1 
			individual(:, end+1 ) = this.initialCorrelationFunction;
		end

		regrfunc = this.regressionFunction;
        theta = individual(:,1:end-1);
        idx = round( individual( :, end  ) );
		corrfunc = this.correlationFunctions{ idx };
        
        %% linear scale from -1,1 to original bounds
        [LB UB] = corrfunc.getBounds();
        transl = (UB+LB)/2.0;
        scale = (UB-LB)/2.0;
        theta = (theta .* scale) + transl;

        m = KrigingModel(this.options, theta,regrfunc,corrfunc);
		% no setOptimizer -> modelbuilder optimizes theta
	end
else % pass on unchanged
    m = KrigingModel( varargin{:} );
	% no setOptimizer -> modelbuilder optimizes theta
end

end
