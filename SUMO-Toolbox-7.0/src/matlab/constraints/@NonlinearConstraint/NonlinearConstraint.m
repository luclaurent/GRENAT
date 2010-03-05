classdef NonlinearConstraint < Constraint

% NonlinearConstraint (SUMO)
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
%	NonlinearConstraint(config)
%
% Description:
%	Nonlinear constraint, accepts an arbitrary function handle that
%	implements the constraint

    properties(Access = private)
        logger;
        func;
    end
       
    methods(Access = public)

        function this = NonlinearConstraint(config)

            import java.util.logging.*
            
            this = this@Constraint(config);

            this.logger = Logger.getLogger('Matlab.NonlinearConstraint');
            f = char( config.self.getOption( 'f' ) );

            if exist( f, 'file' ) ~= 2
                msg = sprintf( 'Constraint function invalid or not found (%s)', f );
                this.logger.severe( msg );
                error(msg);
            end

            this.func = str2func( f );
        end
        
        function y = process(this, x )
            y = this.func( x );
        end
    
        function out = getInternal(this)
            % FIXME: put transform in between ?
            out = this.func;
        end
        
    end
end
        
