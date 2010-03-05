function [] = printBestResults(s)

% printBestResults (SUMO)
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
%	[] = printBestResults(s)
%
% Description:
%	Print information about the best modeling results so far.

% get the best model
model = getBestModel(s);
mdata = model.getMeasureScores();
measureScores = mdata.measureInfo;
score = model.getScore();

% print for each output
for o = 1 : length(s.outputNames)
	
	% get name of this output
	outputName = s.outputNames{o};
	
	% final targets reached?
	if s.finalTargetsReached
		finalReached = '(final targets reached)';
	else
		finalReached = '';
	end
	
	% print achieved accuracy for all measures
	s.logger.info(sprintf('  %s:     %s', outputName, finalReached));
	
	% print measures in INFO mode
	for i=1:length(measureScores{o})
	    measureStruct = measureScores{o}{i};
	    s.logger.info(sprintf( '    * Score on measure %s (%s) : %d%s' , measureStruct.type, measureStruct.errorFcn, measureStruct.score, iff(measureStruct.enabled, '', ' (not used)' ) ));
    end 
end
