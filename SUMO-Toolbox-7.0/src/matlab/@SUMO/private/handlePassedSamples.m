function [passedSamples passedValues samplesPassed] = handlePassedSamples(s, passedSamples, passedValues)

% handlePassedSamples (SUMO)
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
%	[passedSamples passedValues samplesPassed] = handlePassedSamples(s, passedSamples, passedValues)
%
% Description:
%	Check if the user passed samples/values on the command line and do some sanity checking

if (size(passedSamples,1) ~= size(passedValues,1))
	msg = sprintf('The samples and values passed on the commandline do not have an equal number of rows');
	s.logger.severe(msg);
	error(msg);
end

samplesPassed = false;
if(size(passedSamples,1) > 0)
	s.logger.info(sprintf('%d %d-dimensional samples with %d %d-dimensional values were passed on the command line',size(passedSamples,1),size(passedSamples,2),size(passedValues,1),size(passedValues,2)));
	samplesPassed = true;

	if (size(passedSamples,1) < 2)
		msg = sprintf('At least 2 samples must be passed on the commandline');
		s.logger.severe(msg);
		error(msg);
	end	

	simInDim = s.simulatorDimension;
	if(simInDim ~= size(passedSamples,2))
		msg = sprintf('Dimension mismatch: %d-dimensional samples passed while the simulator is declared to have %d inputs',size(passedSamples,2),simInDim);
		s.logger.severe(msg);
		error(msg);
	end

	simOutDim = s.simulatorOutputDimension;
	if(simOutDim ~= size(passedValues,2))
		msg = sprintf('Dimension mismatch: %d-dimensional values passed while the simulator is declared to have %d outputs',size(passedSamples,2),simOutDim);
		s.logger.severe(msg);
		error(msg);
	end
end
