classdef LOLAVoronoiSampleSelector < SampleSelector & CandidateRanker

% LOLAVoronoiSampleSelector (SUMO)
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
%	LOLAVoronoiSampleSelector(config)
%
% Description:

	
	properties
		LOLA;
		Voronoi;
		logger;
        frequency;
        frequencies;
        frequencySlices;
	end
	
	methods (Access = public)
		
		function s = LOLAVoronoiSampleSelector(config)
            s@CandidateRanker(config);
            
			import java.util.logging.*
			s.logger = Logger.getLogger('Matlab.LOLAVoronoiSampleSelector');
            
            % dimensions
            inDim = config.input.getInputDimension();
            outDim = config.output.getOutputDimension();
            

            % check inputs for auto-sampling (not supported by this sample selector)
            frequencyDim = [];
            inputs = config.input.getInputDescriptions();
            for i = 1:length(inputs)
                if inputs(i).isSampledAutomatically()
                    frequencyDim = [frequencyDim i];
                end
            end
            s.frequency = frequencyDim;
            s.frequencySlices = str2num(char(config.self.getOption('frequencySlices', '[]')));
            s.frequencies = config.self.getIntOption('frequencies', 0);
            
            % modify the dimensions based on the frequency variable
            if isempty(s.frequency)
                % do nothing
            else
                
                % make sure frequencies is specified
                if s.frequencies == 0
                    msg = 'If there is a auto-sampled input, the number of auto-sampled points must be specified with a ''frequencies'' option for LOLA-Voronoi.';
                    s.logger.severe(msg);
                    error(msg);
                end

                % frequency dim is not sampled
                inDim = inDim - length(s.frequency);

                % if no frequency slices are defined, use them all
                if isempty(s.frequencySlices)
                    s.frequencySlices = 1 : s.frequencies;
                end

                % for each frequency slice, we generate a new output dim
                outDim  = outDim * length(s.frequencySlices);

            end
            
			% get stuff
			options = struct;
			options.neighbourhoodSize = config.self.getIntOption('neighbourhoodSize', 2);
			options.gradientMethod = char(config.self.getOption('gradientMethod', 'direct'));
			options.debug = config.self.getBooleanOption('debug', false);
			options.combineOutputs = char(config.self.getOption('combineOutputs', 'max'));
            
            % create sample rankers
			s.LOLA = LOLASampleRanker(inDim, outDim, options);
			s.Voronoi = VoronoiSampleRanker(inDim, outDim);
			
		end
		
		[this, newSamples, priorities] = selectSamples(this, state);
		[this, scores] = scoreCandidates(this, candidates, state);
		
	end
	
end
