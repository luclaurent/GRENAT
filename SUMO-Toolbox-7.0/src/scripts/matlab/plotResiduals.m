function plotResiduals( data, varargin )

% plotResiduals (SUMO)
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
%	plotResiduals( data, varargin )
%
% Description:

% We expect validationset

if nargin == 1
	% do nothing, data should be 2 column vector.
	% first column: prediction
	% second column: real values
elseif nargin == 4 % model versus given testset
	% qqdata is 1-column vector with real values
	bestModel = varargin{1};
	outputIdx = varargin{2};
	testset = varargin{3};
	
	pred = evaluate( bestModel, testset );
	data = [pred(:, outputIdx) data];
end

residu = data(:,1) - data(:,2);

figure
plot( data(:,2), residu, 'k.' );
hold on;
plot( data(:,2), zeros( size(data(:,1) ) ) );

title( 'Residuals versus  real values', 'FontSize', 14);
xlabel('y','FontSize',14,'interpreter','none');
ylabel('y - predicted y','FontSize',14,'interpreter','none');
set(gca,'FontSize',14);

%{
residu = qqdata(:,1) - qqdata(:,2);
[N X] = hist( residu, 40 );
scale = 0.3989 ./ max(N); %  norm(0,1)
N = N .* scale; %sum(N);
bar( X, N )

xmax = max( abs(X) );
X = linspace( -xmax, xmax, 100 );
npdf = normpdf(X,0,1);
hold on;
plot( X, npdf, 'r' );

title( 'Histogram', 'FontSize', 14);
xlabel('residual: y - predicted y','FontSize',14,'interpreter','none');
ylabel('Percentage','FontSize',14,'interpreter','none');
set(gca,'FontSize',14);
%}

hold off
drawnow
end
