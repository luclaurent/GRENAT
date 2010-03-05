function [this IK] = fit( this, samples, values )

% fit (SUMO)
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
%	[this IK] = fit( this, samples, values )
%
% Description:
%	 Fit a blind kriging model
%
%	E.g.:
%	  samples = [-pi 0 pi];
%	  values = sin(samples);
%	  m = Kriging();
%	  m = m.fit( samples, values);
%

%% useful constants
[n p] = size(samples); % 'number of samples' 'dimension'

%% Normalize samples and values
% Kriging is more efficient when data is normally distributed (also reduces
% outliers)
inputAvg = mean(samples);
inputStd = std(samples);

outputAvg = mean(values);
outputStd = std(values);

samples = (samples - repmat(inputAvg,n,1)) ./ repmat(inputStd,n,1);
values = (values - repmat(outputAvg,n,1)) ./ repmat(outputStd,n,1);

%% Preprocessing

% lambda = parameter or fixed ?
% NOTE: lambda depends on nrSamples
% xval or rebuildBestModels change nrSamples, but this check returns false 
% thus, lambda is not modified to respect nrSamples. Correct or not ?
if isempty( this.lambda )
    this.lambda = log10( (n+10)*eps );
end

%% Regression matrix preprocessing

% process candidate features options
if length( this.options.maxOrder ) == 1
	this.options.maxOrder = this.options.maxOrder(ones(1,p));
elseif length( this.options.maxOrder ) ~= p
	error('size of maxOrder should be 1 or equal to the number of dimensions (%i)', p);
end

% generate:
% - degree matrix dj for dimensions j=1..p
% (linear, quadratic, cubic, quatric, ...)
% - levels lj for dimensions j=1..p
% - candidate features from sample matrix
dj = cell(p,1);
lj = cell(p,1);

%i = 1;
order = max(this.options.maxOrder);
candidateFeatures = zeros( n, order*p );
this.polyScaling = zeros( p, order );
for j=1:p
	% dj
	dj{j} = zeros( this.options.maxOrder(j)+1, p*order );

	idx1 = 2:this.options.maxOrder(j)+1;
	idx2 = j:p:(p*this.options.maxOrder(j));
	dj{j}( sub2ind( size(dj{j}), idx1, idx2 ) ) = 1;
	
	% lj: TODO: adapt for arbitrarily order
	k = this.options.maxOrder(j) + 1; % number of levels for this factor
	
	p1 = min( samples(:,j), [], 1 );
	p2 = max( samples(:,j), [], 1 );
	
	levels = zeros( k, 1 );
	idx1 = (1:k)';
	idx2 = linspace( 0, 1, k )';
	levels( idx1, : ) = p1 + idx2 .* (p2-p1);
	
	lj{j} = levels;
	
	% polynomial coding
	m = mean(levels);
	delta = levels(2,:) - levels(1,:);
	
	%
	Uj = polynomialCoding( levels, m, k, delta );
	this.polyScaling(j, :) = sqrt(sum(Uj.^2, 1));
	
	candidateFeatures(:,[j:p:end]) = sqrt(k) .* polynomialCoding( samples(:,j), m, k, delta ) ./ repmat(this.polyScaling(j, :), n, 1 );
end

% Generate appropriate degrees + construct candidate model matrix U
degrees = getCandidateDegrees( p, dj ); % create special degrees matrix (upto quadratic-quadratic interactions)
U = buildVandermondeMatrix( candidateFeatures, degrees, cfix( @powerBase, size(candidateFeatures,2) ) );

%% Correlation matrix preprocessing

% (no for loop):
% calculate i,j indices
nSamples = 1:n;
idx = nSamples(ones(n, 1),:);
a = tril( idx, -1 ); % idx
b = triu( idx, 1 )'; % idx
a = a(a~=0); % remove zero's
b = b(b~=0); % remove zero's
distIdxPsi = [a b];

% calculate manhattan distance
dist = samples(a,:) - samples(b,:);

% NOTE: double=8 bytes, 500 samples 
% a/b is 1 mb each... idx is 2 mb
% . a/b and idx reside in memory but are not used anymore -> CLEAR
% only needed is distIdxPsi (2 mb) and dist (2 mb)
clear a b idx

%% Setup initial kriging (IK) L2 parameters (fixed)
if ischar( this.regressionFcn )
	
	% easy to use + compatible with DACE toolbox
	switch this.regressionFcn
        case ''
            this.idxTerms = []; % no regression function (constant=0)
		case 'regpoly1'
			this.idxTerms = (1:p+1); % linear terms
		case 'regpoly2'
			this.idxTerms = 1:(2*p^2+1); % + quadratic interactions
		%{
        case 'regpoly3' % TODO
			this.idxTerms = 1:(2*p^2+1); % + cubic interactions
		case 'regpoly4' % TODO
			this.idxTerms = 1:(2*p^2+1); % + quadric interactions
        %}
		otherwise % 'regpoly0'
			this.idxTerms = 1; % only intercept
	end
	F = U(:,this.idxTerms);
    this.regressionFcn = degrees(this.idxTerms,:);

else
	% custom degrees matrix
	F = buildVandermondeMatrix( candidateFeatures, this.regressionFcn, cfix( @powerBase, size(candidateFeatures,2) ) );
	
    % map custom matrix to candidate features
	idx = ismember( degrees, this.regressionFcn, 'rows' );
	this.idxTerms = find( idx ~= 0 ).';
	
    % 
	if isempty(this.options.regressionMetric) && length(idx) ~= size(this.regressionFcn,1)
		warning('Invalid regression function for blind kriging. Building a fixed kriging model instead.');
	end
	
 
end

this.dist = dist; % Sample inter-distance
this.samples = samples;
this.values = values; % scaled values
this.distIdxPsi = distIdxPsi; % indexing needed for psiD

this.inputScaling = [inputAvg; inputStd];
this.outputScaling = [outputAvg; outputStd];
this.levels = lj;

% tune parameters
if isempty( this.hyperparameters )
	if isempty( this.options.hpOptimizer ) % no optimization
		% fixed theta (or optimized from the outside)
		this.hyperparameters = this.hyperparameters0;
	else
		% measure to use
		this = tuneParameters(this, F);
	end
% else for xval AND rebuildBestModels (samples changes, model parameters
% stay the same
end

% Construct model
this = updateModel(this ,F, this.hyperparameters, this.lambda);

% Do we stop here ? Or continue with feature selection (blind kriging)
if isempty(this.options.regressionMetric)
	% stop
	IK = []; % IK = BK

	% Extra information
	%stats.scoreIndex = size(ModelInfo.F,2); % Chosen model index
	%stats.scoreFinal = NaN; % not known
	this.stats.visitedDegrees = degrees;
	
	% hack: not needed anymore, free it for more memory ;-)
	this.dist = [];
	this.distIdxPsi = []; 
	return;
else
	%% setup metric function handle
	% handles multiple outputs = take avg score
	if size( values, 2 ) > 1
		this.options.regressionMetric = @(a) mean(this.options.regressionMetric(a));
	end
	% handle complex output = take magnitude
	if ~any( isreal( values ) )
		this.options.regressionMetric = @(a) abs(this.options.regressionMetric(a));
	end

	% initial leave-one out score for blind kriging process
	scores = this.options.regressionMetric( this );
end

%% Variable selection
% Setup new struct for blind kriging improvements

IK = this; % store IK model for reference purposes

% transform samples for the factor selection procedure (the 'blind' part)
% Orthogonal polynomial encoding with column length sqrt(3).
% -> this means approx 3 values -> identifying constant-linear-effects
% -> when we have more samples we can encode to column length sqrt(n) and
% identify more interactions, but then the rr and rq formulae should be
% adapted accordingly

% NOTE: xl,xq init moved to top
% Polynomial coding
%xl = (samples-2).*sqrt(3./2);
%xq = (3.*(samples-2).^2-2)./sqrt(2);

mbest = size(F,2)-1; % start with initial kriging
m = mbest;
R = Rmatrix(this, degrees); % variance-covariance matrix of prior of beta

% Keep selecting variables until one of the stopping criteria is met...
nrIter = 3;
while (m-mbest) < nrIter && ... % stop when we don't improve over nrIter iterations
	  (length(this.idxTerms) < size(degrees,1)) && ...
	  ((m+1) < n) % Vandermonde matrix can't contain more interactions than #samples

	b = posteriorBeta(this,R,U);
	
	% multiple outputs -> take mean
	b = mean(b,2);
	b(this.idxTerms,:) = -Inf; % blank out already chosen terms
	
    [maxb idx] = max(b);
    m = m + 1;
    
	% keep hold of index in model matrix (for prediction)
    this.idxTerms = [this.idxTerms idx];
	
	% keep hold of interaction column to calculate new Blind Kriging model
    F(:,end+1) = U(:,idx);

	% intermediate model to asses
	if this.options.retuneParameters
		% update hyperparameters
		this = tuneParameters(this, F);
		this = updateModel( this, F, this.hyperparameters, this.lambda );
		R = Rmatrix(this, degrees); % variance-covariance matrix of prior of beta
	else
		% only regression part changed
		this = updateRegression( this, F );
	end
    
	% asses BK
    scores = [scores ; this.options.regressionMetric(this)];
	
	% check if the score of this model is better than of the previous ones
    if scores(end) < min( scores(1:end-1) )
        mbest = m;
    end
end

% first store the considered terms
this.stats.visitedDegrees = degrees( this.idxTerms, : );

% now we can cut off at mbest terms (+1 for intercept)
this.idxTerms = this.idxTerms(1:mbest+1);

% chosen terms
F = F(:,1:mbest+1);

%% estimate parameters again
% Always needed, there is no sane reason why it should be specified by
% user.
this = tuneParameters(this, F);

% construct model
this = updateModel(this, F, this.hyperparameters, this.lambda);

% Extra information
this.stats.scores = scores; % Cross-validated prediction errors
this.stats.scoreIndex = mbest + 1; % Chosen model index
this.stats.scoreFinal = mean( this.options.regressionMetric(this) ); % Final score (after reoptimizing the parameters)

% no blind kriging anymore
this.regressionFcn = degrees( this.idxTerms, : ); % degrees of final BK model
this.options.regressionMetric = [];

% hack: not needed anymore, free it for more memory ;-)
this.dist = [];
this.distIdxPsi = []; 
end
