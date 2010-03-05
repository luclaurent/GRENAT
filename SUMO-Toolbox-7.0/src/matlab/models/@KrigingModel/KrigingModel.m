classdef KrigingModel < Model & Kriging

% KrigingModel (SUMO)
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
%	KrigingModel(varargin)
%
% Description:
%	Description:
%	Represents a (blind) kriging model
%	This class is derived by KrigingModel, a class in the SUMO-Toolbox that works like an interface between
%	SUMO and the actual implementation Kriging

% Details:
%     Internal:    keeps BasisFunction object + theta in [-1 1]
%     Exposes : both: linear theta (from Kriging) + theta in [-1 1]

	properties (Access = private)
        % overrides correlationFunction of Kriging
        basisFunction = BasisFunction('corrgauss', 1, -2, 2, {'log'} );
        scaledHp = 0;
	end


% method definitions
methods
	
	% Signature:
	%	KrigingModel( initialTheta, regressionMetric, regressionFcn, ...
	%					correlationBF );
	function this = KrigingModel(varargin)

        % ugly construct, filter correlation function argument (convert to
        % BasisFunction)
        if nargin > 0
            if nargin > 3
                basisFunction = varargin{4};
                try
					varargin{4} = basisFunction.getFunction();
				catch
                end
            else
                basisFunction = BasisFunction('corrgauss', 1, -2, 2, {'log'} );
            end
            
            % theta 
            scaledHp = varargin{2};
            [varargin{2} LB UB] = basisFunction.processParameters( scaledHp );

            if nargin > 4
                % bounds
				varargin{1}.hpBounds = [LB ; UB];
				varargin(5) = []; % remove
            end
        end
        
		this = this@Kriging( varargin{:} );
        
		if nargin > 0
			this.scaledHp = scaledHp;
			this.basisFunction = basisFunction;
		end

	end % constructor
	
	%% Function declarations
	
	% constructInModelSpace (SUMO)
	% Description:
	%     Just sets all members to new samples and values
	this = constructInModelSpace(this, samples, values);

	% evaluateInModelSpace (SUMO)
	% Description:
	%     Evaluate the model at the given points
	values = evaluateInModelSpace(this, points);
	
	% evaluateDerivativeInModelSpace (SUMO)
	% Description:
	%     Evaluate the derivative of the prediction at the given points
	dvalues = evaluateDerivativeInModelSpace(this, points, outputIndex);

	% evaluateMSEInModelSpace (SUMO)
	% Description:
	%     Evaluation at a set of points
	mse = evaluateMSEInModelSpace(this, points);

	% evaluateMSEDerivativeInModelSpace (SUMO)
	% Description:
	%     Evaluate the derivative of the mean squared error at the given points
	dmse = evaluateMSEDerivativeInModelSpace(this, points, outputIndex);

	% getDescription (SUMO)
	% Description:
	%     Return a user friendly model description
	desc = getDescription(this);

	% getExpressionInModelSpace (SUMO)
	% Description:
	%     Returns the closed, symbolic expression (as a string) of the model
	%     for the given output number
	desc = getExpressionInModelSpace(this, outputIndex);
	
	% disp
	% Description:
	%     Returns description of the object (overloading the default of matlab)
	function desc = disp(this)
		desc = this.getDescription();
    end
    
    % correlationFunction (SUMO)
    % Description:
    %	Returns the current correlation function (overrides Kriging)
    function [basisfunc corrfunc] = correlationFunction(this)
        basisfunc = this.basisFunction;
        corrfunc = this.basisFunction.getName();
    end
    
    % getHp (SUMO)
    % Description:
    %	Returns the hyperparameters (overrides Kriging)
    function [hp scaledHp] = getHp(this)
        hp = this.getHp@Kriging();
        scaledHp = this.scaledHp;
    end


end % methods

end % classdef
