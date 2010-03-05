function [data] = groupProfilerData(directory, runMask, profilerMask);

% groupProfilerData (SUMO)
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
%	[data] = groupProfilerData(directory, runMask, profilerMask);
%
% Description:
%	Groups all the profiler data present in all runs that match the optional runMask regexp. The data is grouped
%	by profiler and not by run (as with collectProfilerData)!
%	The optional profilerMask parameter ensures that only profiler names that match the given regexp are included
%	A struct is returned with one field for each profiler.  Each profiler field then contains a list of the results
%	from the different runs (in addition to some useful statistics).

if(~exist('runMask'))
	runMask = '.*';
end

if(~exist('profilerMask'))
	profilerMask = '.*';
end

% Collect all profilers in the given directory
txtFiles = subdir([directory '/*.txt']);
profilerNames = {};
for i=1:length(txtFiles)
	% filter out the profilers, ignoring other txt files
	if(strfind(txtFiles(i).name,'profilers'))	
		profilerNames = [profilerNames txtFiles(i).name];
	end
end
% Sort them by run
profilerNames = sort(profilerNames);

data = struct();

for p=1:length(profilerNames)
	% get the profiler name
	fullPname = profilerNames{p};
	[path,pname,ext,vers] = fileparts(fullPname);
	
	% get the run name
	% remove the root directory
	runName = path(length(directory)+1:end);

	% remove the profilers subdirectory
	runName = runName(1:end-10);
    
	if( (length(regexp(pname,profilerMask)) > 0) && (length(regexp(runName,runMask)) > 0) )
        
		% get the location of samples.txt
		samplesFile = fullfile(directory,runName,'samples.txt');

		% init the entry if it does not exist yet
		if(~isfield(data,pname(1:min(namelengthmax,length(pname)))))
			data.(pname) = struct();
			data.(pname).data = {};
			data.(pname).runNames = {};
			data.(pname).final = [];
			data.(pname).finalAvg = 0;
			data.(pname).finalMin = 0;
			data.(pname).finalMax = 0;
			data.(pname).finalStd = 0;
			data.(pname).totalSamples = [];
			data.(pname).totalSamplesAvg = 0;
			data.(pname).totalSamplesStd = 0;
			data.(pname).totalSamplesMin = 0;
			data.(pname).totalSamplesMax = 0;
		end
	
		% load and store the actual data
        try
    		d = load(fullPname);
        catch
            disp(sprintf('WARNING : failed to load %s, skipping',fullPname));
            continue
        end
        
		% only save the last (=best) entry for every duplicate row
		[B I J] = unique(d(:,1),'rows','last');
		d = d(I,:);
		data.(pname).data = [data.(pname).data ; d];
		% Calculate the average of all the profiler data
		%[mn stdd mediann madd] = statisticMetrics(data.(pname).data);
		[mn stdd mediann madd] = interpolatedMean( data.(pname).data );
		%[mn stdd mediann madd] = paddedMean( data.(pname).data )	
		data.(pname).meanData = mn;
		data.(pname).stdData = stdd;
		data.(pname).medianData = mediann; % 
		data.(pname).madData = madd; % Median Absolute Deviation (MAD): robust metric
		% save the run names (strip the timestamp of length 20)
		data.(pname).runNames = [data.(pname).runNames runName(1:end-20)];
	        % save the final result of the profiler (= last row)
		data.(pname).final = [data.(pname).final ; d(end,:)];
		% update the statistics
		data.(pname).finalAvg = mean(data.(pname).final);
		data.(pname).finalMin = min(data.(pname).final);
		data.(pname).finalMax = max(data.(pname).final);
		data.(pname).finalStd = std(data.(pname).final);
		% the number of samples in samples.txt
		d = load(fullfile(directory,runName,'samples.txt'));
		data.(pname).totalSamples = [data.(pname).totalSamples size(d,1)];
		data.(pname).totalSamplesAvg = mean(data.(pname).totalSamples);
		data.(pname).totalSamplesStd = std(data.(pname).totalSamples);
		data.(pname).totalSamplesMin = min(data.(pname).totalSamples);
		data.(pname).totalSamplesMax = max(data.(pname).totalSamples);
	end
end

% Shouldnt be needed
%  % sort the runNames alphabetically for each entry
%  for p=1:length(profilerNames)
%  	[data.(pname).runNames,I] = sort(data.(pname).runNames);
%  	data.(pname).final = data.(pname).final(I,:);
%  end
