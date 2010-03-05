function values = evaluateInModelSpaceBatch(model, samples, outputIndex, blockSize)

% evaluateInModelSpaceBatch (SUMO)
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
%	values = evaluateInModelSpaceBatch(model, samples, outputIndex, blockSize)
%
% Description:
%	Evaluate a large set of samples in smaller blocks

% we evaluate the model in blocks
nSamples = size(samples,1);
values = zeros(nSamples,length(outputIndex));

start = 1;

if(blockSize > nSamples)
  stop = nSamples;
else
  stop = blockSize;
end

while(start < nSamples)

  % evaluate the model
  tmp = evaluateInModelSpace(model,samples(start:stop,:));
  
  % append to result
  values(start:stop,:) = tmp(:,outputIndex);

  start = start + blockSize;
  stop = stop + blockSize;
  
  if(stop > nSamples)
    stop = nSamples;
  end

end

