function [data] = collectProfilerData(directory, runMask, profilerMask);

% collectProfilerData (SUMO)
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
%	[data] = collectProfilerData(directory, runMask, profilerMask);
%
% Description:
%	Gather all profiler data present in all the runs (in directory 'directory') whose name matches the runMask (optional).
%	The optional profilerMask parameter ensures that only profiler names that match the given regexp are included
%	An array of structs is returned with each struct holding the profiler data for one particular run.
%	So basically this file returns the raw contents of all profilers for each run.

if(~exist('runMask'))
	runMask = '*';
end

if(~exist('profilerMask'))
	profilerMask = '.*';
end

runs = dir([directory '/' runMask]);

data = {};

for r=1:length(runs)
	runName = runs(r).name;
	ppath = [directory '/' runName '/profilers'];
	samplesFile = [directory '/' runName '/samples.txt'];

	if(runs(r).isdir && ~strcmp(runName,'.') && ~strcmp(runName,'..'))
		%disp(sprintf('Collecting profiler from run %s',runName));
		
		profilerFiles = dir([ppath '/*.txt']);
		
		entry = struct();
		for p=1:length(profilerFiles)
			pname = profilerFiles(p).name;
			%remove extension
			pname = pname(1:end-4);
			if(length(regexp(pname,profilerMask)) > 0)
				d = load([ppath '/' pname '.txt']);
				%save the last (=best) entry for every duplicate row
				[B I J] = unique(d(:,1),'rows','last');
				d = d(I,:);
				entry.(pname) = d;
			end
		end
		entry.runName = [directory '/' runName];
		
		% store the samples used for this run
		d = load(samplesFile);
		entry.numSamples = size(d,1);
		entry.samples = d;

		% add the information for this run to the list
		data = [data entry];
	end
end
