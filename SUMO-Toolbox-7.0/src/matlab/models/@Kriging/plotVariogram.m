function handle = plotVariogram(this)

% plotVariogram (SUMO)
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
%	handle = plotVariogram(this)
%
% Description:
%	EXPERIMENTAL
%	Variogram of chosen theta parameters

density = 100;

% input
dist = sum( abs( this.dist ), 2 );

% output
values = this.values;
[n p] = size(values);
mzmax = n.*(n-1) / 2;        % number of non-zero distances
%ij = zeros(mzmax, 2);       % initialize matrix with indices
valuesD = zeros(mzmax, p);        % initialize matrix with distances
ll = 0;
for k = 1 : n-1
  ll = ll(end) + (1 : n-k);
  %ij(ll,:) = [repmat(k, n-k, 1) (k+1 : n)']; % indices for sparse matrix
  valuesD(ll,:) = repmat(values(k,:), n-k, 1) - values(k+1:n,:); % differences between points
end

o = ones(1, size(this.dist,2) ); % ./ 2;
h = linspace(0, max(dist), density )';
gamma = zeros( density, 3 );

tol = 0.1;
for i=1:size( h, 1 )
	%% empirical variogram
	% Methods of moments estimator
	% by Matheron (Cressie, 1993)
	holds = find( abs( dist - h(i,:)) < tol );
	holdsMean = mean( valuesD(holds,:).^2 );
	holdsMedian = median( valuesD(holds,:).^2 );
	
	% More robust estimators: Cressie-Hawkins (1980), Genton (1998)
	% In general: use median instead of mean
	
	%% variogram of kriging
	% 2gamma = 2*(corrfunc(0) - corrfunc(h))
	holdsTheoretical = 2.*(1-this.correlationFcn( this.theta, h(i,:).*o));
	%holds2 = this.correlationFcn( this.theta, [h(i,:) h(i,:)]);
	%holds2 = find( abs( D - holds2) < tol );
	%holds2 = sum( valuesD(holds2,:).^2 ) ./ size(holds2,1);
	%holds2 = 0;
	
	%% store
	gamma(i,:) = [holdsMean holdsMedian holdsTheoretical];
end

handle = gcf;
plot( h, gamma(:,1), 'rx', ...
	  h, gamma(:,2), 'bx', 'LineWidth', 1.5 );
hold on;
plot( h, gamma(:,end), 'k-', 'LineWidth', 2 );

% empirical nugget = min( mean variogram ) at h = 0
nugget = gamma(1,1);
plot( h, nugget, 'k--', 'LineWidth', 1.5 );


xlabel( 'h', 'Fontsize', 14, 'Interpreter', 'tex' );
ylabel( '2\gamma(h) (Variogram)', 'Fontsize', 14, 'Interpreter', 'tex' );
set(gca,'Fontsize', 14);
legend( {'Empirical variogram (mean)', ...
		'Empirical variogram (median)', ...
		sprintf( 'Kriging''s variogram (%s)', func2str( this.correlationFcn ) )}, ...
		'Fontsize', 14, 'Interpreter', 'tex', 'Location', 'NorthWest' );

end
