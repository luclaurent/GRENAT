classdef ComplexWrapper < Model

% ComplexWrapper (SUMO)
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
%	ComplexWrapper(varargin)
%
% Description:
%	A utility class to wrap 2 models for a complex output.  One model represents the real
%	component, the other model represents the imaginary component.

    
    properties(Access = private)
        realModel;
        imagModel;
    end
    
    methods(Access = public)
        function this = ComplexWrapper(varargin)
            
            if nargin == 1
                baseModel = varargin{1};
                realModel = OutputFilterWrapper(baseModel, 1);
                imagModel = OutputFilterWrapper(baseModel, 2);
            elseif nargin == 2
                realModel = varargin{1};
                imagModel = varargin{2};
            else
                error('Invalid number of arguments given');
            end
            
            [ri ro] = getDimensions(realModel);
            [ii io] = getDimensions(imagModel);
            
            if( (ri ~= ii) || (ro ~= io) )
                error('The input/output dimensions of the two sub-models do not match!');
            end
            
            if(ro ~= 1)
                error('The output dimension must be 1');
            end
            
            if(numel(getSamplesInModelSpace(realModel)) ~= numel(getSamplesInModelSpace(imagModel)))
                error('Both models must have been built with exactly the same samples');
            end
            
            this = this@Model(ri,1, getSamplesInModelSpace(realModel), getValues(realModel) + i * getValues(imagModel));
            
            % set the transformation functions
            this = this.setTransformationValues(realModel.getTransformationValues());
            
            this.realModel = realModel;
            this.imagModel = imagModel;
            
            this = this.setInputNames(realModel.getInputNames());
            ro = realModel.getOutputNames();
            io = imagModel.getOutputNames();
            
            this = this.setOutputNames({[ro{1} '_' io{1}]});
            
        end
        
        function desc = getDescription( this )
            desc = sprintf('Real part:\n %s \nImaginary part:\n %s \n',getDescription(this.realModel), getDescription(this.imagModel));
        end
        
        %this = constructInModelSpace(this, samples, values);
        [values] = evaluateInModelSpace(this, points);
        desc = getExpressionInModelSpace(this, outputIndex);
        
    end
end
