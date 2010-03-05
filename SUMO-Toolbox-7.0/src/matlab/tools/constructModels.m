function models = constructModels(models,samples,values,parallelMode)

% constructModels (SUMO)
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
%	models = constructModels(models,samples,values,parallelMode)
%
% Description:
%	Given a cell or array of model objects this function will call construct on all of them.  If parallelMode is true
%	the parallel computing toolbox will be used if available.  This means models will be trained in parallel, saving
%	time.  If the toolbox is not available, fall back to training sequentially.

if(parallelMode && length(models) > 1)
  enabled = setupParallelMode(0);

  if(enabled)
    models = parConstruct(models,samples,values);
  else
    models = seqConstruct(models,samples,values);
  end

else
    models = seqConstruct(models,samples,values);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function res = seqConstruct(ms,ss,vs)
        if(iscell(ms))
          res = cell(length(ms),1);
          for i=1:length(ms)
            res{i} = constructInModelSpace(ms{i},ss,vs);
          end
        else
          res = repmat(ms(1),length(ms),1);
          for i=1:length(ms)
            res(i) = constructInModelSpace(ms(i),ss,vs);
          end
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function res = parConstruct(ms,ss,vs)
        
        if(iscell(ms))
          res = cell(length(ms),1);
          parfor i=1:length(ms)
            res{i} = constructInModelSpace(ms{i},ss,vs);
          end
        else
          res = repmat(ms(1),length(ms),1);
          parfor i=1:length(ms)
            res(i) = constructInModelSpace(ms(i),ss,vs);
          end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
