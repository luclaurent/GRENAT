function [this err dpsi] = updateCorrelation( this, hyperparameters, lambda )

% updateCorrelation (SUMO)
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
%	[this err dpsi] = updateCorrelation( this, hyperparameters, lambda )
%
% Description:
%	Updates model

	err = [];
	
    % Number of samples...
    n = size( this.values, 1 );

	if nargout > 1
		[psi dpsi] = correlationMatrix(this, hyperparameters, lambda);
	else
		psi = correlationMatrix(this, hyperparameters, lambda);
	end

	if this.options.lowRankApproximation
		rankMax = min( this.options.rankMax, n );
		[C P] = cholincsp(psi, this.options.rankTol, rankMax );
		rank = size(C,1);
		
		if this.options.debug
			try
				if ~spok(C)
					lastwarn
				end
			catch e
				disp( e.getReport() );
			end
		end
		
		if rank < n
			fprintf(1,'WARNING: correlation matrix is rank %i of %i\n', rank, n );
		end
	else
		%% STANDARD
		% Cholesky factorization with check for pos. def.
		[C rd] = chol(psi);
		P = 1:n;
		rank = size(C,1);

		if rd > 0 % not positive definite
			%fprintf( 1, '
			% penalty
			%out = +Inf;
			%dout = zeros( 1, size( hyperparameters, 2 ) );
			err = 'correlation matrix is ill-conditioned.';
			return
		end
	end
	this.C = C';
	this.P = P;
	this.rank = rank;
  
    % NOTE:
    % C  is lower triangular
    % C' is upper triangular 
    % C*C' = psi(1:P,1:P) (IF rank == n)
end
