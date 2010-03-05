classdef PipelineSampleSelector < SampleSelector

% PipelineSampleSelector (SUMO)
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
%	PipelineSampleSelector(config)
%
% Description:

	
	properties
		dimension;
		logger;
		candidateGenerator;
		candidateRankers;
		mergeCriterion;
		debug = false;
	end
	
	
	
	methods (Access = public)
		
		
		function [s] = PipelineSampleSelector(config)
			import java.util.logging.*;
			import ibbt.sumo.config.*;

			s.logger = Logger.getLogger('Matlab.PipelineSampleSelector');
			s.logger.info(sprintf('Constructing PipelineSampleSelector...'));
			
			% first get the candidate generator
			subs = config.self.selectNodes('CandidateGenerator');
			
			% need one candidate generator
			if subs.size() ~= 1
				msg = sprintf('You need to specify a CandidateGenerator object to generate candidates to score.');
				s.logger.severe(msg);
				error(msg);
			end

			% instantiate the candidate generator
			sub = subs.get(0);
			s.candidateGenerator = instantiateClassOrFunction(sub, config, 'CandidateGenerator');
			s.logger.info(sprintf('Constructed candidate generator %s', s.candidateGenerator.getType()));
			

			% read xml-data from config file
			subs = config.self.selectNodes('CandidateRanker');

			% need at least one candidate ranker
			if subs.size() == 0
				msg = sprintf('You need to specify at least one candidateRanker for scoring the candidates.');
				s.logger.severe(msg);
				error(msg);
			end
			
			% instantiate all subobjects as defined in the config file
			s.candidateRankers = cell(subs.size(), 1);
			for k=1:subs.size()
				
				% first instantiate the ranker
				sub = subs.get(k-1);
				obj = instantiateClassOrFunction(sub, config, 'CandidateRanker');
				s.candidateRankers{k} = obj;
				
				% all done
				s.logger.info(['Registered candidate ranker of type ' obj.getType()]);
			end

			s.dimension = config.input.getInputDimension();

			% read xml-data from config file
			subs = config.self.selectNodes('MergeCriterion');
			
			% no merge criterion specified, just create the default one
			if subs.size() ~= 1
				s.mergeCriterion = WeightedAverage([]);
			
			% instantiate the merge criterion
			else
				sub = subs.get(0);
				s.mergeCriterion = instantiateClassOrFunction(sub, config, 'MergeCriterion');
				s.logger.info(sprintf('Constructed merge criterion %s', s.mergeCriterion.getType()));
			end
			
			s.debug = config.self.getBooleanOption('debug', false );
		end
		
		% defined in separate file
		[s, newSamples, priorities] = selectSamples(s, state);
		
		
	end
	
end
