     %evaluate the CI of the metamodel
        function [ci68,ci95,ci99]=evalCI(obj,nonsamplePts)
            %store non sample points
            if nargin>1;obj.nonsamplePts=nonsamplePts;end
            %eval the CI
            [ci68,ci95,ci99]=BuildCI(obj.nonsampleResp,obj.nonsampleVar);
            obj.nonsampleCI.ci68=ci68;
            obj.nonsampleCI.ci95=ci95;
            obj.nonsampleCI.ci99=ci99;
        end