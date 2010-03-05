classdef LinearConstraint < Constraint

% LinearConstraint (SUMO)
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
%	LinearConstraint(config)
%
% Description:
%	Implementation of a linear constraint

    properties(Access = private)
        Aineq;
        Bineq;
    end
       
    methods(Access = public)

        function this = LinearConstraint(config)

            this = this@Constraint(config);
                
            % Specified: A.x + B <= 0
            AineqB = [str2num( config.self.getOption( 'AineqB' ) )];

            % internally: A.x + B <= 0
            this.Aineq = AineqB(:,1:end-1);
            this.Bineq = AineqB(:,end);
        end
        
        function y = process(this, x )
            %{
            n dimension, m observations
            m*n, 1*n
            (x1 ... xn) * (a1 ... an)'
            (.  ...  .)
            (x1 ... xn)
            %}
            y = (x * this.Aineq') + this.Bineq;
        end
    
        function [Aineq Bineq] = getInternal(this)
            [Aineq, Bineq] = linearEquationToModelSpace( getSampleManager(this), this.Aineq, this.Bineq );
        end
        
    end
end
        
