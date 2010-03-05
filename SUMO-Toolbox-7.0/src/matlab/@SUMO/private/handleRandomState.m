function handleRandomState(config,logger)

% handleRandomState (SUMO)
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
%	handleRandomState(config,logger)
%
% Description:
%	Sets and saves the random state depending on the configuration

import ibbt.sumo.config.*;

randStateType = char(config.self.getOption( 'seedRandomState', 'default'));
randStateFile = char(config.self.getOption( 'randomStateFile', ''));

if(strcmp(randStateType,'default'))
    %Do nothing, keep the default matlab initialization

elseif(strcmp(randStateType,'random'))
    % seed the random state randomly

    % only seed during the first run since seeding multiple times in one session is evil
    if(config.context.getCurrentRunNumber() == 1)
      if(verLessThan('matlab', '7.7'))
	rand('state',sum(100*clock));
	randn('state',sum(100*clock));
      else
	RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
      end

      logger.info('Random number generators initialized randomly');

    else
	logger.fine('Not re-seeding random state randomly since we are no longer in the first run');
    end
      

elseif(strcmp(randStateType,'file'))

    if(isempty(randStateFile))
      error('If the random state type is file, you must specify a valid filename to load the random state from');
    end

    try
      %Seed the random number generator with the saved state
      % note this is done every run
      loadedState = load(randStateFile);

      if(verLessThan('matlab', '7.7'))
	rand('state',loadedState.state.r); 
	randn('state',loadedState.state.rn);
      else
	defaultStream = RandStream.getDefaultStream;
	defaultStream.State = loadedState.state;
      end

      logger.info(['Random state restored from file ' randStateFile]);
    catch err
      logger.warning(['Failed to load random state from file ' randStateFile ' (' err.message ')']);
    end
else
    logger.warning(sprintf('Unknown value %s for seedRandomState option',randStateType));
end

% make sure we save the current random state in the output directory
saveRandomState(config,logger);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function saveRandomState(config,logger)

  fname = fullfile(char(config.context.getOutputDirectory()), 'randState.mat');

  if(verLessThan('matlab', '7.7'))
      state.r = rand('state');
      state.rn = randn('state');
  else
      defaultStream = RandStream.getDefaultStream;
      state = defaultStream.State;
  end

  try
      save(fname, 'state');
      logger.info(['Current random state saved to ' fname]);
  catch
      logger.warning(['Failed to save the random state to ' fname]);
  end

