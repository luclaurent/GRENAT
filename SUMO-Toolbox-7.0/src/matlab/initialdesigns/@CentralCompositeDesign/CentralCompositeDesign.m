classdef CentralCompositeDesign < InitialDesign

% CentralCompositeDesign (SUMO)
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
%	CentralCompositeDesign(config)
%
% Description:
%	Choose an initial sampleset according to a central composite design
%	Note: relies on the matlab ccdesign command, so the Matlab statistics toolbox is required

  properties
	type;
	fraction;
	center;
  end

  methods
    function this = CentralCompositeDesign(config)
      % construct the base class
      this = this@InitialDesign(config);

      if(~exist('ccdesign'))
	error('To use CentralCompositeDesign, you must have the Statistics toolbox installed')
      end
      
      this.type = char(config.self.getOption('type', 'inscribed'));
      this.fraction', config.self.getIntOption('fraction', 0);
      this.center = char(config.self.getOption('center', 'orthogonal'));
    end

    % Choose an initial sample set based on the Central Composite design
    % See "help ccdesign" for more information
    function [initialsamples, evaluatedsamples] = generate(this)
      [in out] = this.getDimensions();

      initialsamples = ccdesign(in, 'type', this.type, 'fraction', this.fraction, 'center', this.center);

      % scale to -1 1
      initialsamples = scaleColumns(initialsamples);

      evaluatedsamples = [];
    end

  end

end
