function [m, scores] = processMeasure(m, model, context, outputIndex)

% processMeasure (SUMO)
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
%	[m, scores] = processMeasure(m, model, context, outputIndex)
%
% Description:
%	This function calls calculateMeasure and replaces NaN/Inf Values

try

	% process this measure
	[m, newModel, scores] = calculateMeasure(m, model, context, outputIndex);

	% replace inf/nan values by a practical infinity
	invalidVals = isfinite(scores);    
	[I J] = find(invalidVals == 0);
	
	% only replace the buggy ones
	scores(I,J) = 1/eps;
    
    if(size(scores,2) ~= size(outputIndex,2))
        error('The measure %s returns %d values while %d are expected',class(m),size(scores,2),size(outputIndex,2));
    end
    
   	if(~isreal(scores))
	  error(sprintf('The measure %s with error function %s returned at least one complex value. A measure must return a positive real number',class(m),func2str(m.errorFcn)));
	end

catch err
	msg = err.message;
	ss = getSamplesInModelSpace(model);
	vv = getValues(model);
	msg = sprintf('Failed to calculate the measure %s on model %s: %s\nThe troublesome model has been saved to disk and has id %d, is built with %d-by-%d samples, %d-by-%d values, and the description is %s',class(m),class(model),msg,getId(model),size(ss,1),size(ss,2),size(vv,1),size(vv,2),getDescription(model));
	m.logger.severe(msg);
	printStackTrace( err.stack, m.logger, java.util.logging.Level.SEVERE );
	logmodel(model,m);
	error(msg);
end


%%%%%%%%%%%%
% save a model causing a crash to disk
function logmodel(mod,this)
  name = [class(this) '_crash_' class(mod) '.mat'];
  name = char(ibbt.sumo.util.Util.makeFilenameUnique(name));
  save(name,'mod')
  this.logger.severe(['Faulty model saved to ' fullfile(pwd,name)]);
  
