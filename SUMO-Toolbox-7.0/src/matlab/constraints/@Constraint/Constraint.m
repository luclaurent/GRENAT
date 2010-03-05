classdef Constraint

% Constraint (SUMO)
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
%	Constraint(config)
%
% Description:
%	Abstract base class representing a constraint
%	 Only provides a logger to the derived classes

    properties(Access = private)
        sampleManager;
        logger;
    end
    
    methods(Access = public)
       function this = Constraint(config)

           import java.util.logging.*
           this.logger = Logger.getLogger('Matlab.Constraint');

           % create sample manager, so we can get the transformation functions for models
           this.sampleManager = SampleManager(config);
       end
       
       % Description:
       %     Evaluates a constraint, calling the process function of the derived
       %     constraint.
       function yes = satisfy(this, x )
            [this, x, xid] = preEvaluation( this, x );
            y = process( this, x );

            % return whether or not this constraint was satisfied
            yes = y <= 0;
       end

        % Description:
        %     runs samples through the SampleManager
        %        - model space -> simulator space
        %        - input select
        %        - dummy values
        %        - ...
       function [this, newSamples, newIds] = preEvaluation( this, samples )
            [this.sampleManager, samplePoints] = prepareForEvaluation(this.sampleManager, samples);

            newSamples = zeros(0, samplePoints(1).getInputDimension() );
            newIds = zeros(0, 1);

            for i=1:length(samplePoints)
                newSamples(i,:) = samplePoints(i).getInputParameters().';
                newIds(i,:) = samplePoints(i).getId();
            end
       end
       
        % Description:
        %     Returns function handle by default
       function out = getInternal(this)
            out = @(x) evaluate( this, x );
       end
       
        % Description:
        %     Evaluates a constraint, calling the process function of the derived
        %     constraint
       function y = evaluate(this, x )
		   
            [this, x, xid] = preEvaluation( this, x );
			
            y = process( this, x );
            %this = postEvaluation( this, x, y, xid);

            % NOTE, this pointer is not returned, internal state of samplemanager is
            % lost... why not return it: optimizers only expect one output value.
       end

    end
end
