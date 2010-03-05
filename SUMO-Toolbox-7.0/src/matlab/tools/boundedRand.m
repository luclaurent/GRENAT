function res = boundedRand(varargin)

% boundedRand (SUMO)
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
%	res = boundedRand(varargin)
%
% Description:
%	Return uniform random numbers within the given lower and upper bounds (may be vectors)
%
%	eg: boundedRand(LB, UB, M, N)
%
%	LB and UB must be column vectors and may be passed as one parameter
%	([LB UB)).  M and N are optional parameters that specify the size of
%	the matrix you want as a result.

if(nargin == 1)
	tmp = varargin{1};
	
	if(size(tmp,2) ~= 2)
		error('The given bounds must have 2 columns');
	end

	lower = tmp(:,1);
	upper = tmp(:,2);
    
    numRows = size(lower,1);
    numCols = 1;

    checkInput(lower,upper,numRows,numCols);
    
elseif(nargin == 2)
	lower = varargin{1};
	upper = varargin{2};
    
    numRows = size(lower,1);
    numCols = 1;
    
    checkInput(lower,upper,numRows,numCols);

elseif(nargin == 3)
	tmp = varargin{1};
	
	if(size(tmp,2) ~= 2)
		error('The given bounds must have 2 columns');
	end

	lower = tmp(:,1);
	upper = tmp(:,2);
    
    numRows = varargin{2};
    numCols = varargin{3};
    
    checkInput(lower,upper,numRows,numCols);
    
elseif(nargin == 4)
	lower = varargin{1};
	upper = varargin{2};
    numRows = varargin{3};
    numCols = varargin{4};

    checkInput(lower,upper,numRows,numCols);

else
	error('Invalid number of parameters');
end

lower2 = lower/2;
upper2 = upper/2;
a = lower2 + upper2;
b = upper2 - lower2;

res = a + b .* (2*rand(numRows,numCols)-1);

%res = unifrnd(lower,upper);


function checkInput(lower,upper, numRows, numCols)
    if(isempty(lower) || isempty(upper))
        error('Bounds may not be empty!');
    end

    if(size(lower,2) ~= 1 || size(upper,2) ~= 1)
         error('Lower and upper bounds must be column vectors');
    end

    if(size(lower,1) ~= size(upper,1))
         error('Lower and upper bounds must have the same number of rows');
    end

    if(~isscalar(numRows) || ~isscalar(numCols))
        error('number of rows or columns must be scalars');
    end

    if( size(lower,1) > 1 && (numRows ~= size(lower,1) || numCols ~= 1) )
       error('Dimension mismatch!');
    end
