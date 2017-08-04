
        
        %% remove missing data in vector/matrix (gradients)
        function VV=removeGV(obj,V,type)
            %size of the input vector
            sV=size(V);
            %deal with no force parameter
            if nargin<3;type='';end
            %deal with different options (in type)
            force=false;
            sizS=obj.nS;
            maskC=obj.ixAvailGradLine;
            switch type
                case {'f','F','force','Force','FORCE'}
                    force=true;
                case {'n','N','new','New','NEW'}
                    sizS=obj.NnS;
                    maskC=obj.newGrad.ixAvailGradLine;
            end
            if sV(1)==sizS*obj.nP||force
                VV=V(maskC,:);
            else
                VV=V;
                Gfprintf(' ++ Wrong size of the input vector\n ++ |%i, expected: %i| (or use force)\n',sV,sizS*obj.nP);
            end
        end