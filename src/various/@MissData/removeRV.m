
        %% remove missing data in vector/matrix (responses)
        function VV=removeRV(obj,V,type)
            %size of the input vector
            sV=size(V);
            %deal with no force parameter
            if nargin<3;type='';end
            %deal with different options (in type)
            force=false;
            sizS=obj.nS;
            maskC=obj.maskResp;
            switch type
                case {'f','F','force','Force','FORCE'}
                    force=true;
                case {'n','N','new','New','NEW'}
                    sizS=obj.NnS;
                    maskC=obj.newResp.maskResp;
            end
            if sV(1)==sizS||force
                VV=V(~maskC,:);
            else
                VV=V;
                Gfprintf(' ++ Wrong size of the input vector\n ++ |%i, expected: %i| (or use force)\n',sV(1),sizS);
            end
        end