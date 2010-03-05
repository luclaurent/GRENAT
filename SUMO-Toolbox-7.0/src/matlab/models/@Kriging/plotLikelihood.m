function h = plotLikelihood(this,func)

% plotLikelihood (SUMO)
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
%	h = plotLikelihood(this,func)
%
% Description:
%	Debugging: plots contour plot of likelihood (if 2D)

    density = 20;
	showDerivatives = true;
	
	fullDim = size( this.options.hpBounds, 2 );
	if ~isinf( this.options.lambda0 )
		fullDim = fullDim + 1;
	end
	
	l = min( fullDim, 2 ); % MAX 2D plot 
	hp = cell(l, 1);
	for i=1:l
		hp{i} = linspace( this.options.hpBounds(1,i), this.options.hpBounds(2,i), density );
	end
	hpFixed = this.hyperparameters(:,3:end);
    
    grid = makeEvalGrid( {hp{:}} );
    [n m] = size(grid);
	lik = zeros( n, 1 );
	dlik = zeros( n, fullDim );
    for i=1:size(grid,1)
		
		p = [grid(i,:) hpFixed];
		if showDerivatives
			%[lik(i,:) dlik(i,:)] = likelihood( this, p, this.lambda );
			[lik(i,:) dlik(i,:)] = func( p );
		else
			%lik(i,:) = likelihood( this, p, this.lambda );
			lik(i,:) = func( p );
		end
		
        if mod( i, 20 ) == 0
            buffer = sprintf('Iteration %i of %i', i, size(grid,1) );
            disp( buffer );    
        end
            
    end
    
	% likelihood: objective + derivatives
	opts = plotScatteredData();
	opts.contour = true;
	opts.plotPoints = false;
    h = plotScatteredData( [grid lik], opts );
	hold on;
	
	if showDerivatives
		quiver(grid(:,1),grid(:,2),dlik(:,1),dlik(:,2),'r');
	end
    
    % grid minimum
    [gridminimum idx] = min( lik );
    plot(grid(idx,1), grid(idx,2),'gx','Markerfacecolor','g');
	gridminimum
	grid(idx,:)
	
	hold off;
end
