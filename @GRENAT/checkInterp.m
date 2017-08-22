        %check interpolation
        function [statusR,statusG]=checkInterp(obj)
            statusG=true;
            %evaluation of the approximation at the sample points
            [Z,GZ]=obj.eval(obj.sampling);
            %check interpolation
            statusR=checkInterpRG(obj.resp,Z,'resp');
            if  obj.dataTrain.used.availGrad
                statusG=checkInterpRG(obj.grad,GZ,'grad');
            end
        end