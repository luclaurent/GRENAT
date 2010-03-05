function varargout = createDesigns(func, nrSamples, design, template)

% createDesigns (SUMO)
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
%	varargout = createDesigns(func, nrSamples, design, template)
%
% Description:

	import java.util.logging.Logger;
	import java.util.logging.Level;
    import ibbt.sumo.config.*; % SimulatorConfig
    import ibbt.sumo.util.*;
    
	rootlogger = Logger.getLogger( '' );
	rootlogger.setLevel( Level.ALL );

	if ~iscell( nrSamples )
		nrSamples = {nrSamples};
	end
	
	if ~iscell( design )
		design = {design};
	end
	
	if ~iscell( template )
		template = {template};
	end

	assert( length( template ) == length( design ) );
	assert( length( design ) == length( nrSamples ) );
	
    if ischar( func )
        simCfg = SimulatorConfig( func );
        exe = simCfg.getExecutable( SystemPlatform.MATLAB, SystemArchitecture.ANY );
		if isempty( exe )
			func = [];
		else
			addpathRecursive( fileparts( func ) );
			func = str2func( char(exe.getText()) );
		end
        
		funcName = lower( char(simCfg.getName()) );
        dim = simCfg.getInputDimension();
        inputs = simCfg.getInputParameterNodes();
        it = inputs.iterator();
        
        % TODO sort
        LB = zeros(1,dim);
        UB = zeros(1,dim);
        for i=1:dim
           var = NodeConfig.newInstance( it.next() );
           LB(i) = var.getDoubleAttrValue( 'minimum', '-1' );
           UB(i) = var.getDoubleAttrValue( 'maximum', '1' );
        end
	else
		if isempty( func )
			funcName = 'empty';
		else
			funcName = func2str( func );
		end
		
        % preset bounds
        % transform from [-1,1] to [?,?]
        dim = 4;
        LB = -1.*ones(1,dim); % default (lna6s)
        UB = 1.*ones(1,dim);
        %LB = 0.*ones(1,dim);
        %UB = 1.*ones(1,dim);

        % specific bounds
        %LB = [1000 0.01]; % TTL
        %UB = [8*1e9 0.1];

        %LB = [0 0 0 0 0 0]; % HARTMAN 6D
        %UB = [1 1 1 1 1 1];
        %LB = [0 0 0]; % HARTMAN 3D
        %UB = [1 1 1];

        %LB = [-5 0]; % Branin 2D
        %UB = [10 15];
    
        % Guillaume MMI
        %LB= [2.246 1.2043 1.0782 2.5];
        %UB = [3.246 1.44431 1.39821 5.5];

        %LB = [0.05 100 63070 990 63.1 700 1120 9855]; % borehole 8D
        %UB = [0.15 50000 115600 1110 116 820 1680 12045];
        
        dim = length(LB);
	end
	
	data = cell( length(design), length(nrSamples) );
	
	for i=1:length(design)
		
		currSamples = nrSamples{i};
		nrDecimals = ceil( log10(max(currSamples))+1 );
		if length( currSamples ) ~= size( currSamples, 1 )
			currSamples = currSamples.';
		end
			
		for j=1:size(currSamples, 1)
			msg = ['%s%0.' num2str(nrDecimals) 'i.txt'];
			fileout = sprintf( msg, template{i}, currSamples(j,:) );
				
			disp(['Constructing ' template{i} ': ' fileout]);

            
            if strcmp( design{i}, 'lhsdesign' )
                samples = lhsdesign( currSamples(j,:), dim, 'iterations', 200, 'criterion', 'maximin' );
                samples = (samples - 0.5) * 2;
            else
                d = feval( design{i}, dim, currSamples(j,:) );
                samples = generate(d);
            end

            
			transl = (UB+LB)/2.0;			
			transl = repmat( transl, size(samples,1), 1);
			scale = (UB-LB)/2.0;
			scale = repmat( scale, size(samples,1), 1);
			samples = (samples .* scale) + transl;

			% assume function is not vectorized
			dataIJ = samples;
			outputIdx = size(dataIJ,2)+1;
            if ~isempty( func )
                for k=1:size(samples,1)
                    dataIJ(k,outputIdx) = func(samples(k,:));
					
					if mod( k, 100 ) == 0
						disp(sprintf('Sample %i of %i', k, size(samples,1) ));
					end
                end
            end
			data{i,j} = dataIJ;
			
			if nargout < 1
				save( fileout, 'dataIJ', '-ascii' )
			end
		end
	
	end
	
	if nargout > 0
		varargout{1} = data;
		varargout{2} = funcName;
	end

end
