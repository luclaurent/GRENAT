classdef CategoriesObservable < Observable

% CategoriesObservable (SUMO)
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
%	CategoriesObservable( name, description, types )
%
% Description:
%	This observable monitors how often each model type occurs in a
%	population

    
    properties(Access = private)
        types;
    end
    
    methods(Access = public)
        
        function this = CategoriesObservable( name, description, types )
            this = this@Observable(name,description);
            this.types = types;
        end
        
        function data = process( s, generation )
            nTypes = length(s.types);
            
            map = java.util.HashMap();
            for i=1:nTypes
                map.put(s.types{i},0);
            end
            
            for j=1:length(generation.population)
                m = generation.population{j};
                t = class(m);
                map.put(t,map.get(t) + 1);
            end
            
            data = zeros(nTypes,1);
            for i=1:nTypes
                data(i) = map.get(s.types{i});
            end
            
            % disp(sprintf('sum of all the types is %d',sum(data)));
            % disp('Generated data vector:')
            % data
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
