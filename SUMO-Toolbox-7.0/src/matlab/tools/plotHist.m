function plotHist(N,M, varargin)

% plotHist (SUMO)
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
% Revision: $Rev: 6383 $
%
% Signature:
%	plotHist(N,M, varargin)
%
% Description:
%	PDF/PMF/histogram plot of the given data

%% get options
% type = {'hist', 'pdf', pmf'}
options = struct('type', 'pdf', 'FontSize', 12 );
n = nargin - 2;
if mod(n,2) ~= 0
    % no options, need pairs
else
    while (n > 0)
        option = varargin{n-1};
        value = varargin{n};
        options.(option) = value;
        n = n - 2;
    end
end

nrOutputs = size(N,2);
if iscell( N )
    labels = sort(N);
    
    % naive:
    %N = zeros( length(labels), 1 );
    n = [];
    i = 1;
    while i <= length(labels);
        
        match = labels{i,:};
        n = [n ; 1];
        while (i+1) <= size(labels, 1) && strcmp( match, labels{i+1} )
            n(i,:) = n(i,:) + 1;
            labels(i+1) = [];
        end
        i = i + 1;
	end
	
	% sort in descending order
	[n idx] = sort(n,1,'descend');
	labels = labels(idx);
    
    x = (1:length(labels))';
else
	% Automatic number of bins calculation
    if ~exist( 'M', 'var' ) || M < 0
        M = calcnbins(N, 'middle' );
	end
    
	%
    [n x] = hist(N,M);
	
	% dirty hack: stupid matlab returns it as row vector
	if nrOutputs == 1
		n = n';
		x = x';
	end
end

if strcmp( options.type, 'hist' )
	% real histogram
	ytext = 'number of occurences';
elseif strcmp( options.type, 'pmf' )
	% sum(n,1) == 1
    n = n ./ repmat( sum(n,1), size(x,1), 1);
	ytext = 'density';
else %if strcmp( options.type, 'pdf' )
	ytext = 'density';
end

spmodel = SplineModel(1);

densex = linspace( min(N), max(N), 50000).';
styles = buildShapeGrid( {'b', 'k'}, {}, {'-', '-.', ':'} );
for i=1:nrOutputs
    hold on;
	
    if strcmp( options.type, 'hist' )
		% histogram (as-is: discrete number of occurrences )
        densex = x;
        densen = n(:,i);
	elseif strcmp( options.type, 'pmf' )
		% pmf (extrapolated)
		spmodel = spmodel.constructInModelSpace( x, n(:,i) );
        densen = spmodel.evaluateInModelSpace( densex );
	elseif strcmp( options.type, 'pdf' ) && ~isempty( ver('stats') )
		% pdf
        [densen densex U] = ksdensity(N(:,i), densex );
	else
		error( 'type is one of ''hist'', ''pmf'', ''pdf'' (''pdf'' requires statistics toolbox)' );
    end
       
    if strcmp( options.type, 'hist' )
        bar( densex, densen );
		if iscell(N)
			set(gca,'XTickLabel', labels );
		end
	else
        plot( densex, densen, styles{i}, 'LineWidth', 1 );
		
		if strcmp( options.type, 'pmf' )
			plot( x, n(:,i), 'kx' ); % discrete
		end
    end
end
ylabel(ytext,'FontSize',options.FontSize,'interpreter','none');

% legend 
if nrOutputs > 1 || iscell(N)
    txt = sprintf( 'Column %i', (1:nrOutputs)' );
    txt = reshape(txt,[],nrOutputs);
    legend( txt' );
% otherwise mean and variance
elseif strcmp( options.type, 'pdf' )
    mu = mean(N);
    sigma = std(N);

    densenorm = normpdf( densex, mu, sigma );
    plot( densex, densenorm, 'r--', 'LineWidth', 1 );

	% Matlab only supports subset of latex. So no \cal{N} (workaround is to change font)
    legend( {'Model', sprintf('{\\fontname{zapfchancery}N}(x)(\\mu = %0.2f,\\sigma = %0.2f)',mu, sigma)}, 'Interpreter','tex','location','NorthWest','FontSize',options.FontSize);
end

% set the fontsize of the axis labels
set(gca,'FontSize',options.FontSize);
hold off;

end

