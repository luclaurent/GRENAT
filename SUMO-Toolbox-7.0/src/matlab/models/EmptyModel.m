classdef EmptyModel < Model
    %EMPTYMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function [values] = evaluateInModelSpace(s, points)
            [inDim, outDim] = s.getDimensions();
            values = zeros(size(points,1), outDim);
        end
    end
    
end

