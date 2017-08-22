        %check interpolation
        function [ZI,detI]=evalInfill(obj,nonsamplePts,Verb)
            if nargin<3;Verb=true;end
            %store non sample points
            if nargin>1;obj.nonsamplePts=nonsamplePts;end
            %evaluation
            obj.eval([],Verb);
            %smallest response
            respMin=min(obj.resp);
            %computation of infill criteria
            ZI=[];
            if ~isempty(obj.nonsampleVar)
                [ZI,detI]=InfillCrit(respMin,obj.nonsampleResp,obj.nonsampleVar,obj.confMeta.infill);
            end
        end