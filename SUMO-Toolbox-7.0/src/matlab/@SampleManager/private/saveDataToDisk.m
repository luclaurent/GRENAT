function [] = saveDataToDisk(s, fileName, header, samples, values, reasons)

% saveDataToDisk (SUMO)
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
%	[] = saveDataToDisk(s, fileName, header, samples, values, reasons)
%
% Description:
%	Store a dataset to disk in an appropriate format.

import java.util.logging.*

% if no reason for the sample is given, we don't print one
if ~exist('reasons', 'var')
	reasons = [];
end

fid = -1;

try
	% write header
	header = [header '% Selected inputs are:' 10];
	inputNames = '';
	inputSelect = [];
	for i = 1 : length(s.inputs)
		if i > 1; inputNames = [inputNames ',']; end;
		inputNames = [inputNames char(s.inputs(i).getName())];
		%inputSelect = [inputSelect (s.inputs(i).getInputSelect()+1)];
	end
	outputNames = '';
	for i = 1 : length(s.outputs)
		if i > 1; outputNames = [outputNames ',']; end;
		outputNames = [outputNames char(s.outputs(i).getName())];
	end
	header = [header '% [' inputNames '] -> [' outputNames ']' 10];
	
	header = [header '% All inputs:' 10];
	header = [header '% [] -> [] (mapping UNKNOWN)' 10];
	
	fid = fopen(fileName, 'w+');
	fwrite(fid, header);
	
	% write data to file
	%usedSamples = samples(:, inputSelect);
	%usedValues = values(:, s.outputSelect);
	dataset = [samples values];
	
	% save everything
	[m,n] = size(dataset);
	for i = 1 : m
		
		% print numbers
		for j = 1 : n
			fprintf(fid, '%e ', dataset(i,j));
		end
		
		% print reason if there is one
		if ~isempty(reasons)
			fprintf(fid, '%% %s', reasons{i});
		end
		fprintf(fid, '\r\n');
	end
	%save(fileName, 'dataset', '-ascii', '-append');
	
	fclose(fid);
catch err
	msg = sprintf('Problem when saving the current samples list to %s: %s', fileName, err.message);
	s.logger.severe(msg);
	printStackTrace(err.stack,s.logger, Level.SEVERE);

	% Make sure we always close the file
	try
	  fclose(fid);
	catch err
	  % ignore
	end
end


