function s = constructInModelSpace( s, samples, values )

% constructInModelSpace (SUMO)
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
%	s = constructInModelSpace( s, samples, values )
%
% Description:
%	Build a RBF model through the samples and values. Just construct
%	the interpolation matrix and solve by simple matrix inversion.

if(size(values,2) > 1)
	error('The RBF models can not model multiple outputs together, please set combineOutputs to false');
end

s = s.constructInModelSpace@Model( samples, values );

switch s.config.backend
	case 'FastRBF'
		rbf_dataset = struct( ...
			'Location', getSamplesInModelSpace(s)', ...
			'Value', getValues(s) ...
		);

		try
			s.fit = fastrbf_fit( rbf_dataset, s.config.targetAccuracy, translateBasisFunction( s ), 'c', s.config.theta );
		catch
			% TODO: Loggers don't save, so currently no logger
			%s.logger.warning( 'Model could not be built for these parameters' );
			s.fit = struct;
		end
		
	case {'direct','Direct'}
		s = directFit( s, samples, values );
		
	case 'AP'
		if size( samples,1 ) < 700
			s = directFit( s, samples, values );
		else
			% Build regression part matrix
			[s,residues] = buildRegressionPart( s, samples, values );
			s.fit.kernelCoefficients = ...
				rbfAlternatingProjections( samples, residues, ...
				translateBasisFunction( s ), s.config.func.theta, s.config.targetAccuracy, 600 );
			s.fit.centers = samples;
		end
		
	case 'Greedy'
		if size( samples,1) < 100
			s = directFit( s, samples, values );
		else
			% Build regression part matrix
			disp( 'Getting residues' );
			[s,residues] = buildRegressionPart( s, samples, values );
			disp( 'Fitting centers' );
			[s.fit.centers,s.fit.kernelCoefficients] = ...
				rbfMultiPointGreedy( samples, residues, ...
				translateBasisFunction( s ), s.config.func.theta, s.config.targetAccuracy, 50 );
		end
end
