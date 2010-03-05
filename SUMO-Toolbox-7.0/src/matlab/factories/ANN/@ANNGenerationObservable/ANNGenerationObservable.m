classdef ANNGenerationObservable < Observable

% ANNGenerationObservable (SUMO)
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
%	ANNGenerationObservable( learningRules )
%
% Description:
%	This observable monitors how often each learning rule is used in a
%	population of ANN models

    
    properties(Access = private)
        rules;
    end
    
    methods(Access = public)
        
        function this = ANNGenerationObservable( learningRules )
            this = this@Observable( 'rules', 'Usage of each training function' );
            this.rules = learningRules;
        end
        
        function obs = process( s, data )
            counters = zeros(length(s.rules),1);
            
            for i=1:length(data.scores)
                model = feval( data.callback, data.population(i,:) );
                if isa( model, 'ANNModel' )
                    modelRule = extractField( model, 'config.learningRule' );
                    for k=1:length(s.rules)
                        if strcmp( modelRule, s.rules{k} )
                            counters(k) = counters(k) + 1;
                        end
                    end
                end
            end
            
            obs = counters;
        end
        
        
        function cols = getColumns( s )
            cols = struct;
            
            for i=1:length(s.rules)
                cols(i).name = s.rules{i};
                cols(i).description = sprintf( 'Use of learning rule %s per generation', s.rules{i} );
            end
        end
        
    end
end
