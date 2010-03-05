classdef BatchObservable < Observable

% BatchObservable (SUMO)
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
%	BatchObservable( name, description, observable, what )
%
% Description:
%	This observable works on a set of models, instead of on a single
%	model

    
    properties(Access = private)
        observable;
        what;
    end
    
    methods(Access = public)
        
        function this = BatchObservable( name, description, observable, what )
            name = sprintf( '%s_%s', name, observable.getName() );
            this = this@Observable(name,description);
            
            this.observable = observable;
            this.what = what;
        end
        
        function values = process( s, data )
            % Sort the score ascending, the best score is 0
            [scores,indices] = sort( data.scores );
            
            switch s.what
                case 'best'
                    values = process( s.observable, feval( data.callback, data.population(indices(1),:)) );
                case 'spread'
                    bestValues = process( s.observable, feval( data.callback, data.population(indices(1),:)) );
                    worstValues = process( s.observable, feval( data.callback, data.population(indices(end),:)) );
                    medianValues = process( s.observable, feval( data.callback, data.population(indices(fix(length(indices)/2)),:)) );
                    
                    
                    if length(bestValues) == length(worstValues) && length(bestValues) == length(medianValues)
                        if(ischar(bestValues))
                            values = {bestValues, worstValues, medianValues};
                        else
                            values = [bestValues(:) ;medianValues(:) ;worstValues(:)].';
                        end
                    else
                        values = [];
                    end
                    
                otherwise
                    error( 'Internal error, `what'' unknown' );
            end
            
        end
        
        function t = getType(this)
            t = getType(this.observable);
        end
        
        function columns = getColumns( s )
            cols = getColumns( s.observable );
            
            switch s.what
                case 'best'
                    columns = cols;
                case 'spread'
                    columns = struct;
                    nCols = length(cols);
                    names = { 'best', 'median', 'worst' };
                    count = 1;
                    for l=1:3
                        for k=1:nCols
                            columns(count).name = sprintf( '%s_%s', names{l}, cols(k).name );
                            columns(count).description = sprintf( '%s (The %s model)', cols(k).name, names{l} );
                            count = count+1;
                        end
                    end
            end
        end
        
    end
end


