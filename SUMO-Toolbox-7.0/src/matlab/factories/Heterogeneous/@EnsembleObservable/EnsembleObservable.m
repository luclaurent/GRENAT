classdef EnsembleObservable < Observable

% EnsembleObservable (SUMO)
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
%	EnsembleObservable( name, description, modelTypes )
%
% Description:
%	This observable tracks the composition of the best performing
%	ensemble

    
    properties(Access = private)
        types;
    end
    
    methods(Access = public)
        
        function this = EnsembleObservable( name, description, modelTypes )
            this = this@Observable(name,description);
            this.types = modelTypes;
        end
        
        function data = process( s, generation )
            %Find best performing ensemble in the population (= the ensemble with the smallest score)
            [Y I] = sort(generation.scores,1,'ascend');
            
            found = false;
            for i=1:length(I)
                model = generation.population{I(i)};
                
                if(isa(model,'EnsembleModel'))
                    found = true;
                    break;
                end
            end
            
            %Get the data
            if(found)
                %Get the number models of each type in the ensemble
                map = getModelTypes(model);
                
                %The ensemble may not necessarily contain all types
                %so add the ones it does not contain to the map with count 0
                for i=1:length(s.types)
                    if(~map.containsKey(s.types{i}))
                        map.put(s.types{i},0);
                    end
                end
                
                data = zeros(length(s.types),1);
                for i=1:length(s.types)
                    data(i) = map.get(s.types{i});
                end
            else
                data = [];
            end
            
        end
        
        
        function columns = getColumns( s )
            columns = struct;
            
            for k=1:length(s.types)
                columns(k).name = s.types{k};
                columns(k).description = sprintf( '%s', s.types{k} );
            end
        end
    end
end

