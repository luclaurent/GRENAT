classdef lrm < CandidateRanker

% lrm (SUMO)
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
%	lrm(config)
%
% Description:

	methods (Access = public)
		
		function this = lrm(config)
			this = this@CandidateRanker(config);
		end

		function d = scoreCandidates(this, points, state)

            mod = state.lastModels{1}{1};

            y = evaluateInModelSpace( mod, points );

            %get the points of the hull
            p = samples(T(i,:), :);

            % get the values corresponding to the points of the hull
            v = values(T(i,:), :);

             % fit a hyperplane through the [points values]
            A = [p v ones( size(p,1), 1)];
            [M,N] = size(A);

            % Calculate hyperplane coefficients
            coeff = zeros( 1, N );
            sign_coeff = 1;
            for j=1:N
                idx = [1:j-1 j+1:N];
                coeff = sign_coeff .* det(A(:,idx));
                sign_coeff = -sign_coeff;
            end

            fpoints = [points y];

            % distance of the evaluated centroid to the plane
            coeff_mat = ones(M+1,1) * coeff;
            d = abs( sum(coeff_mat(:,1:N-1) .* fpoints, 2) + coeff_mat(:,N)) ./ sqrt(sum(coeff(1:end-1) .^ 2));

        end
    end
end

