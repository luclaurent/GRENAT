classdef Observable

% Observable (SUMO)
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
%	Observable( name, description )
%
% Description:
%	A model type can support multiple observables.  An Observable is an
%	object that is able to extract model parameter values from a model so
%	they can be monitored (plotted) during the modeling process.

    properties(Access = private)
        name;
        description;
    end
    
    methods(Access = public)
        
        function this = Observable( name, description )
            this.name = name;
            this.description = description;
        end
        
        function n = getName(this)
            n = this.name;
        end
        
        function d = getDescription(this)
            d = this.description;
        end
    end

    
    methods(Abstract = true)
        obs = process( s, model );
        cols = getColumns( s );
    end

end
