function enabled = setupParallelMode(verbose)

% setupParallelMode (SUMO)
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
%	enabled = setupParallelMode(verbose)
%
% Description:
%	See if we can do Matlab computations in parallel

if(~exist('verbose','var'))
  verbose = 1;
end

logger = java.util.logging.Logger.getLogger('Matlab.setupParallelMode');

minVersion = '4.0';
maxVersion = '4.3';

% Check if the parallel computing toolbox is installed or if it makes sense to use it
v = ver('distcomp');
if(length(v) == 0 || maxNumCompThreads() == 1)
  % no it is not available, or it makes no sense, make sure the global option is set to off
  enabled = false;
else
  % yes it is available,
   if( verLessThan('distcomp',minVersion) || ~verLessThan('distcomp',maxVersion))
      msg = sprintf('The SUMO Toolbox has only been tested with the parallel computing toolbox version %s and %s, you are using %s, trying to continue anyway...',minVersion,maxVersion,v.Version);
      if(verbose)
	logger.warning(msg);
      else
	logger.finest(msg);
      end
    end
      
      msg = 'If you get strange problems with the parallel mode on, please turn it off';
      if(verbose)
	logger.warning(msg);
      end

  % check if a worker pool has been opened;
  numWorkers = matlabpool('size');
  if(numWorkers > 0)
    % ok a pool is available, all good
    logger.fine(sprintf('Matlab parallel computing mode enabled, %d workers are available',numWorkers));
    enabled = true;
  else
    % no pool is available, try to open one
    % how many threads can we run (local restricts us to max 4 or 8 depending on the toolbox version)
    
    if(verLessThan('distcomp','4.2'))
        n = min(maxNumCompThreads(),4);
    else
        n = min(maxNumCompThreads(),8);        
    end
        
    logger.info(sprintf('No worker pool is available trying to open a pool of %d workers...',n));
    try
      matlabpool('open',n);
      enabled = true;
      numWorkers = matlabpool('size');
      logger.info(sprintf('Matlab parallel computing mode enabled, %d workers are available',numWorkers));
    catch ME
      logger.severe(sprintf('Failed to open matlab pool, error is %s',ME.message));
      enabled = false;
    end
  end
end
