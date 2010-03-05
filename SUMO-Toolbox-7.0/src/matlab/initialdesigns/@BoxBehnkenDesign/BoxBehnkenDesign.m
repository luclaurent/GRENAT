classdef BoxBehnkenDesign < InitialDesign

% BoxBehnkenDesign (SUMO)
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
%	BoxBehnkenDesign(config)
%
% Description:
%	Choose an initial sampleset according to a Box-Behnken design
%	Note: relies on the matlab bbdesign command, so the Matlab statistics toolbox is required

  properties
  end

  methods
    function this = BoxBehnkenDesign(config)
      % construct the base class
      this = this@InitialDesign(config);

      if(~exist('bbdesign'))
	error('To use Box-Behnken Design, you must have the Statistics toolbox installed')
      end
      
      [in out] = this.getDimensions();
      
      if(in < 3)
	error('To use a Box-Behnken design, the design dimension must be greater than 2');
      end
    end

    % Choose an initial sample set based on the Box-Behnken design
    % See "help bbdesign" for more information
    function [initialsamples, evaluatedsamples] = generate(this)
      [in out] = this.getDimensions();
      initialsamples = bbdesign(in);
    
      % scale to -1 1
      initialsamples = scaleColumns(initialsamples);

      evaluatedsamples = [];
    end

  end
end
