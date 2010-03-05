classdef Model < ModelInterface

% Model (SUMO)
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
%	getNestedModel(s)
%	Model(varargin)
%
% Description:
%	Constructs an abstract Model object.

    
    properties (Access = private)
        samples;
        values;
        dimension;
        score;
        measureScores;
        outputDimension;
        inputNames;
        outputNames;
        transformationValues;
        modelId;
        version;
	mode = 'regression';
    end
    
    
    % method definitions
    methods
        
        % a normal model returns itself as the nested model (base case)
        function model = getNestedModel(s)
            model = s;
        end
        
        % constructor, note that it is not called when an object is loaded from disk
        function s = Model(varargin)
            
            if nargin == 0
                % do nothing
            elseif nargin == 2
                nin = varargin{1};
                nout = varargin{2};
                samples = zeros(0, nin);
                values = zeros(0, nout);
            elseif nargin == 4
                nin = varargin{1};
                nout = varargin{2};
                samples = varargin{3};
                values = varargin{4};
            else
                error('Invalid number of input arguments.');
            end
            
            % perform init if we have provided samples/values or in/out dims
            if (nargin >= 2)
                s = s.init(samples, values);
            end
            
            % Set to the current revision number
            % Note that this setup relies on the fact that ConstrucOnLoad for this class is FALSE (= the default)
            s.version = '$Rev: 6376 $';
        end
        
    end
    
    
    % final & static functions
    methods (Sealed = true, Static = true)
        function plotDefaults = getPlotDefaults()
            plotDefaults = struct(...
                'plotPoints',		true,...
                'plotUncertainty',	false,...
                'alphaVal',			1,...
                'lighting',		false,...
                'lightPos',		[0 0 50],...
                'lightStyle',		'Infinite',...
                'slices',		3,...
                'title',		{''},...
                'grayScale',		false,...
                'meshSize',		51,...
                'outputAxisRange',	[],...
                'fontSize',		14,...
                'logScale',		false,...
                'plotModels', true, ...
                'withContour',		true,...
                'plotContour',		false, ...
                'saveModels', true, ...
                'saveModelPlots', true, ...
                'bounds', [], ...
                'color', [], ...
                'newFigure', false, ...
                'outputType',	'png' ...
                );
        end
    end
    
    
    % method declarations (final)
    methods (Sealed = true, Access = public)
        
        [fighandle] = basicPlotModel(varargin);
        
        s = init(s, samples, values);
        s = construct(s, samples, values);
        s = update(s, samples, values);
        
        [in, out] = getDimensions(s);
        [exp] = getExpression(s,outputIndex);
        
        id = getId(m);
        [samples, values] = getGrid(m);
        
        res = equals(s, m, threshold);
        values = evaluate(s, points);
        values = evaluateDerivative(s, points, outputIndex);
        
        values = evaluateMSE(s, points);
        
        [m] = setTransformationValues(m, transf);
        [inFunc outFunc] = getTransformationFunctions(m);
        
        function [transf] = getTransformationValues(m)
            transf = m.transformationValues;
        end
        
        this = setMeasureScores(this, scores);
        [scores] = getMeasureScores(this);
        
        samples = getSamples(m);
        samples = getSamplesInModelSpace(m);
        values = getValues(m);
        
        [s] = setScore(s, score);
        [score] = getScore(s);
        [LB UB] = getBounds(s);
        
        m = setInputNames(m, names);
        m = setOutputNames(m, names);
        names = getInputNames(m);
        names = getOutputNames(m);
        
	% are we in regression or classification mode
    	function m = setMode(m,mode)
    		m.mode = mode;
    	end

	% are we in regression or classification mode
    	function res = getMode(m)
    		res = m.mode;
    	end

        function v = getVersion(m)
            if(isempty(m.version))
                v = [];
            else
                v = m.version(2:end-2);
            end
        end
    end
    
    % method declarations (not final), these can be overridden
    methods (Access = public)
        
        % Override matlabs built-in display function
        function display(m)
            disp(' ')
            disp([inputname(1) ' ='])
            for i = 1 : length(m)
                disp(' ')
                disp(['	' m(i).getDescription()]);
            end
            disp(' ')
        end
        
        [fighandle] = plotModel(varargin);
        s = constructInModelSpace(s, samples, values);
        res = complexity(model);
        desc = getExpressionInModelSpace(s, outputIndex);
        values = evaluateDerivativeInModelSpace(s, points, outputIndex);
        s = updateInModelSpace( s, samples, values );
        
        function desc = getDescription(s)
            desc = ['Model object of type ' class(s)];
        end
    end
    
    % abstract methods, these must be implemented
    methods (Abstract = true, Access = public)
        [values] = evaluateInModelSpace(s, points);
    end
    
    
end
