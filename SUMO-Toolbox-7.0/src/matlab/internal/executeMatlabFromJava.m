function [flatout] = executeMatlabFromJava(scriptName, in, inputDimension, options)

% executeMatlabFromJava (SUMO)
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
%	[flatout] = executeMatlabFromJava(scriptName, in, inputDimension, options)
%
% Description:
%	This function takes a matlab script (function) name, a set of input
%	parameters and possibly options that configure the matlab script which
%	also need to be passed.
%	It will then call the function with the inputs and options, and then
%	convert the output it receives to a flat array by flattening all
%	dimensions and concatenating all outputs.

% check if the script exists
if exist(scriptName) == 0
	flatout = 'Script does not exist';
	return;
end

% reshape from [x1 y1 x2 y2 x3 y3 ...] to [x1 y2; x2 y2; ...]
in = reshape(in, inputDimension, length(in) / inputDimension)';

% Make inputs a cell array
incell = num2cell(in, 1);

% number of outputs
numout = nargout(scriptName);

% catch output (comma separated list) in cell array
% To get more info, read ``help lists''
cellout = cell(1,numout);

% Are there any options which need to be passed to the simulator?
try
	
	% check if we need to pass our points in an array or separate inputs
	n = nargin(scriptName);
	
	% options specified, one more input needed
	if exist('options', 'var')
		n = n - 1;
	end
	
	% varargin, use separate inputs
	if n < 0
		if exist('options', 'var')
			[cellout{:}] = feval(scriptName, incell{:}, options);
		else
			[cellout{:}] = feval(scriptName, incell{:});
		end
		
	% there is a match between input dimension and number of inputs for the script
	elseif n == inputDimension
		if exist('options', 'var')
			[cellout{:}] = feval(scriptName, incell{:}, options);
		else
			[cellout{:}] = feval(scriptName, incell{:});
		end
		
	% no match, pass them in one array
	else
		if exist('options', 'var')
			[cellout{:}] = feval(scriptName, in, options);
		else
			[cellout{:}] = feval(scriptName, in);
		end
	end
	
catch err
	flatout = err.message;
	return;
end

% convert cell array to flat version (one array of scalars)
flatout = [];
for i = 1 : numout
	flatout = [flatout cellout{i}];
end

% transpose the array to convert from column-major (matlab) to row-major (java)
flatout = flatout';
