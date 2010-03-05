classdef CombinedDesign < InitialDesign

% CombinedDesign (SUMO)
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
%	CombinedDesign(config)
%
% Description:
%	Wrap 2 different Initial Designs Together
%	When one asks this class to select samples, it just glues together
%	the arrays returned by the subobjects...

  properties
    logger;
    subObjects;
  end

  methods

    function this = CombinedDesign(config)
      % construct the base class
      this = this@InitialDesign(config);

      import java.util.logging.*
      this.logger = Logger.getLogger('Matlab.CombinedDesign');

      % read xml-data from config file
      subs = config.self.selectNodes('InitialDesign');

      % instantiate all subobjects as defined in the config file
      this.logger.info('Constructing CombinedDesign');
      objects = cell(subs.size(), 1);
      for k = 1:subs.size()
	   objects{k} = instantiate(subs.get(k-1), config);
	   this.logger.info( ['Registered sub-design of type ' class(objects{k})] );
      end      

      this.subObjects = objects;
    end

    % Call selectSamples on each subobject and glue them together
    function [initialsamples, evaluatedsamples] = generate(this)
      initialsamples = [];
      evaluatedsamples = [];

      for k=1:length(this.subObjects)
	      [newinit, neweval] = generate(this.subObjects{k});
	      initialsamples = [initialsamples; newinit];
	      evaluatedsamples = [evaluatedsamples; neweval];
      end

    end

  end
end
