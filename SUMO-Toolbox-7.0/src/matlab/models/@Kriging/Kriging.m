classdef Kriging

% Kriging (SUMO)
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
% Revision: $Rev$
%
% Signature:
%	Kriging(varargin)
%
% Description:
%	Represents a (blind) kriging model
%	This class is derived by KrigingModel, a class in the SUMO-Toolbox that works like an interface between
%	SUMO and the actual implementation Kriging

% Details:
%     Internal:    log theta and bounds
%     Exposes : linear theta and bounds

	properties (Access = private)
		%% static part (=ModelFactory options)
		options = [];
		
		%% L2 parameters
		regressionFcn = 'regpoly0'; % degrees matrix (strings are converted)
		correlationFcn = 'corrgauss'; % string -> function handle
		
		% initial hp values OR the real ones (if optimization is done
		% outside)
		hyperparameters0 = [];
		
        % preprocessing values
		samples = [];
		values = [];
		dist = []; % sample inter-distance
		distIdxPsi = []; % indexing needed to calculate psi from D
		inputScaling = []; % input scaling
		outputScaling = []; % output scaling
		levels = []; % k level values (k=3 for the moment)
		polyScaling = [];

		%% L1 parameters
		alpha = []; % Regression coefficients
		gamma = []; % 'Correlation part' coefficients
		
		hyperparameters = []; % correlation parameters
		lambda = []; % amount of regression of stochastic part
		C = []; % correlation matrix (Choleski Decomposition)
		Ft = []; % decorrelated model matrix
		R = []; % from QR decomposition of regression part
		sigma2 = []; % stochastic process variance
		idxTerms = []; % indices of chosen polynomial terms
		
		% Statistics (not needed for fitting and/or predicting)
        stats = struct( ...
            'scores', [], ... % Cross-validated prediction errors
            'scoreIndex', [], ... % Chosen model index
            'scoreFinal', [], ... % Final score (after reoptimizing the parameters)
            'visitedDegrees', [] ... * considered terms
            );

        rank = []; % rank of correlation matrix
        P = []; % permutation
	end

	% PUBLIC
	methods( Access = public )

		% CTor
		function this = Kriging(varargin)

			% default CTor
			if(nargin == 0)
				%use defaults
			% copy CTor
			elseif isa(varargin{1}, 'Kriging')
				this = varargin{1};
			else
				if nargin == 2
					this.options = varargin{1};
					this.hyperparameters0 = varargin{2};
				elseif nargin == 3
					this.options = varargin{1};
					this.hyperparameters0 = varargin{2};
					this.regressionFcn = varargin{3};
				elseif nargin == 4
					this.options = varargin{1};
					this.hyperparameters0 = varargin{2};
					this.regressionFcn = varargin{3};
					this.correlationFcn = varargin{4};		
				else
					error('Invalid number of parameters given');
				end
				
				%% convert strings to function handles
                switch this.options.regressionMetric
                    case 'cvpe'
                        this.options.regressionMetric = @cvpe; % blind kriging
                    otherwise
                        this.options.regressionMetric = []; % fixed kriging
                end
                
                %% Sanitize bounds and theta0
                
                % convert theta to log space
                if  any(this.hyperparameters0 <= 0)
                    error('theta0 must be strictly positive');
                else
                    this.hyperparameters0 = log10( this.hyperparameters0 );
                end
                
                % convert bounds to log space
				if ~isempty( this.options.hpBounds )
					this.options.hpBounds = log10( this.options.hpBounds );

					if length(this.hyperparameters0) ~= size(this.options.hpBounds, 2 )
						error('Initial theta (theta0) and bounds should have the same length.');
					end
				end
			
			end % end outer if
			
		end % constructor

		%% Function definitions (mostly getters)
		
		% getHp (SUMO)
		% Description:
		%	Returns the correlation parameters theta
		function hp = getHp(this)
			hp = 10.^this.hyperparameters;
		end
		
		% getLambda (SUMO)
		% Description:
		%	Returns the regression parameter lambda
		function lambda = getLambda(this)
			lambda = this.lambda;
		end
		
		% getProcessVariance (SUMO)
		% Description:
		%	Returns the regression parameter lambda
		function sigma2 = getProcessVariance(this)
			sigma2 = this.sigma2;
		end

		% correlationFunction (SUMO)
		% Description:
		%	Returns the current correlation function
		function corrfunc = correlationFunction(this)
			corrfunc = func2str( this.correlationFcn );
		end
		
		% includeLambda (SUMO)
		% Description:
		%     include lambda as a hyperparameter
		function this = includeLambda(this, lambda0, bounds)
			this.lambda0 = lambda0;
			this.boundsLambda = bounds;		
		end
		
		% setOptimizer (SUMO)
		% Description:
		%     sets optimizer to use for theta hyperparameter identification		
		function this = setOptimizer( this, optim )
			this.thetaOptimizer = optim;
		end

		%% Function declarations

		% fit (SUMO)
		% Description:
		%     Creates a kriging model
		[this IK] = fit(this, samples, values);

		% predict (SUMO)
		% Description:
		%     Evaluate the model at the given points
		[values sigma2] = predict(this, points);

		% predict_derivatives (SUMO)
		% Description:
		%     Evaluate the derivative of the prediction at the given points
		[dvalues dsigma2] = predict_derivatives(this, points);

        % regressionFunction (SUMO)
		% Description:
		%	Returns the current regression function
		[regressionFcn expression terms] = regressionFunction(this,varargin);

		% cvpe (SUMO)
		% Description:
		%     Calculates cross validated prediction error
		[out dout] = cvpe(this, hp, lambda);
		
        % holdout (SUMO)
		% Description:
		%     Calculates error on holdout set, using MSE
		e = holdout(this);
		        
        % rcValues (SUMO)
		% Description:
        %     robustness-criterion
		%     Quantifies magnification of noise (lower is better)
		rc = rcValues(this);
        
		% plotVariogram (SUMO)
		% Description:
		%     Debugging: plots contour plot of likelihood (if 2D)
        h = plotVariogram(this);
		
        % plotLikelihood (SUMO)
		% Description:
		%     Debugging: plots contour plot of likelihood (if 2D)
        h = plotLikelihood(this,func);

		% setDebug (SUMO)
		% Description:
		%     Turn debugging on/off
		function this = setDebug(this, b)
			this.debug = b;
		end

	end % methods public
    
    %% PROTECTED (needed by @KrigingModel of SUMO toolbox)
    methods( Access = protected )
        
		% Needed by: KrigingModel::getExpressionInModelSpace
        function gamma = getGamma(this)
            gamma = this.gamma;
		end
        
		% Needed by: KrigingModel::getExpressionInModelSpace
        function samples = getScaledSamples(this)
            samples = this.samples;
		end
        
		% Needed by: KrigingModel::getExpressionInModelSpace
        function out = getInputScaling(this)
            out = this.inputScaling;
		end
        
		% Needed by: KrigingModel::getExpressionInModelSpace
        function out = getOutputScaling(this)
            out = this.outputScaling;
		end
		
		% Needed by: KrigingModel::getExpressionInModelSpace
		function levels = getLevels(this)
            levels = this.levels;
		end
        
    end % methods protected

    %% PRIVATE
	methods( Access = private )
		
		% tuneParameters (SUMO)
		% Description:
		%     hyperparameter optimization, returns likelihood of optimized
		%     parameters
		[this perf] = tuneParameters(this, F);
		
		% likelihood (SUMO)
		% Description:
		%     Calculates likelihood
		[out dout] = likelihood(this, F, hp, lambda);
		
		% updateModel (SUMO)
		% Description:
		%     Constructs model (regression + correlation)
		this = updateModel(this, F, hp, lambda);
		
		% updateRegression (SUMO)
		% Description:
		%     Constructs regression part 
		[this err residual sigma2] = updateRegression(this, F);
		
		% updateCorrelation (SUMO)
		% Description:
		%     Constructs correlation part 
		[this err dpsi] = updateCorrelation(this, hp, lambda);
		
		% polynomialCoding (SUMO)
		% Description:
		%     returns coded model matrix
		U = polynomialCoding( samples, k )
			
		% getCandidateDegrees (SUMO)
		% Description:
		%     returns degree matrix for candidate
		degrees = getCandidateDegrees(this);
		
		% correlationMatrix (SUMO)
		% Description:
		%     constructs correlation matrix
		psi = correlationMatrix(this, theta);
		
		% posteriorBeta (SUMO)
		% Description:
		%     beta coefficients
		beta = posteriorBeta(this, R, U);
		
		% Rmatrix (SUMO)
		% Description:
		%     posterior covariance matrix of beta polynomial
		R = Rmatrix(this, degrees);
		
	end % methods private
end % classdef
