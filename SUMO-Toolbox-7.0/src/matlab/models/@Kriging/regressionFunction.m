function [regressionFcn expression terms] = regressionFunction( this, varargin )

% regressionFunction (SUMO)
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
%	[regressionFcn expression terms] = regressionFunction( this, varargin )
%
% Description:
%	Returns the closed, symbolic expression (as a string) of the model for the given output number

    %% degrees matrix
    regressionFcn = this.regressionFcn;
    
    %% optional: the expression and individual terms corresponding to the
    %% degrees matrix
    if nargout > 1
        %% get options
        options = struct('outputIndex', 1, 'latex', false, 'includeCoefficients', true, 'precision', '%.2d' );
        n = nargin - 1;
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

        if options.latex
            mult = ' \cdot ';
            intTerm{1} = '%sx_{%i,l}'; % linear
			intTerm{2} = '%sx_{%i,q}'; % quadratic
			intTerm{3} = '%sx_{%i,c}'; % cubic
			intTerm{4} = '%sx_{%i,qua}'; % quadric
        else
            if options.includeCoefficients
                mult = '.*';
            else
                mult = '';
			end

			intTerm{1} = '%sx%il'; % linear
			intTerm{2} = '%sx%iq'; % quadratic
			intTerm{3} = '%sx%ic'; % cubic
			intTerm{4} = '%sx%iqua'; % quadric
        end

        if nargout > 1
            terms = cell( 1,size(this.stats.visitedDegrees,1) );
            terms{1} = 'OK';
        end

        if options.includeCoefficients
            num = sprintf(options.precision,this.alpha(1, options.outputIndex ));
        else
            num = '1'; % or OK
        end
        dim = size(this.samples, 2);
		nrOrders = size(regressionFcn,2) / dim;
        for set=2:size(this.stats.visitedDegrees, 1)

            %% prepend term with coefficients (if wanted)
            if options.includeCoefficients && set <= length(this.idxTerms)

                % coefficient
                coeff = this.alpha(set, options.outputIndex );

                % complex coefficient
                if ~isreal(coeff)
                    coeff = [' +(' num2str(coeff) ')'];
                % real coefficient
                else
                    % positive coefficient
                    if coeff > 0
                        coeff = ['+' sprintf(options.precision,coeff)];
                    % negative coefficient
                    else
                        coeff = ['-' sprintf(options.precision,-coeff)];
                    end
                end
                coeff = [coeff mult];
            else
                coeff = '+';
            end

            %% construct term
            term = [];
            for var=1:dim
				for i=0:nrOrders-1
					if this.stats.visitedDegrees(set,var+i.*dim) > 0
						if ~isempty(term); term = [term mult]; end
						term = sprintf( intTerm{i+1}, term, var );
					end
				end
            end

            % add term to expression if it was chosen
            if set <= length(this.idxTerms)
                num = [num coeff term];
            end

            % add term to cell array
            if nargout > 2
                terms{set} = term;
            end

        end

        expression = num;
    end
end
