classdef SimpleObservable < Observable

% SimpleObservable (SUMO)
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
%	SimpleObservable( name, description, datatype, functor, count )
%
% Description:
%	This is the simplest form of observable.
%	It takes a name, a description, and a functor used to extract
%	the data from the model object.

    properties(Access = private)
        functor;
        count;
        datatype;
    end
    
    methods(Access = public)
        
       function this = SimpleObservable( name, description, datatype, functor, count )

           this = this@Observable(name,description);
           
           if nargin < 5
               this.count = 1;
           else
               this.count = count;
           end

           this.functor = functor;
           this.datatype = datatype;
       end
    
        function obs = process( this, model )
            if isa( model, this.datatype )
                obs = feval( this.functor, model );
            else
                obs = [];
            end
        end

        function t = getType(this)
            t = this.datatype;
        end

        function cols = getColumns( s )
            cols = struct;

            if s.count == 1
                cols.name = getName(s);
                cols.description = getDescription(s);
            else
                for i=1:s.count
                    cols(i).name = sprintf( '%s%d', getName(s), i );
                    if(i == 1)
                        suffix = 'st';
                    elseif(i == 2)
                        suffix = 'nd';
                    elseif(i == 3)
                        suffix = 'rd';
                    else
                        suffix = 'th';
                    end

                    cols(i).description = sprintf( '%s (%d''%s value)', getDescription(s), i, suffix );
                end
            end
        end
        
    end
end
